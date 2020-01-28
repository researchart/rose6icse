/***** mx_fw_taliro : parse.c *****/

/* Written by Georgios Fainekos, ASU, U.S.A.                              */
/* Copyright (c) 2011  Georgios Fainekos								  */
/* Send bug-reports and/or questions to: fainekos@asu.edu			      */

/* This program is free software; you can redistribute it and/or modify   */
/* it under the terms of the GNU General Public License as published by   */
/* the Free Software Foundation; either version 2 of the License, or      */
/* (at your option) any later version.                                    */
/*                                                                        */
/* This program is distributed in the hope that it will be useful,        */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of         */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          */
/* GNU General Public License for more details.                           */
/*                                                                        */
/* You should have received a copy of the GNU General Public License      */
/* along with this program; if not, write to the Free Software            */
/* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA*/

/* Most of the code in this file was taken from LTL2BA software           */
/* Written by Denis Oddoux, LIAFA, France					              */
/* Some of the code in this file was taken from the Spin software         */
/* Written by Gerard J. Holzmann, Bell Laboratories, U.S.A.               */

#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"

extern int	tl_yylex(void);
extern int	tl_verbose, tl_simp_log;
extern Interval zero2inf;

int	tl_yychar = 0;
YYSTYPE	tl_yylval;
Interval TimeCon;

static Node	*tl_formula(void);
static Node	*tl_factor(void);
static Node	*tl_level(int);

static int	prec[2][4] = {
	{ U_OPER,  V_OPER, 0, 0},  /* left associative */
	{ OR, AND, IMPLIES, EQUIV, },	/* left associative */
};

static int
implies(Node *a, Node *b)
{
  return
    (isequal(a,b) ||
     b->ntyp == TRUE ||
     a->ntyp == FALSE ||
     (b->ntyp == AND && implies(a, b->lft) && implies(a, b->rgt)) ||
     (a->ntyp == OR && implies(a->lft, b) && implies(a->rgt, b)) ||
     (a->ntyp == AND && (implies(a->lft, b) || implies(a->rgt, b))) ||
     (b->ntyp == OR && (implies(a, b->lft) || implies(a, b->rgt))) ||
     (b->ntyp == U_OPER && implies(a, b->rgt)) ||
     (a->ntyp == V_OPER && implies(a->rgt, b)) ||
     (a->ntyp == U_OPER && implies(a->lft, b) && implies(a->rgt, b)) ||
     (b->ntyp == V_OPER && implies(a, b->lft) && implies(a, b->rgt)) ||
     ((a->ntyp == U_OPER || a->ntyp == V_OPER) && a->ntyp == b->ntyp && 
         implies(a->lft, b->lft) && implies(a->rgt, b->rgt)));
}

static Node *bin_simpler(Node *ptr)
{	Node *a, *b;

	if (ptr)
	switch (ptr->ntyp) {
	case U_OPER:
		if (ptr->rgt->ntyp == TRUE
		||  ptr->rgt->ntyp == FALSE
		||  ptr->lft->ntyp == FALSE)
		{	ptr = ptr->rgt;
			break;
		}
		if (implies(ptr->lft, ptr->rgt)) /* NEW */
		{	ptr = ptr->rgt;
		        break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->lft, ptr->rgt))
		{	/* (p U q) U p = (q U p) */
			ptr->lft = ptr->lft->rgt;
			break;
		}
		if (ptr->rgt->ntyp == U_OPER
		&&  implies(ptr->lft, ptr->rgt->lft))
		{	/* NEW */
			ptr = ptr->rgt;
			break;
		}
		/* X p U X q == X (p U q) */
		if (ptr->rgt->ntyp == NEXT
		&&  ptr->lft->ntyp == NEXT)
		{	ptr = tl_nn(NEXT,
				tl_nn(U_OPER,
					ptr->lft->lft,
					ptr->rgt->lft), ZN);
		        break;
		}

		/* NEW : F X p == X F p */
		if (ptr->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == NEXT) {
		  ptr = tl_nn(NEXT, tl_nn(U_OPER, True, ptr->rgt->lft), ZN);
		  break;
		}

		/* NEW : F G F p == G F p */
		if (ptr->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == V_OPER &&
		    ptr->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->rgt->ntyp == U_OPER &&
		    ptr->rgt->rgt->lft->ntyp == TRUE) {
		  ptr = ptr->rgt;
		  break;
		}

		/* NEW */
		if (ptr->lft->ntyp != TRUE && 
		    implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)), ptr->lft))
		{       ptr->lft = True;
		        break;
		}
		break;
	case V_OPER:
		if (ptr->rgt->ntyp == FALSE
		||  ptr->rgt->ntyp == TRUE
		||  ptr->lft->ntyp == TRUE)
		{	ptr = ptr->rgt;
			break;
		}
		if (implies(ptr->rgt, ptr->lft))
		{	/* p V p = p */	
			ptr = ptr->rgt;
			break;
		}
		/* F V (p V q) == F V q */
		if (ptr->lft->ntyp == FALSE
		&&  ptr->rgt->ntyp == V_OPER)
		{	ptr->rgt = ptr->rgt->rgt;
			break;
		}
		/* NEW : G X p == X G p */
		if (ptr->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == NEXT) {
		  ptr = tl_nn(NEXT, tl_nn(V_OPER, False, ptr->rgt->lft), ZN);
		  break;
		}
		/* NEW : G F G p == F G p */
		if (ptr->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == U_OPER &&
		    ptr->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->rgt->ntyp == V_OPER &&
		    ptr->rgt->rgt->lft->ntyp == FALSE) {
		  ptr = ptr->rgt;
		  break;
		}

		/* NEW */
		if (ptr->rgt->ntyp == V_OPER
		&&  implies(ptr->rgt->lft, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}

		/* NEW */
		if (ptr->lft->ntyp != FALSE && 
		    implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN))))
		{       ptr->lft = False;
		        break;
		}
		break;
	case NEXT:
		/* NEW : X G F p == G F p */
		if (ptr->lft->ntyp == V_OPER &&
		    ptr->lft->lft->ntyp == FALSE &&
		    ptr->lft->rgt->ntyp == U_OPER &&
		    ptr->lft->rgt->lft->ntyp == TRUE) {
		  ptr = ptr->lft;
		  break;
		}
		/* NEW : X F G p == F G p */
		if (ptr->lft->ntyp == U_OPER &&
		    ptr->lft->lft->ntyp == TRUE &&
		    ptr->lft->rgt->ntyp == V_OPER &&
		    ptr->lft->rgt->lft->ntyp == FALSE) {
		  ptr = ptr->lft;
		  break;
		}
		break;
	case IMPLIES:
		if (implies(ptr->lft, ptr->rgt))
		  {	ptr = True;
			break;
		}
		ptr = tl_nn(OR, Not(ptr->lft), ptr->rgt);
		ptr = rewrite(ptr);
		break;
	case EQUIV:
		if (implies(ptr->lft, ptr->rgt) &&
		    implies(ptr->rgt, ptr->lft))
		  {	ptr = True;
			break;
		}
		a = rewrite(tl_nn(AND,
			dupnode(ptr->lft),
			dupnode(ptr->rgt)));
		b = rewrite(tl_nn(AND,
			Not(ptr->lft),
			Not(ptr->rgt)));
		ptr = tl_nn(OR, a, b);
		ptr = rewrite(ptr);
		break;
	case AND:
		/* p && (q U p) = p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->lft;
			break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt))
		{	ptr = ptr->rgt;
			break;
		}

		/* p && (q V p) == q V p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}
		if (ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) && (r U q) = (p && r) U q*/
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft->rgt))
		{	ptr = tl_nn(U_OPER,
				tl_nn(AND, ptr->lft->lft, ptr->rgt->lft),
				ptr->lft->rgt);
			break;
		}

		/* (p V q) && (p V r) = p V (q && r) */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft))
		{	ptr = tl_nn(V_OPER,
				ptr->rgt->lft,
				tl_nn(AND, ptr->lft->rgt, ptr->rgt->rgt));
			break;
		}
		/* X p && X q == X (p && q) */
		if (ptr->rgt->ntyp == NEXT
		&&  ptr->lft->ntyp == NEXT)
		{	ptr = tl_nn(NEXT,
				tl_nn(AND,
					ptr->rgt->lft,
					ptr->lft->lft), ZN);
			break;
		}
		/* (p V q) && (r U q) == p V q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = ptr->lft;
			break;
		}

		if (isequal(ptr->lft, ptr->rgt)	/* (p && p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p && F) == F */
		||  ptr->lft->ntyp == TRUE	/* (T && p) == p */
		||  implies(ptr->rgt, ptr->lft))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p && T) == p */
		||  ptr->lft->ntyp == FALSE	/* (F && p) == F */
		||  implies(ptr->lft, ptr->rgt))/* NEW */
		{	ptr = ptr->lft;
			break;
		}
		
		/* NEW : F G p && F G q == F G (p && q) */
		if (ptr->lft->ntyp == U_OPER &&
		    ptr->lft->lft->ntyp == TRUE &&
		    ptr->lft->rgt->ntyp == V_OPER &&
		    ptr->lft->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == U_OPER &&
		    ptr->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->rgt->ntyp == V_OPER &&
		    ptr->rgt->rgt->lft->ntyp == FALSE)
		  {
		    ptr = tl_nn(U_OPER, True,
				tl_nn(V_OPER, False,
				      tl_nn(AND, ptr->lft->rgt->rgt,
					    ptr->rgt->rgt->rgt)));
		    break;
		  }

		/* NEW */
		if (implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)))
		 || implies(ptr->rgt, 
			    push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN))))
		{       ptr = False;
		        break;
		}
		break;

	case OR:
		/* p || (q U p) == q U p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}

		/* p || (q V p) == p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) || (p U r) = p U (q || r) */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft))
		{	ptr = tl_nn(U_OPER,
				ptr->rgt->lft,
				tl_nn(OR, ptr->lft->rgt, ptr->rgt->rgt));
			break;
		}

		if (isequal(ptr->lft, ptr->rgt)	/* (p || p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p || F) == p */
		||  ptr->lft->ntyp == TRUE	/* (T || p) == T */
		||  implies(ptr->rgt, ptr->lft))/* NEW */
		{	ptr = ptr->lft;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p || T) == T */
		||  ptr->lft->ntyp == FALSE	/* (F || p) == p */
		||  implies(ptr->lft, ptr->rgt))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}

		/* (p V q) || (r V q) = (p || r) V q */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = tl_nn(V_OPER,
				tl_nn(OR, ptr->lft->lft, ptr->rgt->lft),
				ptr->rgt->rgt);
			break;
		}

		/* (p V q) || (r U q) == r U q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = ptr->rgt;
			break;
		}		
		
		/* NEW : G F p || G F q == G F (p || q) */
		if (ptr->lft->ntyp == V_OPER &&
		    ptr->lft->lft->ntyp == FALSE &&
		    ptr->lft->rgt->ntyp == U_OPER &&
		    ptr->lft->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == V_OPER &&
		    ptr->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->rgt->ntyp == U_OPER &&
		    ptr->rgt->rgt->lft->ntyp == TRUE)
		  {
		    ptr = tl_nn(V_OPER, False,
				tl_nn(U_OPER, True,
				      tl_nn(OR, ptr->lft->rgt->rgt,
					    ptr->rgt->rgt->rgt)));
		    break;
		  }

		/* NEW */
		if (implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)),
			    ptr->lft)
		 || implies(push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN)),
			    ptr->rgt))
		{       ptr = True;
		        break;
		}
		break;
	}
	return ptr;
}

static Node *bin_minimal(Node *ptr)
{       
	Node *a, *b;

	if (ptr)
	{
		switch (ptr->ntyp) 
		{
			case IMPLIES:
				return tl_nn(OR, Not(ptr->lft), ptr->rgt);

			case EQUIV:
				a = tl_nn(AND,dupnode(ptr->lft),dupnode(ptr->rgt));
				b = tl_nn(AND,Not(ptr->lft),Not(ptr->rgt));
				return tl_nn(OR, a, b); 
		}
	}
	return ptr;
}

static Node *tl_factor(void)
{	
	Node *ptr = ZN;

	switch (tl_yychar) 
	{
	case '(':
		ptr = tl_formula();
		if (tl_yychar != ')')
			tl_yyerror("expected ')'");
		tl_yychar = tl_yylex();
		goto simpl;

	case NOT:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		ptr = push_negation(ptr);
		goto simpl;

	case ALWAYS:
		ptr = tl_nn(V_OPER, False, ptr);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		if(tl_simp_log) 
		{	/* must be modified! */
			if (ptr->ntyp == V_OPER)
			{	
				if (ptr->lft->ntyp == FALSE)
					break;	/* [][]p = []p */
				ptr = ptr->rgt;	/* [] (p V q) = [] q */
			}
		}
		goto simpl;

	case NEXT:
		ptr = tl_nn(NEXT, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

	case WEAKNEXT:
		ptr = tl_nn(WEAKNEXT, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

	case EVENTUALLY:
		ptr = tl_nn(U_OPER, True, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		if(tl_simp_log) 
		{	/* this must be modified */
			if (ptr->ntyp == U_OPER	&&  ptr->lft->ntyp == TRUE)		    
				break;	/* <><>p = <>p */
			if (ptr->ntyp == U_OPER)
			{	/* <> (p U q) = <> q */
				ptr = ptr->rgt;
				/* fall thru */
			}
		}
/*		goto simpl;

	case IMPLIES:
		ptr = tl_nn(OR, Not(ptr->lft), ptr->rgt);
		goto simpl;

	case EQUIV:
		a = tl_nn(AND,dupnode(ptr->lft),dupnode(ptr->rgt));
		b = tl_nn(AND,Not(ptr->lft),Not(ptr->rgt));
		ptr = tl_nn(OR, a, b); */

	simpl:
		if (tl_simp_log) 
		  ptr = bin_simpler(ptr);
		break;

	case PREDICATE:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		break;

	case TRUE:
	case FALSE:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		break;
	}
	if (!ptr) tl_yyerror("expected predicate");
#if 0
	printf("factor:	");
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}

static Node *tl_level(int nr)
{	
	int i; Node *ptr = ZN;
	Interval LocInter;

	if (nr < 0)
		return tl_factor();

	ptr = tl_level(nr-1);
again:
	for (i = 0; i < 4; i++)
		if (tl_yychar == prec[nr][i])
		{	
			if (nr==0 && (i==0 || i==1))
				LocInter = TimeCon;
			tl_yychar = tl_yylex();
			ptr = tl_nn(prec[nr][i],ptr,tl_level(nr-1));
			if (nr==0 && (i==0 || i==1))
				ptr->time = LocInter;
			if(tl_simp_log) 
				ptr = bin_simpler(ptr);
			else 
				ptr = bin_minimal(ptr);
			goto again;
		}
	if (!ptr) tl_yyerror("syntax error");
#if 0
	printf("level %d:	", nr);
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}

static Node *
tl_formula(void)
{	tl_yychar = tl_yylex();
	return tl_level(1);	/* 2 precedence levels, 1 and 0 */	
}

Node *tl_parse(void)
{  
   Node *n = tl_formula();
   if (tl_verbose)
	{	printf("formula: ");
		put_uform();
		printf("\n");
	}
	return(n);
}


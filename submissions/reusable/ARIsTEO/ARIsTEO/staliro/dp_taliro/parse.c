/***** mx_dp_taliro : parse.c *****/

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


static Node	*tl_formula(int *, size_t, char *, Miscellaneous *, int *);
static Node	*tl_factor(int *, size_t, char *, Miscellaneous *, int *);
static Node	*tl_level(int,int *, size_t, char *, Miscellaneous *, int *);


static int
implies(Node *a, Node *b, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
  return
    (isequal(a,b, cnt, uform, tl_yychar, miscell) ||
     b->ntyp == TRUE ||
     a->ntyp == FALSE ||
     (b->ntyp == AND && implies(a, b->lft, cnt, uform, tl_yychar, miscell) && implies(a, b->rgt, cnt, uform, tl_yychar, miscell)) ||
     (a->ntyp == OR && implies(a->lft, b, cnt, uform, tl_yychar, miscell) && implies(a->rgt, b, cnt, uform, tl_yychar, miscell)) ||
     (a->ntyp == AND && (implies(a->lft, b, cnt, uform, tl_yychar, miscell) || implies(a->rgt, b, cnt, uform, tl_yychar, miscell))) ||
     (b->ntyp == OR && (implies(a, b->lft, cnt, uform, tl_yychar, miscell) || implies(a, b->rgt, cnt, uform, tl_yychar, miscell))) ||
     (b->ntyp == U_OPER && implies(a, b->rgt, cnt, uform, tl_yychar, miscell)) ||
     (a->ntyp == V_OPER && implies(a->rgt, b, cnt, uform, tl_yychar, miscell)) ||
     (a->ntyp == U_OPER && implies(a->lft, b, cnt, uform, tl_yychar, miscell) && implies(a->rgt, b, cnt, uform, tl_yychar, miscell)) ||
     (b->ntyp == V_OPER && implies(a, b->lft, cnt, uform, tl_yychar, miscell) && implies(a, b->rgt, cnt, uform, tl_yychar, miscell)) ||
     ((a->ntyp == U_OPER || a->ntyp == V_OPER) && a->ntyp == b->ntyp && 
         implies(a->lft, b->lft, cnt, uform, tl_yychar, miscell) && implies(a->rgt, b->rgt, cnt, uform, tl_yychar, miscell)));
}

static Node *bin_simpler(Node *ptr, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
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
		if (implies(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell)) /* NEW */
		{	ptr = ptr->rgt;
		        break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->lft, ptr->rgt, cnt, uform, tl_yychar, miscell))
		{	/* (p U q) U p = (q U p) */
			ptr->lft = ptr->lft->rgt;
			break;
		}
		if (ptr->rgt->ntyp == U_OPER
		&&  implies(ptr->lft, ptr->rgt->lft, cnt, uform, tl_yychar, miscell))
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
					ptr->rgt->lft, miscell), ZN, miscell);
		        break;
		}

		/* NEW : F X p == X F p */
		if (ptr->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == NEXT) {
		  ptr = tl_nn(NEXT, tl_nn(U_OPER, True, ptr->rgt->lft, miscell), ZN, miscell);
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
		    implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN, miscell), miscell, cnt, uform, tl_yychar), ptr->lft, cnt, uform, tl_yychar, miscell))
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
		if (implies(ptr->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
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
		  ptr = tl_nn(NEXT, tl_nn(V_OPER, False, ptr->rgt->lft, miscell), ZN, miscell);
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
		&&  implies(ptr->rgt->lft, ptr->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->rgt;
			break;
		}

		/* NEW */
		if (ptr->lft->ntyp != FALSE && 
		    implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN, miscell), miscell, cnt, uform, tl_yychar), cnt, uform, tl_yychar, miscell))
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
		  break;
		}
		/* NEW : X F G p == F G p */
		if (ptr->lft->ntyp == U_OPER &&
		    ptr->lft->lft->ntyp == TRUE &&
		    ptr->lft->rgt->ntyp == V_OPER &&
		    ptr->lft->rgt->lft->ntyp == FALSE) {
		  break;
		}
		break;
	case ALWAYS:
		/* NEW : [] G F p == G F p */
		if (ptr->rgt->ntyp == V_OPER &&
		    ptr->rgt->rgt->ntyp == FALSE &&
		    ptr->rgt->lft->ntyp == U_OPER &&
		    ptr->rgt->lft->rgt->ntyp == TRUE) {
		  ptr = ptr->rgt;
		  break;
		}
		/* NEW : [] F G p == F G p */
		if (ptr->rgt->ntyp == U_OPER &&
		    ptr->rgt->rgt->ntyp == TRUE &&
		    ptr->rgt->lft->ntyp == V_OPER &&
		    ptr->rgt->lft->rgt->ntyp == FALSE) {
		  ptr = ptr->rgt;
		  break;
		}
		break;

	case IMPLIES:
		if (implies(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell))
		  {	ptr = True;
			break;
		}
		ptr = tl_nn(OR, Not(ptr->lft), ptr->rgt, miscell);
		ptr = canonical(right_linked(ptr), miscell, cnt, uform, tl_yychar);
		break;
	case EQUIV:
		if (implies(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell) &&
		    implies(ptr->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
		  {	ptr = True;
			break;
		}
		a = canonical(right_linked(tl_nn(AND,
			dupnode(ptr->lft),
			dupnode(ptr->rgt), miscell)), miscell, cnt, uform, tl_yychar);
		b = canonical(right_linked(tl_nn(AND,
			Not(ptr->lft),
			Not(ptr->rgt), miscell)), miscell, cnt, uform, tl_yychar);
		ptr = tl_nn(OR, a, b, miscell);
		ptr = canonical(right_linked(ptr), miscell, cnt, uform, tl_yychar);
		break;
	case AND:
		/* p && (q U p) = p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->lft;
			break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->rgt;
			break;
		}

		/* p && (q V p) == q V p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->rgt;
			break;
		}
		if (ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) && (r U q) = (p && r) U q*/
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft->rgt, cnt, uform, tl_yychar, miscell))
		{	ptr = tl_nn(U_OPER,
				tl_nn(AND, ptr->lft->lft, ptr->rgt->lft, miscell),
				ptr->lft->rgt, miscell);
			break;
		}

		/* (p V q) && (p V r) = p V (q && r) */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = tl_nn(V_OPER,
				ptr->rgt->lft,
				tl_nn(AND, ptr->lft->rgt, ptr->rgt->rgt, miscell), miscell);
			break;
		}
		/* X p && X q == X (p && q) */
		if (ptr->rgt->ntyp == NEXT
		&&  ptr->lft->ntyp == NEXT)
		{	ptr = tl_nn(NEXT,
				tl_nn(AND,
					ptr->rgt->lft,
					ptr->lft->lft, miscell), ZN, miscell);
			break;
		}
		/* (p V q) && (r U q) == p V q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->lft;
			break;
		}

		if (isequal(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell)	/* (p && p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p && F) == F */
		||  ptr->lft->ntyp == TRUE	/* (T && p) == p */
		||  implies(ptr->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p && T) == p */
		||  ptr->lft->ntyp == FALSE	/* (F && p) == F */
		||  implies(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell))/* NEW */
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
					    ptr->rgt->rgt->rgt, miscell), miscell), miscell);
		    break;
		  }

		/* NEW */
		if (implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN, miscell), miscell, cnt, uform, tl_yychar), cnt, uform, tl_yychar, miscell)
		 || implies(ptr->rgt, 
			    push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN, miscell), miscell, cnt, uform, tl_yychar), cnt, uform, tl_yychar, miscell))
		{       ptr = False;
		        break;
		}
		break;

	case OR:
		/* p || (q U p) == q U p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->rgt;
			break;
		}

		/* p || (q V p) == p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) || (p U r) = p U (q || r) */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft, cnt, uform, tl_yychar, miscell))
		{	ptr = tl_nn(U_OPER,
				ptr->rgt->lft,
				tl_nn(OR, ptr->lft->rgt, ptr->rgt->rgt, miscell), miscell);
			break;
		}

		if (isequal(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell)	/* (p || p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p || F) == p */
		||  ptr->lft->ntyp == TRUE	/* (T || p) == T */
		||  implies(ptr->rgt, ptr->lft, cnt, uform, tl_yychar, miscell))/* NEW */
		{	ptr = ptr->lft;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p || T) == T */
		||  ptr->lft->ntyp == FALSE	/* (F || p) == p */
		||  implies(ptr->lft, ptr->rgt, cnt, uform, tl_yychar, miscell))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}

		/* (p V q) || (r V q) = (p || r) V q */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt, cnt, uform, tl_yychar, miscell))
		{	ptr = tl_nn(V_OPER,
				tl_nn(OR, ptr->lft->lft, ptr->rgt->lft, miscell),
				ptr->rgt->rgt, miscell);
			break;
		}

		/* (p V q) || (r U q) == r U q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt, cnt, uform, tl_yychar, miscell))
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
					    ptr->rgt->rgt->rgt, miscell), miscell), miscell);
		    break;
		  }

		/* NEW */
		if (implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN, miscell), miscell, cnt, uform, tl_yychar),
			    ptr->lft, cnt, uform, tl_yychar, miscell)
		 || implies(push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN, miscell), miscell, cnt, uform, tl_yychar),
			    ptr->rgt, cnt, uform, tl_yychar, miscell))
		{       ptr = True;
		        break;
		}
		break;
	}
	return ptr;
}

static Node *bin_minimal(Node *ptr, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
{       
	Node *a, *b;

	if (ptr)
	{
		switch (ptr->ntyp) 
		{
			case IMPLIES:
				return tl_nn(OR, Not(ptr->lft), ptr->rgt, miscell);

			case EQUIV:
				a = tl_nn(AND,dupnode(ptr->lft),dupnode(ptr->rgt), miscell);
				b = tl_nn(AND,Not(ptr->lft),Not(ptr->rgt), miscell);
				return tl_nn(OR, a, b, miscell); 

		}
	}
	return ptr;
}

static Node *tl_factor(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	
	Node *ptr = ZN;
	int tl_simp_log_p = 0;


	switch ((*tl_yychar)) 
	{
	case '(':
		ptr = tl_formula(cnt, hasuform, uform, miscell, tl_yychar);
		if ((*tl_yychar) != ')')
			tl_yyerror("expected ')'", cnt, uform, tl_yychar, miscell);
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		goto simpl;

	case NOT:
		ptr = miscell->tl_yylval;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		ptr->lft = tl_factor(cnt, hasuform, uform, miscell, tl_yychar);
		ptr = push_negation(ptr, miscell, cnt, uform, tl_yychar);
		goto simpl;

	case ALWAYS:
		ptr = tl_nn(ALWAYS, False, ZN, miscell);
		ptr->time = miscell->TimeCon;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		ptr->rgt = tl_factor(cnt, hasuform, uform, miscell, tl_yychar);
/*		if(tl_simp_log_p) 
		{	/* must be modified! */
/*			if (ptr->ntyp == V_OPER)
			{	
				if (ptr->lft->ntyp == FALSE)
					break;	/* [][]p = []p */
/*				ptr = ptr->rgt;	/* [] (p V q) = [] q */
/*			}
		}
*/		goto simpl;

	case NEXT:
		ptr = tl_nn(NEXT, ZN, ZN, miscell);
		ptr->time = miscell->TimeCon;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		ptr->lft = tl_factor(cnt, hasuform, uform, miscell, tl_yychar);
		goto simpl;

	case WEAKNEXT:
		ptr = tl_nn(WEAKNEXT, ZN, ZN, miscell);
		ptr->time = miscell->TimeCon;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		ptr->lft = tl_factor(cnt, hasuform, uform, miscell, tl_yychar);
		goto simpl;

	case EVENTUALLY:
		ptr = tl_nn(EVENTUALLY, True, ZN, miscell);
		ptr->time = miscell->TimeCon;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		ptr->rgt = tl_factor(cnt, hasuform, uform, miscell, tl_yychar);

/*	case U_OPER:
		ptr = tl_nn(U_OPER, ZN, ZN);
		ptr->time = miscell->TimeCon;
		(*tl_yychar) = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;
*/		goto simpl;

/*	case IMPLIES:
		ptr = tl_nn(OR, Not(ptr->lft), ptr->rgt);
		goto simpl;

/*	case EQUIV:
		a = tl_nn(AND,dupnode(ptr->lft),dupnode(ptr->rgt));
		b = tl_nn(AND,Not(ptr->lft),Not(ptr->rgt));
		ptr = tl_nn(OR, a, b); */

	simpl:
		if (tl_simp_log_p) 
		  ptr = bin_simpler(ptr,miscell,cnt,uform, tl_yychar);
		break;

	case PREDICATE:
		ptr = miscell->tl_yylval;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		break;

	case TRUE:
	case FALSE:
		ptr = miscell->tl_yylval;
		(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
		break;
	}
	if (!ptr) tl_yyerror("expected predicate", cnt, uform, tl_yychar, miscell);
#if 0
	printf("factor:	");
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}

static Node *tl_level(int nr, int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	
	int i; Node *ptr = ZN;
	Interval LocInter;
	int tl_simp_log_p = 0;
	static int	prec[2][4] = {
	{ U_OPER,  V_OPER, 0, 0},  /* left associative */
	{ OR, AND, IMPLIES, EQUIV, },	/* left associative */
};


	if (nr < 0)
		return tl_factor(cnt, hasuform, uform, miscell, tl_yychar);

	ptr = tl_level(nr-1, cnt, hasuform, uform, miscell, tl_yychar);
again:
	for (i = 0; i < 4; i++)
		if ((*tl_yychar) == prec[nr][i])
		{	
			if (nr==0 && (i==0 || i==1))
				LocInter = miscell->TimeCon;
			(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
			ptr = tl_nn(prec[nr][i],ptr,tl_level(nr-1, cnt, hasuform, uform, miscell, tl_yychar), miscell);
			if (nr==0 && (i==0 || i==1))
				ptr->time = LocInter;
			if(tl_simp_log_p) 
				ptr = bin_simpler(ptr,miscell,cnt,uform, tl_yychar);
			else 
				ptr = bin_minimal(ptr,miscell,cnt,uform, tl_yychar);
			goto again;
		}
	if (!ptr) tl_yyerror("syntax error", cnt, uform, tl_yychar, miscell);
#if 0
	printf("level %d:	", nr);
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}

static Node *
tl_formula(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	(*tl_yychar) = tl_yylex(cnt, hasuform, uform, miscell, tl_yychar);
	return tl_level(1, cnt, hasuform, uform, miscell, tl_yychar);	/* 2 precedence levels, 1 and 0 */	
}

Node *tl_parse(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{  
	int tl_verbose_p = 0;
   Node *n = tl_formula(cnt, hasuform, uform, miscell, tl_yychar);
   if (tl_verbose_p)
	{	printf("formula: ");
		put_uform(uform, miscell);
		printf("\n");
	}
	return(n);
}


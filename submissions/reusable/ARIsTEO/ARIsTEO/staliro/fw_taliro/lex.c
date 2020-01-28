/***** mx_fw_taliro : lex.c *****/

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

#include <stdlib.h>
#include <ctype.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "monitor.h"

static Symbol *symtab[Nhash+1];
static int tl_lex(void);

extern YYSTYPE	tl_yylval;
char	yytext[2048];
extern Interval TimeCon;
extern Interval zero2inf;
extern Number zero;
extern FWTaliroParam fw_taliro_param;

#define Token(y)			tl_yylval = tl_nn(y,ZN,ZN); return y
#define MetricToken(y)		tl_yylval = tl_nn(y,ZN,ZN); tl_yylval->time = TimeCon; return y

int isalnum_(int c)
{       
	return (isalnum(c) || c == '_');
}

int hash(char *s)
{       
	int h=0;
	while (*s)
	{       
		h += *s++;
		h <<= 1;
		if (h&(Nhash+1))
			h |= 1;
	}
	return h&Nhash;
}

static void getword(int first, int (*tst)(int))
{	
	int i=0; char c;

	yytext[i++]= (char ) first;
	while (tst(c = tl_Getchar()))
		yytext[i++] = c;
	yytext[i] = '\0';
	tl_UnGetchar();
}

Number getnumber(char cc) /* get a number from input string */
{
	int sign = 1;
	int ii = 0; 
	char strnum[80];
	Number num;

	if (cc=='-')
	{	
		sign = -1;
		do {	
			cc = tl_Getchar();
		} while (cc == ' ');
	}
	else if (cc == '+')
	{	
		do {	
			cc = tl_Getchar(); 
		} while (cc == ' ');
	}
	
	if (cc=='i')
	{	cc = tl_Getchar();
		if (cc=='n')
		{	cc = tl_Getchar();
			if (cc=='f')
			{	if (fw_taliro_param.ConOnSamples)
				{	
					num.numi.inf = sign;
					num.numi.i_num = 0;
				}
				else
				{	
					num.numf.inf = sign;
					num.numf.f_num = 0.0;
				}
			}
			else
			{	tl_UnGetchar();
				tl_yyerror("expected a number or a (-)inf in timing constraints!");
				tl_exit(0);
			}
		}
		else
		{	tl_UnGetchar();
			tl_yyerror("expected a number or a (-)inf in timing constraints!");
			tl_exit(0);
		}
	}
	else if (('0'<=cc && cc<='9') || cc=='.')
	{
		strnum[ii++] = cc;
		for (cc = tl_Getchar(); cc!=' '&& cc!=',' && cc!=']' && cc!=')'; cc = tl_Getchar())
		{ 	
			if (ii>=80)
			{	
				tl_UnGetchar();
				tl_yyerror("numeric constants must have length less than 80 characters.");
				tl_exit(0);
			}
			strnum[ii++] = cc;
		}
		tl_UnGetchar();
		strnum[ii] = '\0';
		if (fw_taliro_param.ConOnSamples)
		{	num.numi.inf = 0;
			num.numi.i_num = sign*atoi(strnum);
		}
		else
		{	num.numf.inf = 0;
			num.numf.f_num = (double)sign*atof(strnum);
		}
	}
	else
	{
		tl_UnGetchar();
		tl_yyerror("expected a number or inf");
		tl_exit(0);
	}
	return(num);
}

Interval getbounds(void)
{	
	char cc;
	Interval time;

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');
	
	if (cc!='[' && cc!='(')
	{
		tl_UnGetchar();
		tl_yyerror("expected '(' or '[' after _");
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc=='[')
		time.l_closed = 1;
	else
		time.l_closed = 0;

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');
	
	/* get lower bound */
	time.lbd = getnumber(cc);
	if (e_le(time.lbd,zero,&fw_taliro_param))
	{
		tl_UnGetchar();
		tl_yyerror("past time operators are not allowed - only future time intervals.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	if (cc!=',')
	{	
		tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2>.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	/* get upper bound */
	time.ubd = getnumber(cc);

	if (e_ge(time.lbd,time.ubd,&fw_taliro_param))
	{	tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2> with num1 <= num2.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	if (cc!=']' && cc!=')')
	{
		tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2>, where > is from the set {),]}");
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc==']')
		time.u_closed = 1;
	else
		time.u_closed = 0;

	return(time);

}

static int follow(int tok, int ifyes, int ifno)
{	
	int c;
	char buf[32];
	extern int tl_yychar;

	if ((c = tl_Getchar()) == tok)
		return ifyes;
	tl_UnGetchar();
	tl_yychar = c;
	sprintf(buf, "expected '%c'", tok);
	tl_yyerror(buf);	/* no return from here */
	return ifno;
}

static void mtl_con(void)
{
	char c;
	c = tl_Getchar();
	if (c == '_')
	{
		fw_taliro_param.LTL = 0;
		TimeCon = getbounds();
	}
	else
	{
		TimeCon = zero2inf;
		tl_UnGetchar();
	}
}

static int mtl_follow(int tok, int ifyes, int ifno)
{	
	int c;
	char buf[32];
	extern int tl_yychar;

	if ((c = tl_Getchar()) == tok)
	{
		mtl_con();
		return ifyes;
	}
	tl_UnGetchar();
	tl_yychar = c;
	sprintf(buf, "expected '%c'", tok);
	tl_yyerror(buf);	/* no return from here */
	return ifno;
}

int
tl_yylex(void)
{	int c = tl_lex();
#if 0
	printf("c = %d\n", c);
#endif
	return c;
}

static int tl_lex(void)
{	
	int c;

	do {
		c = tl_Getchar();
		yytext[0] = (char ) c;
		yytext[1] = '\0';
		if (c <= 0)
		{	Token(';');
		}
	} while (c == ' ');	/* '\t' is removed in tl_main.c */

	/* get the truth constants true and false and predicates */
	if (islower(c))
	{	getword(c, isalnum_);
		if (strcmp("true", yytext) == 0)
		{	Token(TRUE);
		}
		if (strcmp("false", yytext) == 0)
		{	Token(FALSE);
		}
		tl_yylval = tl_nn(PREDICATE,ZN,ZN);
		tl_yylval->sym = tl_lookup(yytext);
		return PREDICATE;
	}
	/* get temporal operators */
	if (c == '<')
	{	
		c = tl_Getchar();
		if (c == '>') 
		{
			tl_yylval = tl_nn(EVENTUALLY,ZN,ZN);
			mtl_con();
			return EVENTUALLY;
		}
		if (c != '-')
		{	
			tl_UnGetchar();
			tl_yyerror("expected '<>' or '<->'");
		}
		c = tl_Getchar();
		if (c == '>')
		{	
			Token(EQUIV);
		}
		tl_UnGetchar();
		tl_yyerror("expected '<->'");
	}

	switch (c) 
	{
		case '/' : 
			c = follow('\\', AND, '/'); 
			break;
		case '\\': 
			c = follow('/', OR, '\\'); 
			break;
		case '&' : 
			c = follow('&', AND, '&'); 
			break;
		case '|' : 
			c = follow('|', OR, '|'); 
			break;
		case '[' : 
			c = mtl_follow(']', ALWAYS, '['); 
			break;
		case '-' : 
			c = follow('>', IMPLIES, '-'); 
			break;
		case '!' : 
			c = NOT; 
			break;
		case 'U' : 
			mtl_con();
			c = U_OPER;
			break;
		case 'R' : 
			mtl_con();
			c = V_OPER;
			break;
		case 'X' : 
			mtl_con();
			c = NEXT;
			break;
		case 'W' : 
			mtl_con();
			c = WEAKNEXT;
			break;
		default  : break;
	}
	Token(c);
}

Symbol *tl_lookup(char *s)
{	
	Symbol *sp;
	int h = hash(s);

	for (sp = symtab[h]; sp; sp = sp->next)
		if (strcmp(sp->name, s) == 0)
			return sp;

	sp = (Symbol *) emalloc(sizeof(Symbol));
	sp->name = (char *) emalloc(strlen(s) + 1);
	strcpy(sp->name, s);
	sp->next = symtab[h];
	sp->set = NullSet;
	symtab[h] = sp;

	return sp;
}

void tl_clearlookup(char *s)
{
	int ii;
	Symbol *sp, *sp_old;
	
	int h = hash(s);

	for (sp = symtab[h], ii=0; sp; sp_old = sp, sp = sp->next, ii++)
		if (strcmp(sp->name, s) == 0)
		{
			if (ii==0)
				symtab[h] = sp->next;
			else
				sp_old->next = sp->next;
			mxFree(sp->name);
			mxFree(sp);
			return;
		}

}


Symbol *getsym(Symbol *s)
{	Symbol *n = (Symbol *) emalloc(sizeof(Symbol));

	n->name = s->name;
	return n;
}

/***** mx_dp_taliro : lex.c *****/

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
#include "param.h"

static int tl_lex(int *, size_t, char *, Miscellaneous *, int *);


#define Token(y)			miscell->tl_yylval = tl_nn(y,ZN,ZN,miscell); return y
#define MetricToken(y)		miscell->tl_yylval = tl_nn(y,ZN,ZN,miscell); miscell->tl_yylval->time = miscell->TimeCon; return y

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

static void getword(int first, int (*tst)(int),int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell)
{	
	int i=0; char c;

	miscell->yytext[i++]= (char ) first;
	while (tst(c = tl_Getchar(cnt, hasuform, uform)))
		miscell->yytext[i++] = c;
	miscell->yytext[i] = '\0';
	tl_UnGetchar(cnt);
}

Number getnumber(char cc, int *cnt, size_t hasuform, char *uform, int *tl_yychar, Miscellaneous *miscell) /* get a number from input string */
{
    /* Peer reviewed on 2013.07.22 by Dokhanchi, Adel */
	int sign = 1;
	int ii = 0; 
	int jj = 0;
	char strnum[80];
	Number num;
	char temp[80];
	int match = 0;

	if (cc=='-')
	{	
		sign = -1;
		do {	
			cc = tl_Getchar(cnt, hasuform, uform);
		} while (cc == ' ');
	}
	else if (cc == '+')
	{	
		do {	
			cc = tl_Getchar(cnt, hasuform, uform); 
		} while (cc == ' ');
	}
	
	if (cc=='i')
	{	cc = tl_Getchar(cnt, hasuform, uform);
		if (cc=='n')
		{	cc = tl_Getchar(cnt, hasuform, uform);
			if (cc=='f')
			{	if (miscell->dp_taliro_param.ConOnSamples)
				{	
					num.numi.inf = sign;
					num.numi.i_num = 0;
       				tl_UnGetchar(cnt);
                   	tl_yyerror("Constraints on the number of samples is not supported by dp_taliro", cnt, uform, tl_yychar, miscell);
                    tl_exit(0);
				}
				else
				{	
					num.numf.inf = sign;
					num.numf.f_num = 0.0;
				}
			}
			else
			{	tl_UnGetchar(cnt);
				tl_yyerror("expected a number or a (-)inf in timing constraints!", cnt, uform, tl_yychar, miscell);
				tl_exit(0);
			}
		}
		else
		{	tl_UnGetchar(cnt);
			tl_yyerror("expected a number or a (-)inf in timing constraints!", cnt, uform, tl_yychar, miscell);
			tl_exit(0);
		}
	}
	else if (('0'<=cc && cc<='9') || cc=='.')
	{
		strnum[ii++] = cc;
		for (cc = tl_Getchar(cnt, hasuform, uform); cc!=' '&& cc!=',' && cc!=']' && cc!=')'; cc = tl_Getchar(cnt, hasuform, uform))
		{ 	
			if (ii>=80)
			{	
				tl_UnGetchar(cnt);
				tl_yyerror("numeric constants must have length less than 80 characters.", cnt, uform, tl_yychar, miscell);
				tl_exit(0);
			}
			strnum[ii++] = cc;
		}
		tl_UnGetchar(cnt);
		strnum[ii] = '\0';
		if (miscell->dp_taliro_param.ConOnSamples)
		{	num.numi.inf = 0;
			num.numi.i_num = sign*atoi(strnum);
     		tl_UnGetchar(cnt);
            tl_yyerror("Constraints on the number of samples is not supported by dp_taliro", cnt, uform, tl_yychar, miscell);
            tl_exit(0);
		}
		else
		{	num.numf.inf = 0;
			num.numf.f_num = (double)sign*atof(strnum);
		}
	}
	else
	{
		temp[jj++] = cc;
		for (cc = tl_Getchar(cnt, hasuform, uform); cc!=' '&& cc!=',' && cc!=']' && cc!=')'; cc = tl_Getchar(cnt, hasuform, uform))
		{ 	
			if (ii>=80)
			{	
				tl_UnGetchar(cnt);
				tl_yyerror("numeric constants must have length less than 80 characters.", cnt, uform, tl_yychar, miscell);
				tl_exit(0);
			}
			temp[jj++] = cc;
		}
		tl_UnGetchar(cnt);
		temp[jj] = '\0';

		for(ii = 0; ii < miscell->dp_taliro_param.nPred; ii++)
		{
			if(miscell->parMap[ii].str != NULL)
			{
				if(strcmp(temp, miscell->parMap[ii].str)==0)
				{
					miscell->parMap[ii].type = miscell->type_temp;
					match = 1;
					miscell->pList.pindex[ii] = PAR;
					if(miscell->parMap[ii].value != NULL)
					{
						miscell->parMap[ii].with_value = true;
						if (miscell->dp_taliro_param.ConOnSamples)
						{
							num.numi.inf = 0;
							num.numi.i_num = sign*(int)(*(miscell->parMap[ii].value));
                            tl_UnGetchar(cnt);
                            tl_yyerror("Constraints on the number of samples is not supported by dp_taliro", cnt, uform, tl_yychar, miscell);
                            tl_exit(0);
						}
						else
						{
							num.numf.inf = 0;
							num.numf.f_num = (double)sign*(*(miscell->parMap[ii].value));
						}
					}
					else
					{
						miscell->parMap[ii].with_value = false;
						if (miscell->dp_taliro_param.ConOnSamples)
						{
							num.numi.inf = 0;
							num.numi.i_num = sign*(int)(miscell->parMap[ii].Range[0]);
                     		tl_UnGetchar(cnt);
                            tl_yyerror("Constraints on the number of samples is not supported by dp_taliro", cnt, uform, tl_yychar, miscell);
                            tl_exit(0);
						}
						else
						{
							num.numf.inf = 0;
							num.numf.f_num = (double)sign*(miscell->parMap[ii].Range[0]);
						}
					}
					if(miscell->lbd)
					{
						miscell->parMap[ii].lbd = true;
					}
					else
					{
						miscell->parMap[ii].lbd = false;
					}
				}
			}
		}
		if(match == 0)
		{
			tl_UnGetchar(cnt);
			tl_yyerror("expected a number or inf or a paramter or parameter not matched", cnt, uform, tl_yychar, miscell);
			tl_exit(0);
		}
	}
	return(num);
}

Interval getbounds(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	
	char cc;
	Interval time;

	/* remove spaces */
	do 
	{	cc = tl_Getchar(cnt, hasuform, uform);
	} while (cc == ' ');
	
	if (cc!='[' && cc!='(')
	{
		tl_UnGetchar(cnt);
		tl_yyerror("expected '(' or '[' after _", cnt, uform, tl_yychar, miscell);
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc=='[')
		time.l_closed = 1;
	else
		time.l_closed = 0;

	/* remove spaces */
	do 
	{	cc = tl_Getchar(cnt, hasuform, uform);
	} while (cc == ' ');
	
	/* get lower bound */
	miscell->lbd = true;
	time.lbd = getnumber(cc, cnt, hasuform, uform, tl_yychar, miscell);
	if (e_le(time.lbd,miscell->zero,&(miscell->dp_taliro_param)))
	{
		tl_UnGetchar(cnt);
		tl_yyerror("past time operators are not allowed - only future time intervals.", cnt, uform, tl_yychar, miscell);
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar(cnt, hasuform, uform);
	} while (cc == ' ');

	if (cc!=',')
	{	
		tl_UnGetchar(cnt);
		tl_yyerror("timing constraints must have the format <num1,num2>.", cnt, uform, tl_yychar, miscell);
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar(cnt, hasuform, uform);
	} while (cc == ' ');

	/* get upper bound */
	miscell->lbd = false;
	time.ubd = getnumber(cc, cnt, hasuform, uform, tl_yychar, miscell);

	if (e_ge(time.lbd,time.ubd,&(miscell->dp_taliro_param)))
	{	tl_UnGetchar(cnt);
		tl_yyerror("timing constraints must have the format <num1,num2> with num1 <= num2.", cnt, uform, tl_yychar, miscell);
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar(cnt, hasuform, uform);
	} while (cc == ' ');

	if (cc!=']' && cc!=')')
	{
		tl_UnGetchar(cnt);
		tl_yyerror("timing constraints must have the format <num1,num2>, where > is from the set {),]}", cnt, uform, tl_yychar, miscell);
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc==']')
		time.u_closed = 1;
	else
		time.u_closed = 0;

	return(time);

}

static int follow(int tok, int ifyes, int ifno, int *cnt, size_t hasuform, char *uform, int *tl_yychar, Miscellaneous *miscell)
{	
	int c;
	char buf[32];

	if ((c = tl_Getchar(cnt, hasuform, uform)) == tok)
		return ifyes;
	tl_UnGetchar(cnt);
	*tl_yychar = c;
	sprintf(buf, "expected '%c'", tok);
	tl_yyerror(buf, cnt, uform, tl_yychar, miscell);	/* no return from here */
	return ifno;
}

static void mtl_con(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{
	char c;
	c = tl_Getchar(cnt, hasuform, uform);
	if (c == '_')
	{
		miscell->dp_taliro_param.LTL = 0;
		miscell->TimeCon = getbounds(cnt, hasuform, uform, miscell, tl_yychar);
	}
	else
	{
		miscell->TimeCon = miscell->zero2inf;
		tl_UnGetchar(cnt);
	}
}

static int mtl_follow(int tok, int ifyes, int ifno, int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	
	int c;
	char buf[32];

	if ((c = tl_Getchar(cnt, hasuform, uform)) == tok)
	{
		miscell->type_temp = ifyes;
		mtl_con(cnt, hasuform, uform, miscell,tl_yychar);
		return ifyes;
	}
	tl_UnGetchar(cnt);
	*tl_yychar = c;
	sprintf(buf, "expected '%c'", tok);
	tl_yyerror(buf, cnt, uform, tl_yychar, miscell);	/* no return from here */
	return ifno;
}

int
tl_yylex(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	int c = tl_lex(cnt, hasuform, uform, miscell, tl_yychar);
#if 0
	printf("c = %d\n", c);
#endif
	return c;
}

static int tl_lex(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar)
{	
	int c,ii;

	do {
		c = tl_Getchar(cnt, hasuform, uform);
		miscell->yytext[0] = (char ) c;
		miscell->yytext[1] = '\0';
		if (c <= 0)
		{	Token(';');
		}
	} while (c == ' ');	/* '\t' is removed in tl_main.c */

	/* get the truth constants true and false and predicates */
	if (islower(c))
	{	getword(c, isalnum_,cnt, hasuform, uform, miscell);
		if (strcmp("true", miscell->yytext) == 0)
		{	Token(TRUE);
		}
		if (strcmp("false", miscell->yytext) == 0)
		{	Token(FALSE);
		}
		miscell->tl_yylval = tl_nn(PREDICATE,ZN,ZN,miscell);
		miscell->type_temp = PREDICATE;
		miscell->tl_yylval->sym = tl_lookup(miscell->yytext, miscell);

		/* match predicate index*/
		for(ii = 0; ii < miscell->dp_taliro_param.nPred; ii++)
		{
			if(miscell->predMap[ii].str != NULL)
			{
				if(strcmp(miscell->tl_yylval->sym->name, miscell->predMap[ii].str)==0)
				{
					miscell->pList.pindex[ii] = PRED;
					miscell->tl_yylval->sym->index = ii+1;
				}
			}
		}

		return PREDICATE;
	}
	/* get temporal operators */
	if (c == '<')
	{	
		c = tl_Getchar(cnt, hasuform, uform);
		if (c == '>') 
		{
			miscell->tl_yylval = tl_nn(EVENTUALLY,ZN,ZN,miscell);
			miscell->type_temp = EVENTUALLY;
			mtl_con(cnt, hasuform, uform, miscell,tl_yychar);
			return EVENTUALLY;
		}
		if (c != '-')
		{	
			tl_UnGetchar(cnt);
			tl_yyerror("expected '<>' or '<->'", cnt, uform, tl_yychar, miscell);
		}
		c = tl_Getchar(cnt, hasuform, uform);
		if (c == '>')
		{	
			Token(EQUIV);
		}
		tl_UnGetchar(cnt);
		tl_yyerror("expected '<->'", cnt, uform, tl_yychar, miscell);
	}

	switch (c) 
	{
		case '/' : 
			c = follow('\\', AND, '/', cnt, hasuform, uform, tl_yychar, miscell); 
			break;
		case '\\': 
			c = follow('/', OR, '\\', cnt, hasuform, uform, tl_yychar, miscell); 
			break;
		case '&' : 
			c = follow('&', AND, '&', cnt, hasuform, uform, tl_yychar, miscell); 
			break;
		case '|' : 
			c = follow('|', OR, '|', cnt, hasuform, uform, tl_yychar, miscell); 
			break;
		case '[' : 
			c = mtl_follow(']', ALWAYS, '[', cnt, hasuform, uform, miscell, tl_yychar); 
			break;
		case '-' : 
			c = follow('>', IMPLIES, '-', cnt, hasuform, uform, tl_yychar, miscell); 
			break;
		case '!' : 
			c = NOT; 
			break;
		case 'U' : 
			miscell->type_temp = U_OPER;
			mtl_con(cnt, hasuform, uform, miscell,tl_yychar);
			c = U_OPER;
			break;
		case 'R' : 
			miscell->type_temp = V_OPER;
			mtl_con(cnt, hasuform, uform, miscell,tl_yychar);
			c = V_OPER;
			break;
		case 'X' : 
			miscell->type_temp = NEXT;
			mtl_con(cnt, hasuform, uform, miscell,tl_yychar);
			c = NEXT;
			break;
		case 'W' : 
			miscell->type_temp = WEAKNEXT;
			mtl_con(cnt, hasuform, uform, miscell, tl_yychar);
			c = WEAKNEXT;
			break;
		default  : break;
	}
	Token(c);
}

Symbol *tl_lookup(char *s, Miscellaneous *miscell)
{	
	Symbol *sp;
	int h = hash(s);

	for (sp = miscell->symtab[h]; sp; sp = sp->next)
		if (strcmp(sp->name, s) == 0)
			return sp;

	sp = (Symbol *) emalloc(sizeof(Symbol));
	sp->name = (char *) emalloc(strlen(s) + 1);
	strcpy(sp->name, s);
	sp->next = miscell->symtab[h];
	sp->set = NullSet;
	miscell->symtab[h] = sp;

	return sp;
}

void tl_clearlookup(char *s, Miscellaneous *miscell)
{
	int ii;
	Symbol *sp, *sp_old;
	
	int h = hash(s);

	for (sp = miscell->symtab[h], ii=0; sp; sp_old = sp, sp = sp->next, ii++)
		if (strcmp(sp->name, s) == 0)
		{
			if (ii==0)
				miscell->symtab[h] = sp->next;
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

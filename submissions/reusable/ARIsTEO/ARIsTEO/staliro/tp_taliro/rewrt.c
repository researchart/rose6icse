/***** ltl2ba : rewrt.c *****/

/* Modified by Georgios Fainekos, ASU, U.S.A.                             */
/* Send bug-reports and/or questions to: fainekos@asu.edu			      */

/* Written by Denis Oddoux, LIAFA, France                                 */
/* Copyright (c) 2001  Denis Oddoux                                       */
/*                                                                        */
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
/*                                                                        */
/* Based on the translation algorithm by Gastin and Oddoux,               */
/* presented at the CAV Conference, held in 2001, Paris, France 2001.     */
/* Send bug-reports and/or questions to: Denis.Oddoux@liafa.jussieu.fr    */
/* or to Denis Oddoux                                                     */
/*       LIAFA, UMR 7089, case 7014                                       */
/*       Universite Paris 7                                               */
/*       2, place Jussieu                                                 */
/*       F-75251 Paris Cedex 05                                           */
/*       FRANCE                                                           */    

/* Some of the code in this file was taken from the Spin software         */
/* Written by Gerard J. Holzmann, Bell Laboratories, U.S.A.               */

#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"


#define BUFF_LEN 4096

Node *right_linked(Node *n)
{
	if (!n) 
		return n;

	if (n->ntyp == AND || n->ntyp == OR)
		while (n->lft && n->lft->ntyp == n->ntyp)
		{	
			Node *tmp = n->lft;
			n->lft = tmp->rgt;
			tmp->rgt = n;
			n = tmp;
		}

	n->lft = right_linked(n->lft);
	n->rgt = right_linked(n->rgt);

	return n;
}

/* assumes input is right_linked */
Node *canonical(Node *n, Miscellaneous *miscell, int *cnt, char *uform , int *tl_yychar)
{	
	Node *m;	

	if (!n) 
		return n;

	if (m = in_cache(n, cnt, uform, tl_yychar, miscell))
		return m;

	n->rgt = canonical(n->rgt, miscell, cnt, uform, tl_yychar);
	n->lft = canonical(n->lft, miscell, cnt, uform, tl_yychar);

	return cached(n, miscell, cnt, uform, tl_yychar);
}

Node *push_negation(Node *n, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
{	
	Node *m;

	Assert(n->ntyp == NOT, n->ntyp);

	switch (n->lft->ntyp) {
	case TRUE:
		releasenode(0, n->lft);
		n->lft = ZN;
		n->ntyp = FALSE;
		break;
	case FALSE:
		releasenode(0, n->lft);
		n->lft = ZN;
		n->ntyp = TRUE;
		break;
	case NOT:
		m = n->lft->lft;
		releasenode(0, n->lft);
		n->lft = ZN;
		releasenode(0, n);
		n = m;
		break;
	case V_OPER:
		n = switchNotTempOper(n,U_OPER, miscell, cnt, uform, tl_yychar);
		break;
	case U_OPER:
		n = switchNotTempOper(n,V_OPER, miscell, cnt, uform, tl_yychar);
		break;
	case NEXT:
		n = switchNotTempOper(n,WEAKNEXT, miscell, cnt, uform, tl_yychar);
		break;
	case WEAKNEXT:
		n = switchNotTempOper(n,NEXT, miscell, cnt, uform, tl_yychar);
		break;
	case  AND:
		n = switchNotTempOper(n,OR, miscell, cnt, uform, tl_yychar);
		break;
	case  OR:
		n = switchNotTempOper(n,AND, miscell, cnt, uform, tl_yychar);
		break;
	}

	return n;
	/* return rewrite(n);
	 do not forget to change this in parse*/
}

Node *switchNotTempOper(Node *n, int ntyp, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
{
	Node *m;

	m = n;
	n = n->lft;
	n->ntyp = ntyp;
	m->lft = n->lft;
	n->lft = push_negation(m, miscell, cnt, uform, tl_yychar);
	if (ntyp!=NEXT && ntyp!=WEAKNEXT)
	{
		n->rgt = Not(n->rgt);
	}
	return(n);
}

static void addcan(int tok, Node *n, Miscellaneous *miscell)
{	Node	*m, *prev = ZN;
	Node	**ptr;
	Node	*N;
	Symbol	*s, *t; int cmp;
	static char	dumpbuf[BUFF_LEN];
	static Node	*can = ZN;

	if (!n) return;

	if (n->ntyp == tok)
	{	addcan(tok, n->rgt, miscell);
		addcan(tok, n->lft, miscell);
		return;
	}
#if 0
	if ((tok == AND && n->ntyp == TRUE)
	||  (tok == OR  && n->ntyp == FALSE))
		return;
#endif
	N = dupnode(n);
	if (!can)	
	{	can = N;
		return;
	}

	s = DoDump(N,dumpbuf, miscell);
	if (can->ntyp != tok)	/* only one element in list so far */
	{	ptr = &can;
		goto insert;
	}

	/* there are at least 2 elements in list */
	prev = ZN;
	for (m = can; m->ntyp == tok && m->rgt; prev = m, m = m->rgt)
	{	t = DoDump(m->lft,dumpbuf, miscell);
		cmp = strcmp(s->name, t->name);
		if (cmp == 0)	/* duplicate */
			return;
		if (cmp < 0)
		{	if (!prev)
			{	can = tl_nn(tok, N, can, miscell);
				return;
			} else
			{	ptr = &(prev->rgt);
				goto insert;
	}	}	}

	/* new entry goes at the end of the list */
	ptr = &(prev->rgt);
insert:
	t = DoDump(*ptr,dumpbuf, miscell);
	cmp = strcmp(s->name, t->name);
	if (cmp == 0)	/* duplicate */
		return;
	if (cmp < 0)
		*ptr = tl_nn(tok, N, *ptr, miscell);
	else
		*ptr = tl_nn(tok, *ptr, N, miscell);
}


static void
marknode(int tok, Node *m)
{
	if (m->ntyp != tok)
	{	releasenode(0, m->rgt);
		m->rgt = ZN;
	}
	m->ntyp = -1;
}

Node *Canonical(Node *n, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
{	Node *m, *p, *k1, *k2, *prev, *dflt = ZN;
	int tok;
	static Node	*can = ZN;


	if (!n) return n;

	tok = n->ntyp;
	if (tok != AND && tok != OR)
		return n;

	can = ZN;
	addcan(tok, n, miscell);
#if 1
	Debug("\nA0: "); Dump(can); 
	Debug("\nA1: "); Dump(n); Debug("\n");
#endif
	releasenode(1, n);

	/* mark redundant nodes */
	if (tok == AND)
	{	for (m = can; m; m = (m->ntyp == AND) ? m->rgt : ZN)
		{	k1 = (m->ntyp == AND) ? m->lft : m;
			if (k1->ntyp == TRUE)
			{	marknode(AND, m);
				dflt = True;
				continue;
			}
			if (k1->ntyp == FALSE)
			{	releasenode(1, can);
				can = False;
				goto out;
		}	}
		for (m = can; m; m = (m->ntyp == AND) ? m->rgt : ZN)
		for (p = can; p; p = (p->ntyp == AND) ? p->rgt : ZN)
		{	if (p == m
			||  p->ntyp == -1
			||  m->ntyp == -1)
				continue;
			k1 = (m->ntyp == AND) ? m->lft : m;
			k2 = (p->ntyp == AND) ? p->lft : p;

			if (isequal(k1, k2, cnt, uform, tl_yychar, miscell))
			{	marknode(AND, p);
				continue;
			}
			if (anywhere(OR, k1, k2, cnt, uform, tl_yychar, miscell))
			{	marknode(AND, p);
				continue;
			}
			if (k2->ntyp == U_OPER
			&&  anywhere(AND, k2->rgt, can, cnt, uform, tl_yychar, miscell))
			{	marknode(AND, p);
				continue;
			}	/* q && (p U q) = q */
	}	}
	if (tok == OR)
	{	for (m = can; m; m = (m->ntyp == OR) ? m->rgt : ZN)
		{	k1 = (m->ntyp == OR) ? m->lft : m;
			if (k1->ntyp == FALSE)
			{	marknode(OR, m);
				dflt = False;
				continue;
			}
			if (k1->ntyp == TRUE)
			{	releasenode(1, can);
				can = True;
				goto out;
		}	}
		for (m = can; m; m = (m->ntyp == OR) ? m->rgt : ZN)
		for (p = can; p; p = (p->ntyp == OR) ? p->rgt : ZN)
		{	if (p == m
			||  p->ntyp == -1
			||  m->ntyp == -1)
				continue;
			k1 = (m->ntyp == OR) ? m->lft : m;
			k2 = (p->ntyp == OR) ? p->lft : p;

			if (isequal(k1, k2, cnt, uform, tl_yychar, miscell))
			{	marknode(OR, p);
				continue;
			}
			if (anywhere(AND, k1, k2, cnt, uform, tl_yychar, miscell))
			{	marknode(OR, p);
				continue;
			}
			if (k2->ntyp == V_OPER
			&&  k2->lft->ntyp == FALSE
			&&  anywhere(AND, k2->rgt, can, cnt, uform, tl_yychar, miscell))
			{	marknode(OR, p);
				continue;
			}	/* p || (F V p) = p */
	}	}
	for (m = can, prev = ZN; m; )	/* remove marked nodes */
	{	if (m->ntyp == -1)
		{	k2 = m->rgt;
			releasenode(0, m);
			if (!prev)
			{	m = can = can->rgt;
			} else
			{	m = prev->rgt = k2;
				/* if deleted the last node in a chain */
				if (!prev->rgt && prev->lft
				&&  (prev->ntyp == AND || prev->ntyp == OR))
				{	k1 = prev->lft;
					prev->ntyp = prev->lft->ntyp;
					prev->sym = prev->lft->sym;
					prev->rgt = prev->lft->rgt;
					prev->lft = prev->lft->lft;
					releasenode(0, k1);
				}
			}
			continue;
		}
		prev = m;
		m = m->rgt;
	}
out:
#if 1
	Debug("A2: "); Dump(can); Debug("\n");
#endif
	if (!can)
	{	if (!dflt)
			fatal("cannot happen, Canonical", (char *) 0, cnt, uform, tl_yychar, miscell);
		return dflt;
	}

	return can;
}

/***** mx_dp_taliro : cache.c *****/
/* Version 1.0				     */

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

/* Some of the code in this file was taken from LTL2BA software           */
/* Written by Denis Oddoux, LIAFA, France					              */
/* Some of the code in this file was taken from the Spin software         */
/* Written by Gerard J. Holzmann, Bell Laboratories, U.S.A.               */

#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"



static int	ismatch(Node *, Node *);
int	sameform(Node *, Node *, int *cnt, char *uform, int *tl_yychar, Miscellaneous *);

void
cache_dump(Miscellaneous *miscell)
{	Cache *d; int nr=0;
	static Cache	*stored = (Cache *) 0;

	printf("\nCACHE DUMP:\n");
	for (d = stored; d; d = d->nxt, nr++)
	{	if (d->same) continue;
		printf("B%3d: ", nr); dump(d->before, miscell); printf("\n");
		printf("A%3d: ", nr); dump(d->after, miscell); printf("\n");
	}
	printf("============\n");
}

Node *in_cache(Node *n, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{	
	Cache *d; int nr=0;
	static Cache	*stored = (Cache *) 0;
	static unsigned long CacheHits;

	for (d = stored; d; d = d->nxt, nr++)
		if (isequal(d->before, n, cnt, uform, tl_yychar, miscell))
		{	CacheHits++;
			if (d->same && ismatch(n, d->before)) return n;
			return dupnode(d->after);
		}
	return ZN;
}

Node *
cached(Node *n, Miscellaneous *miscell, int *cnt, char *uform, int *tl_yychar)
{	Cache *d;
	Node *m;
	static Cache	*stored = (Cache *) 0;
	static unsigned long Caches;


	if (!n) return n;
	if (m = in_cache(n, cnt, uform, tl_yychar, miscell))
		return m;

	Caches++;
	d = (Cache *) emalloc(sizeof(Cache));
	d->before = dupnode(n);
	d->after  = Canonical(n, miscell, cnt, uform, tl_yychar); /* n is released */

	if (ismatch(d->before, d->after))
	{	d->same = 1;
		releasenode(1, d->after);
		d->after = d->before;
	}
	d->nxt = stored;
	stored = d;
	return dupnode(d->after);
}

void
cache_stats(void)
{
	static unsigned long Caches;
	static unsigned long CacheHits;

	printf("cache stores     : %9ld\n", Caches);
	printf("cache hits       : %9ld\n", CacheHits);
}

/* It frees the memory for the node if all_levels=0
   It frees the memory for the tree if all_levels=1 */
void releasenode(int all_levels, Node *n)
{
	if (!n) return;

	if (all_levels)
	{	releasenode(1, n->lft);
		n->lft = ZN;
		releasenode(1, n->rgt);
		n->rgt = ZN;
	}
	mxFree((void *) n); 
}

Node *tl_nn(int t, Node *ll, Node *rl, Miscellaneous *miscell)
{	
	Node *n = (Node *) emalloc(sizeof(Node));

	n->ntyp = (short) t;
	n->rob.ds = 0.0;
	n->rob.dl = 0;
	n->sym = ZS;
	n->time = miscell->emptyInter;
	n->lft  = ll;
	n->rgt  = rl;

	return n;
}

Node *getnode(Node *p)
{	
	Node *n;

	if (!p) return p;

	n =  (Node *) emalloc(sizeof(Node));
	n->ntyp = p->ntyp;
	n->rob = p->rob; 
	n->time = p->time; 
	n->sym  = p->sym; 
	n->lft  = p->lft;
	n->rgt  = p->rgt;

	return n;
}

Node *dupnode(Node *n)
{	
	Node *d;

	if (!n) return n;
	d = getnode(n);
	d->lft = dupnode(n->lft);
	d->rgt = dupnode(n->rgt);
	return d;
}

int
one_lft(int ntyp, Node *x, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!x)  return 1;
	if (!in) return 0;

	if (sameform(x, in, cnt, uform, tl_yychar, miscell))
		return 1;

	if (in->ntyp != ntyp)
		return 0;

	if (one_lft(ntyp, x, in->lft, cnt, uform, tl_yychar, miscell))
		return 1;

	return one_lft(ntyp, x, in->rgt, cnt, uform, tl_yychar, miscell);
}

int
all_lfts(int ntyp, Node *from, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!from) return 1;

	if (from->ntyp != ntyp)
		return one_lft(ntyp, from, in, cnt, uform, tl_yychar, miscell);

	if (!one_lft(ntyp, from->lft, in, cnt, uform, tl_yychar, miscell))
		return 0;

	return all_lfts(ntyp, from->rgt, in, cnt, uform, tl_yychar, miscell);
}

int
sametrees(int ntyp, Node *a, Node *b, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{	/* toplevel is an AND or OR */
	/* both trees are right-linked, but the leafs */
	/* can be in different places in the two trees */

	if (!all_lfts(ntyp, a, b, cnt, uform, tl_yychar, miscell))
		return 0;

	return all_lfts(ntyp, b, a, cnt, uform, tl_yychar, miscell);
}

int	/* a better isequal() */
sameform(Node *a, Node *b, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!a && !b) return 1;
	if (!a || !b) return 0;
	if (a->ntyp != b->ntyp) return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	switch (a->ntyp) {
	case TRUE:
	case FALSE:
		return 1;
	case PREDICATE:
		if (!a->sym || !b->sym) fatal("sameform...", (char *) 0, cnt, uform, tl_yychar, miscell);
		return !strcmp(a->sym->name, b->sym->name);

	case NOT:
	case NEXT:
		return sameform(a->lft, b->lft, cnt, uform, tl_yychar, miscell);
	case U_OPER:
	case V_OPER:
		if (!sameform(a->lft, b->lft, cnt, uform, tl_yychar, miscell))
			return 0;
		if (!sameform(a->rgt, b->rgt, cnt, uform, tl_yychar, miscell))
			return 0;
		return 1;

	case AND:
	case OR:	/* the hard case */
		return sametrees(a->ntyp, a, b, cnt, uform, tl_yychar, miscell);

	default:
		printf("type: %d\n", a->ntyp);
		fatal("cannot happen, sameform", (char *) 0, cnt, uform, tl_yychar, miscell);
	}

	return 0;
}

int
isequal(Node *a, Node *b, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!a && !b)
		return 1;

	if (!a || !b)
	{	if (!a)
		{	if (b->ntyp == TRUE)
				return 1;
		} else
		{	if (a->ntyp == TRUE)
				return 1;
		}
		return 0;
	}
	if (a->ntyp != b->ntyp)
		return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	if (isequal(a->lft, b->lft, cnt, uform, tl_yychar, miscell)
	&&  isequal(a->rgt, b->rgt, cnt, uform, tl_yychar, miscell))
		return 1;

	return sameform(a, b, cnt, uform, tl_yychar, miscell);
}

static int
ismatch(Node *a, Node *b)
{
	if (!a && !b) return 1;
	if (!a || !b) return 0;
	if (a->ntyp != b->ntyp) return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	if (ismatch(a->lft, b->lft)
	&&  ismatch(a->rgt, b->rgt))
		return 1;

	return 0;
}

int
any_term(Node *srch, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!in) return 0;

	if (in->ntyp == AND)
		return	any_term(srch, in->lft, cnt, uform, tl_yychar, miscell) ||
			any_term(srch, in->rgt, cnt, uform, tl_yychar, miscell);

	return isequal(in, srch, cnt, uform, tl_yychar, miscell);
}

int
any_and(Node *srch, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!in) return 0;

	if (srch->ntyp == AND)
		return	any_and(srch->lft, in, cnt, uform, tl_yychar, miscell) &&
			any_and(srch->rgt, in, cnt, uform, tl_yychar, miscell);

	return any_term(srch, in, cnt, uform, tl_yychar, miscell);
}

int
any_lor(Node *srch, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!in) return 0;

	if (in->ntyp == OR)
		return	any_lor(srch, in->lft, cnt, uform, tl_yychar, miscell) ||
			any_lor(srch, in->rgt, cnt, uform, tl_yychar, miscell);

	return isequal(in, srch, cnt, uform, tl_yychar, miscell);
}

int
anywhere(int tok, Node *srch, Node *in, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	if (!in) return 0;

	switch (tok) {
	case AND:	return any_and(srch, in, cnt, uform, tl_yychar, miscell);
	case  OR:	return any_lor(srch, in, cnt, uform, tl_yychar, miscell);
	case   0:	return any_term(srch, in, cnt, uform, tl_yychar, miscell);
	}
	fatal("cannot happen, anywhere", (char *) 0, cnt, uform, tl_yychar, miscell);
	return 0;
}

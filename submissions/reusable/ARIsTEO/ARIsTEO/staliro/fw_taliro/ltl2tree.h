/***** mx_fw_taliro : ltl2tree.h *****/

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

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

typedef struct Symbol {
	char *name;
	ConvSet *set;
	struct Symbol *next;	/* linked list, symbol table */
} Symbol;

#define NullSymbol (Symbol *)0

typedef union {
	struct {
		int inf;
	} num;
	struct {
		int inf;
		double f_num;
	} numf;
	struct {
		int inf;
		int i_num;
	} numi;
} Number;

typedef struct {
	Number lbd;
	int l_closed;
	Number ubd;
	int u_closed;
} Interval;

typedef struct Node {
	short ntyp;	/* node type */
	HyDis rob; /* robustness */
	Interval time; /* lower and upper real time bounds */
	struct Symbol *sym;
	struct Node	*lft;	/* tree */
	struct Node	*rgt;	/* tree */
	struct Node	*nxt;	/* if linked list */
} Node;

enum {
	ALWAYS=257,
	AND,		/* 258 */
	EQUIV,		/* 259 */
	EVENTUALLY,	/* 260 */
	FALSE,		/* 261 */
	IMPLIES,	/* 262 */
	NOT,		/* 263 */
	OR,			/* 264 */
	PREDICATE,	/* 265 */
	TRUE,		/* 266 */
	U_OPER,		/* 267 */
	V_OPER,		/* 268 */
	NEXT,		/* 269 */
	VALUE,		/* 270 */
	WEAKNEXT,	/* 271 */
	U_MOD,		/* 272 */
	V_MOD		/* 273 */
};

Node	*Canonical(Node *);
Node	*canonical(Node *);
Node	*cached(Node *);
Node	*dupnode(Node *);
Node	*getnode(Node *);
Node	*in_cache(Node *);
Node	*push_negation(Node *);
Node	*switchNotTempOper(Node *n, int ntyp);
Node	*right_linked(Node *);
Node	*tl_nn(int, Node *, Node *);

Symbol	*tl_lookup(char *);
void	tl_clearlookup(char *);
Symbol	*getsym(Symbol *);
Symbol	*DoDump(Node *);

char	*emalloc(size_t);	

int	anywhere(int, Node *, Node *);
int	dump_cond(Node *, Node *, int);
int	isequal(Node *, Node *);
int	tl_Getchar(void);

static void	non_fatal(char *, char *);

void	cache_stats(void);
void	dump(Node *);
void	Fatal(char *, char *);
void	fatal(char *, char *);
void	fsm_print(void);
void	releasenode(int, Node *);
void	tl_explain(int);
void	tl_UnGetchar(void);
Node	*tl_parse(void);
void	tl_yyerror(char *);
void	trans(Node *);

#define ZN	(Node *)0
#define ZS	(Symbol *)0
#define Nhash	255    	
#define True	tl_nn(TRUE,  ZN, ZN)
#define False	tl_nn(FALSE, ZN, ZN)
#define Not(a)	push_negation(tl_nn(NOT, a, ZN))
#define rewrite(n)	canonical(right_linked(n))

typedef Node	*Nodeptr;
#define YYSTYPE	 Nodeptr

#define Debug(x)	{ if (0) printf(x); }
#define Debug2(x,y)	{ if (tl_verbose) printf(x,y); }
#define Dump(x)		{ if (0) dump(x); }
#define Explain(x)	{ if (tl_verbose) tl_explain(x); }

#define Assert(x, y)	{ if (!(x)) { tl_explain(y); \
			  Fatal(": assertion failed\n",(char *)0); } }
#define min(a,b)    (((a) < (b)) ? (a) : (b))

void put_uform(void);

void tl_exit(int i);


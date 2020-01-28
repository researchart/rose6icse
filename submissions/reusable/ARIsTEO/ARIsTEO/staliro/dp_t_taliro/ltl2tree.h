/***** mx_dp_taliro : ltl2tree.h *****/

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

typedef struct Symbol {
	char *name;
	ConvSet *set;
	struct Symbol *next;	/* linked list, symbol table */
	int index;
} Symbol;

typedef struct {
	int LTL;			/* Is this an LTL formula */
	int ConOnSamples;	/* Are the constraints on the actual time or the # of samples? */
	mwSize SysDim; /* System dimension */
	mwSize nSamp;  /* Number of Samples */
	size_t nPred;  /* Number of Predicates */
	size_t true_nPred;  /* Number of Predicates */
	mwSize tnLoc;  /* total number of control locations */
	int nInp;	   /* Number of inputs to mx_dp_taliro */
	int ParON;		/* Indicator if parameter is used */
} FWTaliroParam;


#define NullSymbol (Symbol *)0

typedef struct queue{

	int i;
    struct Node *first;
    struct Node *last;
}queue;


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

typedef struct {
	int last_v;
	int past_v;
} Verdict;				/* used for time robustness state representation*/


typedef struct Node {
	/* Peer reviewed on 2013.06.28 by Dokhanchi, Adel */
    short ntyp;	/* node type */
    int visited;
    int index;
	int LBound;
	int UBound;
	int LBound_nxt;
	int BoundCheck;
	int UBindicator;
	int LBindicator;
	int LBindicator_nxt;
	int loop_end;
	HyDis rob; /* robustness */
	HyDis rob_sec; /* robustness_last */
	Interval time; /* lower and upper real time bounds */
	struct Symbol *sym;
	struct Node	*lft;	/* tree */
	struct Node	*rgt;	/* tree */
	struct Node	*nxt;	/* if linked list */
	int inSet;
	Verdict verdict;
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
	V_MOD,		/* 273 */
	POSITIVE_POLAR = 1,
	NEGATIVE_POLAR = -1,
	MIXED_POLAR = 0,
	UNDEFINED_POLAR = 2,
	PRED = 1,
	PAR = 2,
	PREDPAR = 3
};

typedef Node	*Nodeptr;
#define YYSTYPE	 Nodeptr
#define Nhash	255    	

typedef struct Cache {
	Node *before;
	Node *after;
	int same;
	struct Cache *nxt;
} Cache;

typedef struct {
	char *str;
	ConvSet set;
	bool true_pred;
	double *Range;
} PMap;

typedef struct {
	char *str;
	double *value;
	int index;
	double *Range;
	bool lbd;
	int type;
	bool with_value;
} ParMap;

typedef struct {
    /* Peer reviewed on 2013.07.22 by Dokhanchi, Adel */
	int *pindex;
	size_t total;
	int used;
}PredList;

typedef struct {
	int polar;
} Polarity;

typedef struct {
	Number zero;
	Number inf;
	Interval zero2inf;
	Interval emptyInter;
	Interval TimeCon;
	YYSTYPE	tl_yylval;
	FWTaliroParam dp_taliro_param;
	int	tl_errs;
	FILE *tl_out;
	char	yytext[2048];
	Symbol *symtab[Nhash+1];
	ParMap *parMap;
	PMap *predMap; 
	PredList pList;
	bool lbd;
	int type_temp;
} Miscellaneous;


Node	*Canonical(Node *, Miscellaneous *, int *, char *, int *);
Node	*canonical(Node *, Miscellaneous *, int *, char *, int *);
Node	*cached(Node *, Miscellaneous *, int *, char *, int *);
Node	*dupnode(Node *);
Node	*getnode(Node *);
Node	*in_cache(Node *, int *, char *, int *, Miscellaneous *);
Node	*push_negation(Node *, Miscellaneous *, int *, char *, int *);
Node	*switchNotTempOper(Node *n, int ntyp, Miscellaneous *, int *cnt, char *uform, int *tl_yychar);
Node	*right_linked(Node *);
Node	*tl_nn(int, Node *, Node *, Miscellaneous *);

Symbol	*tl_lookup(char *, Miscellaneous *miscell);
void	tl_clearlookup(char *, Miscellaneous *miscell);
Symbol	*getsym(Symbol *);
Symbol	*DoDump(Node *, char *, Miscellaneous *miscell);

char	*emalloc(size_t);	

int	anywhere(int, Node *, Node *, int *, char *, int *, Miscellaneous *);
int	dump_cond(Node *, Node *, int);
int	isequal(Node *, Node *, int *, char *, int *, Miscellaneous *);
int	tl_Getchar(int *cnt, size_t hasuform, char *uform);

static void	non_fatal(char *, char *, int *, char *, int *, Miscellaneous *);

void	cache_stats(void);
void	dump(Node *, Miscellaneous *);
void	Fatal(char *, char *, int *, char *, int *, Miscellaneous *);
void	fatal(char *, char *, int *, char *, int *, Miscellaneous *);
void	fsm_print(void);
void	releasenode(int, Node *);
void	tl_explain(int);
void	tl_UnGetchar(int *cnt);
Node	*tl_parse(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *);
void	tl_yyerror(char *s1, int *cnt, char *uform, int *, Miscellaneous *);
void	trans(Node *);

int	tl_yylex(int *cnt, size_t hasuform, char *uform, Miscellaneous *miscell, int *tl_yychar);
void	fatal(char *, char *, int *, char *, int *, Miscellaneous *);

#define ZN	(Node *)0
#define ZS	(Symbol *)0




#define True	tl_nn(TRUE,  ZN, ZN, miscell)
#define False	tl_nn(FALSE, ZN, ZN, miscell)
#define Not(a)	push_negation(tl_nn(NOT, a, ZN, miscell), miscell, cnt, uform, tl_yychar)
#define rewrite(n)	canonical(right_linked(n), miscell, cnt, uform, tl_yychar)


#define Debug(x)	{ if (0) printf(x); }
#define Debug2(x,y)	{ if (tl_verbose) printf(x,y); }
#define Dump(x)		{ if (0) dump(x, miscell); }
#define Explain(x)	{ if (tl_verbose) tl_explain(x); }

#define Assert(x, y)	{ if (!(x)) { tl_explain(y); \
			  Fatal(": assertion failed\n",(char *)0, cnt, uform, tl_yychar, miscell); } }
#define min(a,b)    (((a) < (b)) ? (a) : (b))

void put_uform(char *uform, Miscellaneous *);

void tl_exit(int i);


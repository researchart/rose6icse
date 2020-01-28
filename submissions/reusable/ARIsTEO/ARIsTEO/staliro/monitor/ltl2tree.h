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
#include <ctype.h>


/* Convex set */
typedef struct {
	int Dim;  /* false: 1D Interval, true: higher dimensional set */
	int idx;  /* Predicate index in the predicate map*/
	int *proj; /* the projected dimension in a higher dimensional space*/
	int nproj; /* the number of projected components*/
	double *loc;  /* locations in the H.A.*/
	int nloc; /* number of locations (0 implies any location)*/
	/* 2D set and higher */
	bool isSetRn; /* true means that the set is R^n (indicated by an empty A as input)*/
	int ncon;	/* number of constraints*/
	double **A; /* constraint : A*x<=b */
	double *b;  /**/
	/* Interval {lb,ub} where { is [ or ( and } is ] or ) */
	double lb;	/* lower bound*/
	double ub;  /* upper bound*/
	int lbcl;  /* if lbcl is 1 then [ otherwise, i.e., 0, (*/
	int ubcl;  /* if upcl is 1 then ] otherwise, i.e., 0, )*/
} ConvSet;

/* Convex set for Guard sets*/
typedef struct {
	int nset;  /* number of sets*/
	int *ncon;	/* number of constraints*/
	double ***A; /* constraint : A*x<=b */
	double **b;  
} GuardSet;


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

/* Hybrid distance (robustness) */
typedef struct {
	int dl;
	double ds;
} HyDis;


typedef struct Node {
	int ntyp;	/* node type */
    int visited;
    int past;
    int index;
    int Lindex;
    int Rindex;
	int LBound;
	int UBound;
    int FiniteHorizon;
    int History;
	HyDis rob; /* robustness */
	Interval time; /* lower and upper real time bounds */
	struct Symbol *sym;
	struct Node	*lft;	/* tree */
	struct Node	*rgt;	/* tree */
	struct Node	*nxt;	/* if linked list */
} Node;


typedef struct queue{
	int i;
    struct Node *first;
    struct Node *last;
}queue;



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
	S_OPER,		/* 274 */
	T_OPER,		/* 275 */
	PREV,		/* 276 */
	WEAKPREV,	/* 277 */
	EVENTUALLY_PAST,/* 278 */
	ALWAYS_PAST/* 279 */
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

int tl_yylex(void) ;
int isalnum_(int c);
static int tl_lex(void);
static int ismatch(Node *a, Node *b);
int	sameform(Node *a, Node *b);

Symbol	*tl_lookup(char *);
void	tl_clearlookup(char *);
Symbol	*getsym(Symbol *);
Symbol	*DoDump(Node *);


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

/*================================*/
/*#define emalloc(n) { malloc(n); }*/
/*================================*/

#define Assert(x, y)	{ if (!(x)) { tl_explain(y); \
			  Fatal(": assertion failed\n",(char *)0); } }
#define min(a,b)    (((a) < (b)) ? (a) : (b))

void put_uform(void);

void tl_exit(int i);


/***** mx_fw_taliro : monitor.h *****/

typedef struct {
	char *str;
	ConvSet set;
} PMap;

typedef struct {
	int LTL;			/* Is this an LTL formula */
	int ConOnSamples;	/* Are the constraints on the actual time or the # of samples? */
	mwSize SysDim; /* System dimension */
	mwSize nSamp;  /* Number of Samples */
	size_t nPred;  /* Number of Predicates */
	mwSize tnLoc;  /* total number of control locations */
	int szInp;	   /* Size of the input to monitor */
    int  predictorHorizon; 
} FWTaliroParam;


#define max(a, b)  (((a) > (b)) ? (a) : (b)) 

HyDis hmax(HyDis inp1, HyDis inp2);
HyDis hmin(HyDis inp1, HyDis inp2);


 typedef struct {
 	double *LDist; 	/* distance between current control location and predicate locations on the hybrid automaton graph */
    GuardSet **GuardMap; /* the maps for the guard sets */
 	double **AdjL; /* Adjacency list for control locations */
 	size_t *AdjLNell; /* number of neigbors of each control location */
 } DistCompData;


/* TL formula manipulation */
void moveNode2to1(Node **pt_node1, Node *node2);
void moveNodeFromLeft(Node **node);
void moveNodeFromRight(Node **node);
Node *SimplifyNodeValue(Node *node);
/* Node *SimplifyBoolConn(int BCon, Node *node, void (*MoveNodeL)(Node **), void (*MoveNodeR)(Node **), double (*Comparison)(double,double)); */
Node *SimplifyBoolConn(int BCon, Node *node, void (*MoveNodeL)(Node **), void (*MoveNodeR)(Node **), HyDis (*Comparison)(HyDis,HyDis));
Node *NextOperator(Node *phi, int Nxt, Number dt, char last, FWTaliroParam *p_par);
Node *TempOperator(Node *phi, int Until, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par);

/* Timing constraints */
Interval NumberPlusInter(Number num, Interval inter);
int e_le(Number num1, Number num2, FWTaliroParam *p_par);
int e_eq(Number num1, Number num2, FWTaliroParam *p_par);
int e_leq(Number num1, Number num2, FWTaliroParam *p_par);
int e_ge(Number num1, Number num2, FWTaliroParam *p_par);
int e_geq(Number num1, Number num2, FWTaliroParam *p_par);


/***** mx_fw_taliro : distances.h *****/




/* xx: current state vector (xx[dim] is the current location, 
   SS: convex set, dim: dimension of xx
   LDist: array of location distances (current location to predicate location)
   p_distdat: pointer to all the data needed in hybrid metrics
   tnLoc: total number of control locations in the hybrid automaton */
/* Hybrid distance computation without taking into account distance from guard sets */

HyDis SignedHDist0(double *xx, ConvSet *SS, int dim, double *LDist, mwSize tnloc);
 
/* Hybrid distance computation that takes into account distance from guard sets */
HyDis SignedHDistG(double *xx, ConvSet *SS, int dim, DistCompData *p_distdat, mwSize tnloc);

double SignedDist(double *xx, ConvSet *SS, int dim);
int isPointInConvSet(double *xx, ConvSet *SS, int dim);
double inner_prod(double *vec1, double *vec2, int dim);
double norm(double *vec, int dim);
void vec_scl(double *vec0, double scl, double *vec1, int dim);
void vec_add(double* vec0, double *vec1, double *vec2, int dim);

#define dmin(a, b)  (((a) < (b)) ? (a) : (b)) 
#define NullSet (ConvSet *)0

    
/* Variables needed for monitor */

FILE *tl_out;

/* Default parameters */
#define BUFF_LEN 4096
FWTaliroParam fw_taliro_param = {1, 0, 0, 0, 0, 0, 0}; 

/* Global variables */
Number zero, inf;
Interval emptyInter;
Interval zero2inf;

typedef struct {
    Node *node;
    HyDis **RobTable;
    HyDis  lastRobustness;
    HyDis  *pre;
    double  *tS;/*Time Stamp*/
    Node **subformula;				/* subformula array as a cross-reference for the phi*/
    mxArray *MTLformula;
    mxArray *ObservationMap;
 	double *XTrace, *TStamps, *LTrace;
 	DistCompData distData;
 	PMap *predMap; 
	int SampleNum;
    int phi_size,FH,History;
    int Globally;
    int Prediction;
    int iHst;
} Miscellaneous;

int tl_simp_log  = 0; /* logical simplification */
int	tl_errs      = 0;
int	tl_verbose   = 0;
int	tl_terse     = 0;

/* temporal logic formula 
 static char	uform[BUFF_LEN];
 static size_t hasuform=0;
 static int cnt;
char	uform[BUFF_LEN];*/
char	*uform;
/*char	yytext[2048];*/
char	*yytext;
/*char	dumpbuf[BUFF_LEN];*/
char	*dumpbuf;


size_t hasuform=0;
int cnt;

int	tl_yychar = 0;
YYSTYPE	tl_yylval;
Interval TimeCon;



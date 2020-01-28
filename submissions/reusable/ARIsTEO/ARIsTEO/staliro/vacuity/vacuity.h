/***** mx_debugging : vacuity.h *****/

/* Written by Adel Dokhanchi, ASU, U.S.A.                              */
/* Copyright (c) 2017  Georgios Fainekos								  */
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
	int nInp;	   /* Number of inputs to mx_fw_taliro */
} FWTaliroParam;

mxArray *monitor(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *param);

Node *ProgRob(Node *phi, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par);

#define max(a, b)  (((a) > (b)) ? (a) : (b)) 

HyDis hmax(HyDis inp1, HyDis inp2);
HyDis hmin(HyDis inp1, HyDis inp2);

void moveNode2to1(Node **pt_node1, Node *node2);
void moveNodeFromLeft(Node **node);
void moveNodeFromRight(Node **node);
Node *SimplifyNodeValue(Node *node);

Node *SimplifyBoolConn(int BCon, Node *node, void (*MoveNodeL)(Node **), void (*MoveNodeR)(Node **), HyDis (*Comparison)(HyDis,HyDis));
Node *NextOperator(Node *phi, int Nxt, Number dt, char last, FWTaliroParam *p_par);
Node *TempOperator(Node *phi, int Until, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par);

Interval NumberPlusInter(Number num, Interval inter);
int e_le(Number num1, Number num2, FWTaliroParam *p_par);
int e_eq(Number num1, Number num2, FWTaliroParam *p_par);
int e_leq(Number num1, Number num2, FWTaliroParam *p_par);
int e_ge(Number num1, Number num2, FWTaliroParam *p_par);
int e_geq(Number num1, Number num2, FWTaliroParam *p_par);

void mtl2qtl(Node *phi);
void countLiterals(Node *phi);
int changeLiteral(Node *phi,int litIndex,Node *falseNode);
void findConjuncts(Node *phi,Node **conjNodes);
void mtl_print(Node *phi);
void countAntecedent(Node *phi);
void mtl2str(Node *phi);
void findIntervals(Node *phi,Interval bounds);
void extractAntecedent(Node *phi,int antcdIndex);

void mtl2str(Node *phi);
void countConjunctions(Node *phi);
void mtl2strI(Node *phi);
void mtl2ltl(Node *phi);
int checkSingleTemporal();

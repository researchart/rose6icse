/***** mx_fw_taliro : monitor.h *****/

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

/* 	monitor (forward TL evaluation algorithm) inputs: 
	phi: TL formula, predMap: Predicate map, XTrace: State trace, TStamps: Time Stamps, 
	LTrace: Location Trace (for signals from hybrid automata), 
	fw_taliro_param: various parameters */
mxArray *monitor(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *param);

/* ProgRob inputs: 
   phi: TL formula, xx: current signal value, 
   pct: pointer to current time, pdt: pointer to time step (Next time - Current time),
   plast: is this the last sample? 
   p_par: fw_taliro options */
Node *ProgRob(Node *phi, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par);

#define max(a, b)  (((a) > (b)) ? (a) : (b)) 

/* Hybrid Distance (robustness) */
HyDis hmax(HyDis inp1, HyDis inp2);
HyDis hmin(HyDis inp1, HyDis inp2);

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


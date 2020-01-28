/***** mx_dp_taliro : param.h *****/

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


/* 	monitor (forward TL evaluation algorithm) inputs: 
	phi: TL formula, predMap: Predicate map, XTrace: State trace, TStamps: Time Stamps, 
	LTrace: Location Trace (for signals from hybrid automata), 
	dp_taliro_param: various parameters */

int enqueue(struct queue *q, Node *phi);
Node *popfront(struct queue *q);
int dequeue(struct queue *q);
void init_queue(struct queue *q);
int queue_empty_p(const struct queue *q);
int BreadthFirstTraversal(struct queue *q, Node *root,Node *subformula[],int *qi);
mxArray *DynamicProgramming(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *param, Miscellaneous *miscell);

void DPRob(Node *subformula[], double *next, double *now, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par, int jjj, int ii, int jj, Number *CurTime, HyDis *TempL, HyDis *TempR, HyDis **TempPredRob);
void DPRob_forward(Node *subformula[], double *next, double *now, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par, int jjj, int ii, int jj, Number *CurTime, HyDis *TempL, HyDis *TempR, HyDis **TempPredRob);
double future_operator(Number *CurTime, int ii, Node *subformula, double last_timerob, double current_rob);
void compute_predicate(Node *subformula[], double *xx, DistCompData *p_distData, FWTaliroParam *p_par, int iii, int ii, HyDis *rob, HyDis *rob_nxt, Number *CurTime, HyDis **TempPredRob);
void compute_predicate_forward(Node *subformula[], double *xx, DistCompData *p_distData, FWTaliroParam *p_par, int iii, int ii, HyDis *rob, HyDis *rob_nxt, Number *CurTime);

/* ProgRob inputs: 
   phi: TL formula, xx: current signal value, 
   pct: pointer to current time, pdt: pointer to time step (Next time - Current time),
   plast: is this the last sample? 
   p_par: dp_taliro options */

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

/* Timing constraints */
Interval NumberPlusInter(Number num, Interval inter);
int e_le(Number num1, Number num2, FWTaliroParam *p_par);
int e_eq(Number num1, Number num2, FWTaliroParam *p_par);
int e_leq(Number num1, Number num2, FWTaliroParam *p_par);
int e_ge(Number num1, Number num2, FWTaliroParam *p_par);
int e_geq(Number num1, Number num2, FWTaliroParam *p_par);


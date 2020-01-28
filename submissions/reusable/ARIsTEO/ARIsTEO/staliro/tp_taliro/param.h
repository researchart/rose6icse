/***** mx_tp_taliro : param.h *****/

/* Written by Georgios Fainekos, ASU, U.S.A.                              */
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



int enqueue(struct queue *q, Node *phi);
Node *popfront(struct queue *q);
int dequeue(struct queue *q);
void init_queue(struct queue *q);
int queue_empty_p(const struct queue *q);
mxArray *DP(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *param, Miscellaneous *miscell);


#define max(a, b)  (((a) > (b)) ? (a) : (b)) 

/* Hybrid Distance (robustness) */
HyDis hmax(HyDis inp1, HyDis inp2);
HyDis hmin(HyDis inp1, HyDis inp2);

/* TL formula manipulation */
void moveNode2to1(Node **pt_node1, Node *node2);
void moveNodeFromLeft(Node **node);
void moveNodeFromRight(Node **node);
Node *SimplifyNodeValue(Node *node);
Node *SimplifyBoolConn(int BCon, Node *node, void (*MoveNodeL)(Node **), void (*MoveNodeR)(Node **), HyDis (*Comparison)(HyDis,HyDis));

/* Timing constraints */
Interval NumberPlusInter(Number num, Interval inter);
int e_le(Number num1, Number num2, FWTaliroParam *p_par);
int e_eq(Number num1, Number num2, FWTaliroParam *p_par);
int e_leq(Number num1, Number num2, FWTaliroParam *p_par);
int e_ge(Number num1, Number num2, FWTaliroParam *p_par);
int e_geq(Number num1, Number num2, FWTaliroParam *p_par);


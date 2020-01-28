/***** mx_fw_taliro : distances.h *****/
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

/* Last modifid by Hengyi Yang 5/3/2012									  */


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

typedef struct {
	double *LDist; 	/* distance between current control location and predicate locations on the hybrid automaton graph */
    GuardSet **GuardMap; /* the maps for the guard sets */
	double **AdjL; /* Adjacency list for control locations */
	size_t *AdjLNell; /* number of neigbors of each control location */
} DistCompData;

/* Hybrid distance (robustness) */
typedef struct {
	int dl;
	double ds;
} HyDis;

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

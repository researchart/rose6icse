/***** mx_dp_taliro : DynamicProgramming.c *****/

/* Written by Hengyi Yang, Adel Dokhanchi, ASU, U.S.A. for dp_taliro      */
/* Copyright (c) 2012  Hengyi Yang								          */
/* Copyright (c) 2013  Adel Dokhanchi							          */

/* Some of the code in this file was taken from fw_taliro software        */
/* Written by Georgios Fainekos, ASU, U.S.A.                              */
/* Copyright (c) 2011  Georgios Fainekos								  */
/* Send bug-reports and/or questions to: fainekos@gmail.com			      */

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





#include <time.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "param.h"
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

#define intMax32bit 2147483647

/* 
compute predicate is used when during the dynamic programming process the type of subformula is 'Predicate'
it calls different functions in distances accroding to number of inputs	

*/

HyDis  SetToInf(int sign,int iter){
	HyDis   temp;
	double infval = mxGetInf();	
	if( sign == -1 ){
		temp.dl= -infval;
		temp.ds= -infval;
	}
	else{
		temp.dl= infval;
		temp.ds= infval;
	}
	temp.iteration=iter;
	temp.preindex=-1;
	temp.HAindex = 0;
	temp.headLocation = 0;
	temp.tailLocation = 0;

	return  temp;
}
int imax(int a, int b)
{
	return(((a) > (b)) ? (a) : (b));
}
int imin(int a, int b)
{
	return(((a) < (b)) ? (a) : (b));
}

/* Saturate and normalize a scalar to the interval [-1,1] */
/* x : scalar value to be scaled */
/* bd : positive bound for scaling and normalizing */
/* I.e., saturate values to [-bd,bd] and map the interval [-bd,bd] to [-1,1] */
double Normalize(double x, double bd)
{
	if (x > bd)
	{
		return(1.0);
	}
	else if (x < -bd)
	{
		return(-1.0);
	}
	else
	{
		return(x/bd);
	}
}

/* Saturate and normalize a hybrid value (l,s) to the interval [-1,1] */
/* x : hybrid value to be scaled */
/* bd_s : positive bound for scaling and normalizing the euclidean component */
/* bd_l : positive bound for scaling and normalizing the discrete component */
/* I.e., saturate values and map [-bd_l,bd_l]x[-bd,bd] to [-1,1] */
HyDis NormalizeHybrid(HyDis x, double bd_l, double bd_s)
{
	x.ds = Normalize(x.ds, bd_s);
	x.ds = Normalize(x.dl + x.ds, bd_l+1);
	x.dl = 0;
	return(x);
}

void compute_predicate(Node *subformula[], double *xx, DistCompData *p_distData, FWTaliroParam *p_par, int iii, int ii, HyDis *rob) 
{
    int i;
    double infval = mxGetInf();
	HyDis  robustness;
    HyDis  *robHA;

    if (!subformula[iii]->sym->set)
	{
		mexPrintf("%s%s\n", "Predicate: ", subformula[iii]->sym->name);
		mexErrMsgTxt("mx_dp_taliro: The set for the above predicate has not been defined!\n");
	}
	if ((p_par->nInp==6) && (subformula[iii]->sym->set->nloc>0))
	{
		*rob = SignedHDist0(xx,subformula[iii]->sym->set,p_par->SysDim,p_distData->LDist,p_par->tnLoc);
		rob->iteration = ii;
		rob->preindex = subformula[iii]->sym->index;
		if (subformula[iii]->sym->Normalized)
		{
			*rob = NormalizeHybrid(*rob, subformula[iii]->sym->NormBounds[1], subformula[iii]->sym->NormBounds[0]);
		}
	}
	else if ((p_par->nInp==8) && (subformula[iii]->sym->set->nloc>0))
	{
		*rob = SignedHDistG(xx,subformula[iii]->sym->set,p_par->SysDim,p_distData,p_par->tnLoc);
		rob->iteration = ii;
		rob->preindex = subformula[iii]->sym->index;
		if (subformula[iii]->sym->Normalized)
		{
			*rob = NormalizeHybrid(*rob, subformula[iii]->sym->NormBounds[1], subformula[iii]->sym->NormBounds[0]);
		}
               
	}
    else  if ((p_par->nInp==8) && (subformula[iii]->sym->set->nloc==0) && (p_par->nCLG>=1)) /*used for multiple H.A.s*/
	{
        robHA=(HyDis *)emalloc((p_par->nCLG)*sizeof(HyDis));
        for(i=0;i<p_par->nCLG;i++){
			if (subformula[iii]->sym->set->nlocNCLG[i] == 0){
				robustness.ds = SignedDist(xx, subformula[iii]->sym->set, p_par->SysDim);
				robustness.dl = 0;
				robustness.headLocation = 0;
				robustness.tailLocation = 0;
			}
			else
			{
				robustness=SignedHDistGNCLG(xx,subformula[iii]->sym->set,p_par->SysDim,p_distData,p_par->tnLocNCLG[i],i);
			}
			robustness.HAindex=i+1;
            robHA[i]=robustness;
        }
        robustness=SetToInf(+1,ii);/*we use minimum because hybrid distance is negative when it is not in the desired location*/
        for(i=0;i<p_par->nCLG;i++){
            robustness=hmin(robustness,robHA[i]);
        }
        rob->ds=robustness.ds;
        rob->dl=robustness.dl;
		rob->iteration = ii;
		rob->preindex = subformula[iii]->sym->index;
        rob->HAindex=robustness.HAindex;
        rob->headLocation=robustness.headLocation;
        rob->tailLocation=robustness.tailLocation;
		if (subformula[iii]->sym->Normalized)
		{
			*rob = NormalizeHybrid(*rob, subformula[iii]->sym->NormBounds[1], subformula[iii]->sym->NormBounds[0]);
		}
	}
    else  if ((p_par->nInp==6) && (subformula[iii]->sym->set->nloc==0) && (p_par->nCLG>=1)) /*used for multiple H.A.s*/
	{
        robHA=(HyDis *)emalloc((p_par->nCLG)*sizeof(HyDis));
        for(i=0;i<p_par->nCLG;i++){
			if (subformula[iii]->sym->set->nlocNCLG[i] == 0){
				robustness.ds = SignedDist(xx, subformula[iii]->sym->set, p_par->SysDim);
				robustness.dl = 0;
				robustness.headLocation = 0;
				robustness.tailLocation = 0;
			}
			else
			{
				robustness = SignedHDist0NCLG(xx, subformula[iii]->sym->set, p_par->SysDim, p_distData->LDistNCLG, p_par->tnLocNCLG[i], i);
			}
			robustness.HAindex=i+1;
            robHA[i]=robustness;
        }
        robustness=SetToInf(+1,ii);/*we use minimum because hybrid distance is negative when it is not in the desired location*/
        for(i=0;i<p_par->nCLG;i++){
            robustness=hmin(robustness,robHA[i]);
        }
        rob->ds=robustness.ds;
        rob->dl=robustness.dl;
		rob->iteration = ii;
		rob->preindex = subformula[iii]->sym->index;
        rob->HAindex=robustness.HAindex;
        rob->headLocation=robustness.headLocation;
        rob->tailLocation=robustness.tailLocation;
		if (subformula[iii]->sym->Normalized)
		{
			*rob = NormalizeHybrid(*rob, subformula[iii]->sym->NormBounds[1], subformula[iii]->sym->NormBounds[0]);
		}
	}
    else    
	{
		rob->ds = SignedDist(xx,subformula[iii]->sym->set,p_par->SysDim);
		rob->dl = 0;
        rob->HAindex=0;
        rob->headLocation=0;
        rob->tailLocation=0;
		rob->iteration = ii;
		rob->preindex = subformula[iii]->sym->index;
		if (subformula[iii]->sym->Normalized)
		{
			rob->ds = Normalize(rob->ds, subformula[iii]->sym->NormBounds[0]);
		}
	}
}

/* cluster of functions for BFS */
int enqueue(struct queue *q, Node *phi)
{

    if (phi == NULL) {
        errno = ENOMEM;
        return 1;
    }
	if(phi->visited == 0){
		phi->visited = 0;
			if (q->first == NULL){
				q->first = q->last = phi;							/* point first and last in the queue to the phi passed if the queue is empty*/
			}
			else {
				q->last = phi;                                      /* stuff the phi passed in the last of the queue if the queue is not empty*/
			}
		phi->visited = 1;
    return 0;
	}
	return -1;
}

int dequeue(struct queue *q)
{
	if (!q->first) {
        return 1;
    }
    if (q->first == q->last)							/* if the queue has only one element*/
        q->first = q->last = NULL;
    else
		q->first = q->last;                             /*  pop the first element out of the queue*/
    return 0;
}

void init_queue(struct queue *q)
{
    q->first = q->last = NULL;
}

int queue_empty_p(const struct queue *q)
{
    return q->first == NULL;
}

int BreadthFirstTraversal(struct queue *q,Node *root,Node *subformula[],int *i)
{
	double infval = mxGetInf();	
	Node *p = NULL;
	if (root == NULL) return 0;

	enqueue(q,root);									/* enqueue the root node*/

	while (!queue_empty_p(q)) {
		if(!q->first){
			p = NULL;
		}
		else{											/* set subformula index		*/	
			if((*i)>399)
			{
				mexErrMsgTxt("mx_dp_taliro: The formula is too big to be stored in tree sturcture!");/* error message when amount of subformulas exceeds subMax*/
			}
			else
			{
				p = q->first;
				p->index = *i;
				subformula[*i] = p;
				subformula[*i]->BoundCheck = 0;
				subformula[*i]->UBound = -intMax32bit;
				subformula[*i]->LBound = intMax32bit;
				subformula[*i]->LBound_nxt = intMax32bit;
				subformula[*i]->UBindicator = 0;
				subformula[*i]->LBindicator = 0;
				subformula[*i]->LBindicator_nxt = 0;
				subformula[*i]->loop_end = 0;

				(*i)++;
			}
		}
		
		dequeue(q);
		if (p->lft != NULL)
			BreadthFirstTraversal( q,p->lft,subformula,i);
		if (p->rgt != NULL)
			BreadthFirstTraversal( q,p->rgt,subformula,i);

	}
	return (*i-1);
} 

/* cluster of functions for BFS ends */

mxArray *DynamicProgramming(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par, Miscellaneous *miscell)
{
	mwIndex ii = 0;							/* used for mapping predicate and passing state vector*/
	mwIndex jj = 0;							/* used for passing state vector*/
	double t_cur = 0;						/* store time */
	double t_nxt = 0; 
	Symbol *tmpsym;
	double infval;							/*	infinite value*/
	double *now;							/*	state vector for second switch*/
	double *next;							/*	state vector for first switch*/
	HyDis *TempL;							/*  Temporal memory space for robustness metrics used in opeartors such as <>,[],U,R */
	HyDis *TempR;							/*  Temporal memory space for robustness metrics used in opeartors such as <>,[],U,R */
	char last = 0;
	Number dt, ct;
	const char *fields[] = {"dl", "ds", "most_related_iteration", "most_related_predicate_index", "most_related_HA", "most_related_Guard_head", "most_related_Guard_tail"};
    mxArray *tmp;
#define subMax 400							/*	biggest number of nodes/elements the subformula could store*/
	Node *subformula[subMax];				/* subformula array as a cross-reference for the phi*/
	Number *CurTime;
	int iii=0;								/* used for check the index for subformula*/
	int jjj=0;								/* length-1 of the subformula array */
	int *qi;
	int temp = 1;
	/* Initialize some variables for BFS */
	queue q;
	queue *Q = &q;
	init_queue(Q);							/*initial the queue*/
	qi = &temp;
	/*----------------------------------*/
	infval = mxGetInf();
	dt = miscell->zero;
	ct = miscell->zero;	

	/*-----BFS for formula--------------*/
	jjj = BreadthFirstTraversal(Q,phi,subformula,qi);
		for(iii=1; iii<jjj; iii++)			/*	check the index for subformula*/
		{
			if(iii != subformula[iii]->index)
				mexErrMsgTxt("mx_dp_taliro: Breadth-First-Traversal failed, subformulas are not matched to right index!");
		}
	/* reserve space for the state vector 
	   +1 for the current location appended at the end of the vector */
    /*now = (double *)emalloc((p_par->SysDim+1)*sizeof(double));
    next = (double *)emalloc((p_par->SysDim+1)*sizeof(double));*/
    /* For Multiple H.A. is updated*/
        now = (double *)emalloc((p_par->SysDim+p_par->nCLG)*sizeof(double));
        next = (double *)emalloc((p_par->SysDim+p_par->nCLG)*sizeof(double));
    /* For Multiple H.A.*/
    CurTime = (Number *)emalloc(1*(p_par->nSamp+1)*sizeof(Number));
	TempL = (HyDis *)emalloc((jjj+1)*3*2*(p_par->nSamp+1)*sizeof(HyDis));
	TempR = (HyDis *)emalloc((jjj+1)*3*2*(p_par->nSamp+1)*sizeof(HyDis));		
	/* map each predicate to a set */
	for (ii=0;ii<p_par->nPred;ii++)
	{
		if(predMap[ii].true_pred)
		{
			/* GF: TODO: Should predMap below be replaced with misc ?? */
			tmpsym = tl_lookup(predMap[ii].str, miscell);
			tmpsym->set = &(predMap[ii].set);
			tmpsym->Normalized = predMap[ii].Normalized;
			tmpsym->NormBounds = predMap[ii].NormBounds;
		}
	}
	/* Get time stamp if the logic is MTL */
	if (!p_par->ConOnSamples && !p_par->LTL)
		t_cur = TStamps[0];		
	if (!p_par->LTL && !p_par->ConOnSamples)
	{
		ii = 0;
		while(ii<p_par->nSamp)
		{
			t_nxt = TStamps[ii+1];
			dt.numf.f_num = t_nxt-t_cur;
			ct.numf.f_num = t_cur;
			CurTime[ii] = ct;
			t_cur = t_nxt;
			ii++;
		}
	}
	/* -----DP----- */
	/*	initial state vector*/
	ii = p_par->nSamp-1 ;
	jj = p_par->nSamp-1 ;
	while(ii>=0)
	{
		for(jj = 0; jj < p_par->SysDim; jj++)			/* time stamp for DP*/
		{
			next[jj] = XTrace[ii-0+jj*p_par->nSamp];
			now[jj] = XTrace[ii-1+jj*p_par->nSamp];	
		}
        
   		if (p_par->nInp>4 && p_par->nCLG<=1)
		{
			next[p_par->SysDim] = LTrace[ii];			/* value of location is added to the end of the trace*/
			now[p_par->SysDim] = LTrace[ii-1];
		}
        else if ( p_par->nInp>4 && p_par->nCLG>1 ){
    		for(jj = 0; jj < p_par->nCLG; jj++)			/* Multiple CLG locations for DP*/
        	{
            	next[p_par->SysDim+jj] = LTrace[ii-0+jj*p_par->nSamp];
                now[p_par->SysDim+jj] = LTrace[ii-1+jj*p_par->nSamp];	
            }            
        }

        
		jj = p_par->nSamp -1;
	/*	dynamic programming */
		DPRob(subformula,next,now,p_distData,&ct,&dt,&last,p_par,jjj,ii,jj,CurTime,TempL,TempR);
		ii--;								/*	decrease the time*/
		if(ii>=0)
		{									/* decrease the time twice if it's not the end iteration*/
			ii--;
		}
		if(ii>=0){							/* set new state vector*/
			for(jj = 0; jj < p_par->SysDim; jj++)
			{
				next[jj] = XTrace[ii-1+jj*p_par->nSamp];
				now[jj] = XTrace[ii-2+jj*p_par->nSamp];	
			}
   			if (p_par->nInp>4 && p_par->nCLG<=1)
			{
				next[p_par->SysDim] = LTrace[ii-1];
				now[p_par->SysDim] = LTrace[ii-2];
			}
            else if ( p_par->nInp>4 && p_par->nCLG>1 ){
        		for(jj = 0; jj < p_par->nCLG; jj++)			/* Multiple CLG locations for DP*/
            	{
                	next[p_par->SysDim+jj] = LTrace[ii-0+jj*p_par->nSamp];
                    now[p_par->SysDim+jj] = LTrace[ii-1+jj*p_par->nSamp];	
                }            
            }

		}		
	}
		
	/* free memory */
	mxFree(now);
	mxFree(next);
	mxFree(CurTime);
	mxFree(TempL);
	mxFree(TempR);
	/* Output the result */
	tmp = mxCreateStructMatrix(1, 1, 7, fields);
	if (phi->ntyp==TRUE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "most_related_HA", mxCreateDoubleScalar(0));
		mxSetField(tmp, 0, "most_related_Guard_head", mxCreateDoubleScalar(0));
		mxSetField(tmp, 0, "most_related_Guard_tail", mxCreateDoubleScalar(0));
		return(tmp);
	}
	else if (phi->ntyp==FALSE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "most_related_HA", mxCreateDoubleScalar(0));
		mxSetField(tmp, 0, "most_related_Guard_head", mxCreateDoubleScalar(0));
		mxSetField(tmp, 0, "most_related_Guard_tail", mxCreateDoubleScalar(0));
		return(tmp);
	}
	else 
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(phi->rob.dl));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(phi->rob.ds));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(phi->rob.iteration+1));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(phi->rob.preindex));
		mxSetField(tmp, 0, "most_related_HA", mxCreateDoubleScalar(phi->rob.HAindex));
		mxSetField(tmp, 0, "most_related_Guard_head", mxCreateDoubleScalar(phi->rob.headLocation));
		mxSetField(tmp, 0, "most_related_Guard_tail", mxCreateDoubleScalar(phi->rob.tailLocation));
		return(tmp);
	}
}

void DPRob(Node *subformula[], double *next, double *now, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par, int mmm, int ii, int jj, Number *CurTime, HyDis *TempLeft, HyDis *TempRight)
{
/*
MTL-debugging: I first implement Until(U_OPER) function of MTL according to ALG 1, modify it to become ALWAYS function of MTL. 
And Relase(V_OPER) is the negation of Until(U_OPER) and EVENTUALLY is the negation of ALWAYS.

*/
    
         
    int jjj = mmm;						/* length-1 of the subformula array */
	int iii = mmm;						/* iteration times*/
	int kkk;							/* used for find the connection between subformulas*/
	int lll;							/* used for find the connection between subformulas*/
	int tbi;							/* used for time_bound calculation*/
	int highi;
	int bl_to_bu;							/* used for MTL*/
	int bl_to_bl_plus;
	int rmin_iteration;
	int lockon = 0;
	int *i_low;
	int initial = 0;
	int bl = 0;
	int bu = 0;						/* as the bl and bu defined in the algorithm in the paper [Verification of Automotive Control Applications using S-TaLiRo]*/
	int bl_plus = 0;
	HyDis RMin;							/* as the Rmin defined in the algorithm in the paper [...]*/
	Number TempU;
	Number TempL;
	Number TempL_nxt;

	int (*l_comp)(Number, Number, FWTaliroParam *);
	int (*u_comp)(Number, Number, FWTaliroParam *);
	double infval = mxGetInf();							/*	infinite value*/
	i_low = &initial;					


	while(iii > 0){
		/*------------------------------------first switch---------------------------------*/
			switch (subformula[iii]->ntyp)
			{
			case TRUE:
                subformula[iii]->rob = SetToInf(+1, ii);
                break;
			case FALSE:
                subformula[iii]->rob = SetToInf(-1, ii);
                break;
			case VALUE:
				break;

			case PREDICATE:
				if (ii == jj)
				{
					subformula[iii]->rob_sec = SetToInf(-1, ii);
				}
                compute_predicate(subformula, next, p_distData, p_par, iii, ii, &(subformula[iii]->rob)); 
				break;

			case NOT:
				kkk = iii;
				while(kkk<jjj+1)
				{
					if(subformula[iii]->lft == subformula[kkk])
					{
						subformula[iii]->rob = subformula[kkk]->rob;
						subformula[iii]->rob.dl = (-1)*(subformula[kkk]->rob.dl);
						subformula[iii]->rob.ds = (-1)*(subformula[kkk]->rob.ds);
					}
					kkk++;
				}
				break;

			case AND:
				for(kkk = iii; kkk < jjj+1; kkk++)
				{
					for(lll = iii; lll < jjj+1; lll++)
					{
						if(subformula[iii]->lft == subformula[kkk] && subformula[iii]->rgt == subformula[lll])
						{
							subformula[iii]->rob = hmin(subformula[kkk]->rob, subformula[lll]->rob);
						}
					}
				}
				break;

			case OR:
				for(kkk = iii; kkk < jjj+1; kkk++)
				{
					for(lll = iii; lll < jjj+1; lll++)
					{
						if(subformula[iii]->lft == subformula[kkk] && subformula[iii]->rgt == subformula[lll])
						{
							subformula[iii]->rob = hmax(subformula[kkk]->rob, subformula[lll]->rob);
						}
					}
				}
				break;

			case NEXT:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
					if(subformula[iii]->lft == subformula[kkk])
						{
							subformula[iii]->rob = subformula[kkk]->rob_sec;
   							if(ii == jj){
								subformula[iii]->rob = SetToInf(-1,ii);
								subformula[iii]->rob_sec = SetToInf(-1,ii);
                            }
						}
					}			
				}
				else
				{
					if(1)
					{
                        subformula[iii]->UBound = -intMax32bit;
						subformula[iii]->LBound = intMax32bit;
						for(tbi = jj; tbi >= 0; tbi--)
						{
                            TempU=subformula[iii]->time.ubd;
                            if(subformula[iii]->time.ubd.numf.inf != 1)
							{
								TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
							}
							else
							{
								TempU.numf.f_num = infval;
							}                               
                            if ((*u_comp)(CurTime[tbi],TempU,p_par))
                            {
                                subformula[iii]->UBound = imax(subformula[iii]->UBound,tbi);
                            }
							TempL = subformula[iii]->time.lbd;
                            TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
							if ((*l_comp)(CurTime[tbi],TempL,p_par))
							{
                                subformula[iii]->LBound = imin(subformula[iii]->LBound,tbi);
							}
						}
						subformula[iii]->BoundCheck = 1;
					}
					if(subformula[iii]->LBound > subformula[iii]->UBound)
					{
						subformula[iii]->rob = SetToInf(-1,ii);
						subformula[iii]->rob_sec = SetToInf(-1,ii);
					}
					else
					{
						for(kkk = iii; kkk < jjj+1; kkk++)
						{
							if(subformula[iii]->lft == subformula[kkk])
							{
                                if( ii >= subformula[iii]->LBound-1 && ii <= subformula[iii]->UBound-1)
								{
    							    subformula[iii]->rob = subformula[kkk]->rob_sec;
                                }
								else
								{
            						subformula[iii]->rob = SetToInf(-1,ii);
                        			subformula[iii]->rob_sec = SetToInf(-1,ii);
								}
                                if(ii == jj){
                                    subformula[iii]->rob = SetToInf(-1,ii);
                                    subformula[iii]->rob_sec = SetToInf(-1,ii);
                                }
							}
						}
					}
				}
				break;

			case U_OPER:
				if (subformula[iii]->time.l_closed)
				{
					l_comp = &e_geq;
				}
				else
				{
					l_comp = &e_ge;
				}
				if (subformula[iii]->time.u_closed)
				{
					u_comp = &e_leq;
				}
				else
				{
					u_comp = &e_le;
				}
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								if(ii==jj)
								{
									subformula[iii]->rob = subformula[kkk]->rob;
								}
								else
								{
									subformula[iii]->rob = hmax(hmin(subformula[iii]->rob_sec,subformula[lll]->rob),subformula[kkk]->rob);
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
								TempLeft[iii * (jj+2) + ii] = subformula[lll]->rob;
								{
                                /* algorithm for getting time-stamps of the trace */
                                /* see the algorithm in paper [Dynamic Programming algorithm for Computing Temporal Logic Robustness]*/
								if(1)
								{
									if(subformula[iii]->time.ubd.numf.inf == 1)
									{	
										subformula[iii]->UBound = jj;
									}
									else
									{
										if(subformula[iii]->UBound != -intMax32bit)
                                        {
											highi = subformula[iii]->UBound;
										}
										else
										{
											highi = jj;
										}
										*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									}

									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
                                /**/
								{
									/* boundary conditions, in this case LBOUND is never assigned a value thus it should be infinity 
										which means i+I exceeds the last sampling point of the trace
									*/
										if(subformula[iii]->LBound > subformula[iii]->UBound)
										{	
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(-1,ii);
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
										else
										{
											if(ii==jj)
											{
												/* see the algorithm in Verification of Automotive Control Applications using S-TaLiRo */
												if(subformula[iii]->LBound == 0)
												{
													subformula[iii]->rob = subformula[kkk]->rob;
													subformula[iii]->rob_sec = subformula[kkk]->rob;
												}
												else
												{
													subformula[iii]->rob = subformula[iii]->rgt->rob;
													subformula[iii]->rob = SetToInf(-1,ii);
													subformula[iii]->rob_sec = subformula[iii]->rob;
												}
												RMin = subformula[iii]->lft->rob;
												RMin = SetToInf(+1,ii);
											}
											bl = subformula[iii]->LBound;
											bu = subformula[iii]->UBound;
											RMin = subformula[iii]->lft->rob;
											RMin = SetToInf(+1,ii);
											for(rmin_iteration = ii; rmin_iteration < bl; rmin_iteration++)
											{
												if(rmin_iteration<=jj)
												{
													RMin = hmin(RMin,TempLeft[iii * (jj+2) + rmin_iteration]);
												}
											}
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(-1,ii);
											for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
											{
												if(bl_to_bu<=jj)
												{
													subformula[iii]->rob = hmax(subformula[iii]->rob,hmin(TempRight[iii * (jj+2) + bl_to_bu], RMin));
													RMin = hmin(RMin,TempLeft[iii * (jj+2) + bl_to_bu]); 
												}
											}
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
									}
								}
							}
						}
					}
				}
				break;

			case V_OPER:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								if(ii==jj)
								{
									subformula[iii]->rob = subformula[kkk]->rob;
								}
								else
								{
									subformula[iii]->rob = hmin(hmax(subformula[iii]->rob_sec,subformula[lll]->rob),subformula[kkk]->rob);
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
								TempLeft[iii * (jj+2) + ii] = subformula[lll]->rob;
								{
								if(1)
								{
									if(subformula[iii]->time.ubd.numf.inf == 1)
									{	
										subformula[iii]->UBound = jj;
									}
									else
									{
                                        if(subformula[iii]->UBound != -intMax32bit)
										{
											highi = subformula[iii]->UBound;
										}
										else
										{
											highi = jj;
										}
										*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									}
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
								{
										if(subformula[iii]->LBound > subformula[iii]->UBound)
										{
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(+1,ii);
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
										else
										{
											if(ii==jj)
											{
												if(subformula[iii]->LBound == 0)
												{
													subformula[iii]->rob = subformula[kkk]->rob;
													subformula[iii]->rob_sec = subformula[kkk]->rob;
												}
												else
												{
													subformula[iii]->rob = subformula[iii]->rgt->rob;
													subformula[iii]->rob = SetToInf(+1,ii);
													subformula[iii]->rob_sec = subformula[iii]->rob;
												}
												RMin = subformula[iii]->lft->rob;
												RMin = SetToInf(-1,ii);
											}
											bl = subformula[iii]->LBound;
											bu = subformula[iii]->UBound;
											RMin = subformula[iii]->lft->rob;
											RMin = SetToInf(-1,ii);
											for(rmin_iteration = ii; rmin_iteration < bl; rmin_iteration++)
											{
												if(rmin_iteration<=jj)
												{
													RMin = hmax(RMin,TempLeft[iii * (jj+2) + rmin_iteration]);
												}
											}
											subformula[iii]->rob = RMin;
											subformula[iii]->rob = SetToInf(+1,ii);
											for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
											{
												if(bl_to_bu<=jj)
												{
													subformula[iii]->rob = hmin(subformula[iii]->rob,hmax(TempRight[iii * (jj+2) + bl_to_bu], RMin));
													RMin = hmax(RMin,TempLeft[iii * (jj+2) + bl_to_bu]); 
												}
											}
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
									}
								}
							}
						}
					}
				}
				break;
				
			case ALWAYS:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							if(ii==jj)
							{
								subformula[iii]->rob = subformula[kkk]->rob;
							}
							else
							{
								subformula[iii]->rob = hmin(subformula[iii]->rob_sec,subformula[kkk]->rob);
							}
						}
					}
				}
				else if(subformula[iii]->time.lbd.numf.inf == 0 && (subformula[iii]->time.lbd.numf.f_num != 0 || subformula[iii]->time.l_closed == 0) && subformula[iii]->time.ubd.numf.inf == 1)
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
                                /* get time bound*/
								if(1)
								{
									subformula[iii]->UBound = jj;
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound_nxt) && tbi>=0)
											{
												TempL_nxt = subformula[iii]->time.lbd;
												if(ii + 1 <= jj)
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii+1].numf.f_num;
												}
												else
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;												
												}
												if (((*l_comp)(CurTime[tbi],TempL_nxt,p_par)))
												{
													subformula[iii]->LBound_nxt = tbi;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									bl = subformula[iii]->LBound;
									bl_plus = subformula[iii]->LBound_nxt;
								}
                            /* get time bound ends*/
							if(subformula[iii]->LBound > subformula[iii]->UBound)
							{
								subformula[iii]->rob = subformula[iii]->rgt->rob;
								subformula[iii]->rob = SetToInf(+1,ii);
								subformula[iii]->rob_sec = subformula[iii]->rob;
							}
							else
							{
								lockon = 0;
								if(bl == intMax32bit || bl_plus == intMax32bit)
								{
									lockon = 1;
								}
								if(ii==jj)
								{
									subformula[iii]->rob = subformula[kkk]->rob;
									subformula[iii]->rob_sec = subformula[iii]->rob;
									subformula[iii]->rob_sec = SetToInf(+1,ii);
								}
								else
								{
									if(lockon == 0)
									{
										RMin = subformula[iii]->rgt->rob;	
										RMin = SetToInf(+1,ii);
										if(bl == intMax32bit || bl_plus == intMax32bit)
										{
											mexErrMsgTxt("mx_dp_taliro: lockon not working!");
										}
										for(bl_to_bl_plus = bl; bl_to_bl_plus <= bl_plus; bl_to_bl_plus++)
										{
											RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
										}
										subformula[iii]->rob = hmin(subformula[iii]->rob_sec,RMin);
									}
									else if(lockon == 1)
									{
										if(bl == jj)
										{
											subformula[iii]->rob = TempRight[iii * (jj+2) + jj];
										}
										else
										{
											RMin = subformula[iii]->rgt->rob;	
											RMin = SetToInf(+1,ii);
											if(bl == intMax32bit)
											{
												mexErrMsgTxt("mx_dp_taliro: error when lockon == 1!");
											}
											if(bl>=0 && bl_plus== intMax32bit)
											{
												for(bl_to_bl_plus = bl; bl_to_bl_plus <= jj; bl_to_bl_plus++)
												{
													RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
												}
												subformula[iii]->rob = hmin(subformula[iii]->rob_sec,RMin);	
											}
										}
									}
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
							{
							/* get time bound*/
								if(1)
								{
									if(subformula[iii]->UBound != -intMax32bit)
									{
										highi = subformula[iii]->UBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi - 1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
								/*get time bound ends*/
								{
									if(subformula[iii]->LBound > subformula[iii]->UBound)
									{
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(+1,ii);
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
									else
									{
										if(ii==jj)
										{
											if(subformula[iii]->LBound == 0)
											{
												subformula[iii]->rob = subformula[iii]->rgt->rob;
												subformula[iii]->rob = SetToInf(+1,ii);
												subformula[iii]->rob_sec = subformula[iii]->rob;
											}
											else
											{
												subformula[iii]->rob = subformula[iii]->rgt->rob;
												subformula[iii]->rob = SetToInf(-1,ii);
												subformula[iii]->rob_sec = subformula[iii]->rob;
											}
											RMin = subformula[iii]->rgt->rob;	
											RMin = SetToInf(+1,ii);
										}
										bl = subformula[iii]->LBound;
										bu = subformula[iii]->UBound;
										RMin = subformula[iii]->rgt->rob;	
										RMin = SetToInf(+1,ii);
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(+1,ii);
										for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
										{
											if(bl_to_bu<=jj)
											{
												RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bu]); 
												subformula[iii]->rob = hmin(subformula[iii]->rob, RMin);
											}
										}							
									}
								}
							}				
						}
					}
				}
				break;

			case EVENTUALLY:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							if(ii==jj)
							{
								subformula[iii]->rob = subformula[kkk]->rob;
							}
							else
							{
								subformula[iii]->rob = hmax(subformula[iii]->rob_sec,subformula[kkk]->rob);
							}
						}
					}
				}
				else if(subformula[iii]->time.lbd.numf.inf == 0 && (subformula[iii]->time.lbd.numf.f_num != 0 || subformula[iii]->time.l_closed == 0) && subformula[iii]->time.ubd.numf.inf == 1)
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
                            /* get time bound */
								if(1)
								{
									subformula[iii]->UBound = jj;
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound_nxt) && tbi>=0)
											{
												TempL_nxt = subformula[iii]->time.lbd;
												if(ii + 1 <= jj)
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii+1].numf.f_num;
												}
												else
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;												
												}
												if (((*l_comp)(CurTime[tbi],TempL_nxt,p_par)))
												{
													subformula[iii]->LBound_nxt = tbi;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									bl = subformula[iii]->LBound;
									bl_plus = subformula[iii]->LBound_nxt;
								}
							/* get time bound ends */
							if(subformula[iii]->LBound > subformula[iii]->UBound)
							{
								subformula[iii]->rob = subformula[iii]->rgt->rob;
								subformula[iii]->rob = SetToInf(-1,ii);
								subformula[iii]->rob_sec = subformula[iii]->rob;
							}
							else
							{
								lockon = 0;
								if(bl == intMax32bit || bl_plus == intMax32bit)
								{
									lockon = 1;
								}
								if(ii==jj)
								{
									subformula[iii]->rob = subformula[kkk]->rob;
									subformula[iii]->rob_sec = subformula[iii]->rob;
									subformula[iii]->rob_sec = SetToInf(-1,ii); 
								}
								else
								{
									if(lockon == 0)
									{
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(-1,ii);
										if(bl == intMax32bit || bl_plus == intMax32bit)
										{
											mexErrMsgTxt("mx_dp_taliro: lockon not working!");
										}
										for(bl_to_bl_plus = bl; bl_to_bl_plus <= bl_plus; bl_to_bl_plus++)
										{
											RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
										}
										subformula[iii]->rob = hmax(subformula[iii]->rob_sec,RMin);
									}
									else if(lockon == 1)
									{
										if(bl == jj)
										{
											subformula[iii]->rob = TempRight[iii * (jj+2) + jj];
										}
										else
										{
											RMin = subformula[iii]->rgt->rob;
											RMin = SetToInf(-1,ii);
											if(bl == intMax32bit)
											{
												mexErrMsgTxt("mx_dp_taliro: error when lockon == 1!");
											}
											if(bl>=0 && bl_plus == intMax32bit)
											{
												for(bl_to_bl_plus = bl; bl_to_bl_plus <= jj; bl_to_bl_plus++)
												{
													RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
												}
												subformula[iii]->rob = hmax(subformula[iii]->rob_sec,RMin);
											}
										}
									}
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob;
							{
                            /* get time bound*/
								if(1)
								{
									if(subformula[iii]->UBound != -intMax32bit)
									{
										highi = subformula[iii]->UBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
										  
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi - 1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
                                /* get time bound ends */
								{
									if(subformula[iii]->LBound > subformula[iii]->UBound)
									{
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(-1,ii);
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
									else
									{
										if(ii==jj) 
										{
											if(subformula[iii]->LBound == 0)
											{
												subformula[iii]->rob = subformula[iii]->rgt->rob;
												subformula[iii]->rob = SetToInf(-1,ii);
												subformula[iii]->rob_sec = subformula[iii]->rob;
											}
											else{
												subformula[iii]->rob = subformula[iii]->rgt->rob;
												subformula[iii]->rob = SetToInf(+1,ii);
												subformula[iii]->rob_sec = subformula[iii]->rob;
											}
											RMin = SetToInf(-1,ii);
										}
										bl = subformula[iii]->LBound;
										bu = subformula[iii]->UBound;
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(-1,ii);
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(-1,ii);
										for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
										{
											if(bl_to_bu<=jj)
											{
												RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bu]);
												subformula[iii]->rob = hmax(subformula[iii]->rob, RMin);
											}
										}							
									}
								}
							}				
						}
					}
				}
				break;

			case WEAKNEXT:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
					if(subformula[iii]->lft == subformula[kkk])
						{
							subformula[iii]->rob = subformula[kkk]->rob_sec;
   							if(ii == jj){
								subformula[iii]->rob = SetToInf(1,ii);
								subformula[iii]->rob_sec = SetToInf(1,ii);
                            }
						}
					}			
				}
				else
				{
					if(1)
					{
                        subformula[iii]->UBound = -intMax32bit;
						subformula[iii]->LBound = intMax32bit;
						for(tbi = jj; tbi >= 0; tbi--)
						{
                            TempU=subformula[iii]->time.ubd;
                            if(subformula[iii]->time.ubd.numf.inf != 1)
							{
								TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
							}
							else
							{
								TempU.numf.f_num = infval;
							}                               
                            if ((*u_comp)(CurTime[tbi],TempU,p_par))
                            {
                                subformula[iii]->UBound = imax(subformula[iii]->UBound,tbi);
                            }
							TempL = subformula[iii]->time.lbd;
                            TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
							if ((*l_comp)(CurTime[tbi],TempL,p_par))
							{
                                subformula[iii]->LBound = imin(subformula[iii]->LBound,tbi);
							}
						}
						subformula[iii]->BoundCheck = 1;
					}
					if(subformula[iii]->LBound > subformula[iii]->UBound)
					{
						subformula[iii]->rob = SetToInf(1,ii);
						subformula[iii]->rob_sec = SetToInf(1,ii);
					}
					else
					{
						for(kkk = iii; kkk < jjj+1; kkk++)
						{
							if(subformula[iii]->lft == subformula[kkk])
							{
                                if( ii >= subformula[iii]->LBound-1 && ii <= subformula[iii]->UBound-1)
								{
    							    subformula[iii]->rob = subformula[kkk]->rob_sec;
                                }
								else
								{
            						subformula[iii]->rob = SetToInf(1,ii);
                        			subformula[iii]->rob_sec = SetToInf(1,ii);
								}
                                if(ii == jj){
                                    subformula[iii]->rob = SetToInf(1,ii);
                                    subformula[iii]->rob_sec = SetToInf(1,ii);
                                }
							}
						}
					}
				}
				break;
			default:
                mexPrintf("%s%s\n", "Node: ", "WEAKNEXT");
				mexErrMsgTxt("mx_dp_taliro: The above operator is not supported!\n");
				break;
			}
			iii--;
		}

		 iii = jjj;
		/*------------------------------------second switch---------------------------------*/
		if(ii>=1){
			ii = ii -1;
			while(iii > 0)
			{
				switch (subformula[iii]->ntyp)
				{
    			case TRUE:
                    subformula[iii]->rob_sec = SetToInf(+1, ii);
                    break;
                case FALSE:
                    subformula[iii]->rob_sec = SetToInf(-1, ii);
                    break;
				case VALUE:
					break;

				case PREDICATE:
					compute_predicate(subformula, now, p_distData, p_par, iii, ii, &(subformula[iii]->rob_sec));
					break;

				case NOT:
					kkk = iii;
					while(kkk<jjj+1)
					{
						if(subformula[iii]->lft == subformula[kkk])
						{
							subformula[iii]->rob_sec = subformula[kkk]->rob_sec;
							subformula[iii]->rob_sec.dl = (-1)*(subformula[kkk]->rob_sec.dl);
							subformula[iii]->rob_sec.ds = (-1)*(subformula[kkk]->rob_sec.ds);
						}
						kkk++;
					}
					break;

				case AND:
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->lft == subformula[kkk] && subformula[iii]->rgt == subformula[lll])
							{
								subformula[iii]->rob_sec = hmin(subformula[kkk]->rob_sec, subformula[lll]->rob_sec);
							}
						}
					}
					break;

				case OR:
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->lft == subformula[kkk] && subformula[iii]->rgt == subformula[lll])
							{
								subformula[iii]->rob_sec = hmax(subformula[kkk]->rob_sec, subformula[lll]->rob_sec);
							}
						}
					}
					break;

				case NEXT:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->lft == subformula[kkk])
						{
                            subformula[iii]->rob_sec = subformula[kkk]->rob;
						}
					}
				}
				else
				{
					if(1)
					{
						subformula[iii]->UBound = -intMax32bit;
						subformula[iii]->LBound = intMax32bit;
						for(tbi = jj; tbi >= 0; tbi--)
						{
                            TempU=subformula[iii]->time.ubd;
                            if(subformula[iii]->time.ubd.numf.inf != 1)
							{
								TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
							}
							else
							{
								TempU.numf.f_num = infval;
							}                               
                            if ((*u_comp)(CurTime[tbi],TempU,p_par))
                            {
                                subformula[iii]->UBound = imax(subformula[iii]->UBound,tbi);
                            }
							TempL = subformula[iii]->time.lbd;
                            TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
							if ((*l_comp)(CurTime[tbi],TempL,p_par))
							{
                                subformula[iii]->LBound = imin(subformula[iii]->LBound,tbi);
							}
						}
						subformula[iii]->BoundCheck = 1;
					}
                    if(subformula[iii]->LBound > subformula[iii]->UBound)
					{
						subformula[iii]->rob = SetToInf(-1,ii);
						subformula[iii]->rob_sec = SetToInf(-1,ii);
					}
					else
					{
						for(kkk = iii; kkk < jjj+1; kkk++)
						{
							if(subformula[iii]->lft == subformula[kkk])
							{
								if( ii>=subformula[iii]->LBound-1 && ii <=subformula[iii]->UBound-1)
								{
                                    subformula[iii]->rob_sec = subformula[kkk]->rob;
								}
								else
								{
            						subformula[iii]->rob = SetToInf(-1,ii);
                        			subformula[iii]->rob_sec = SetToInf(-1,ii);
								}
							}
						}
					}
				}
				break;

				case U_OPER:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								subformula[iii]->rob_sec = hmax(hmin(subformula[iii]->rob,subformula[lll]->rob_sec),subformula[kkk]->rob_sec);
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;
								TempLeft[iii * (jj+2) + ii] = subformula[lll]->rob_sec;							
								{
								if(1)
								{
									if(subformula[iii]->time.ubd.numf.inf == 1)
									{	
										subformula[iii]->UBound = jj;
									}
									else
									{
										if(subformula[iii]->UBound != -intMax32bit)
										{
											highi = subformula[iii]->UBound;
										}
										else
										{
											highi = jj;
										}
										*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									}

									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
								{
										if(subformula[iii]->LBound > subformula[iii]->UBound)
										{
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(-1,ii);
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
										else
										{
											bl = subformula[iii]->LBound;
											bu = subformula[iii]->UBound;
											RMin = subformula[iii]->lft->rob;
											RMin = SetToInf(+1,ii);
											for(rmin_iteration = ii; rmin_iteration < bl; rmin_iteration++)
											{
												if(rmin_iteration<=jj)
												{
													RMin = hmin(RMin,TempLeft[iii * (jj+2) + rmin_iteration]);
												}
											}
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(-1,ii);
											for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
											{
												if(bl_to_bu<=jj)
												{
													subformula[iii]->rob = hmax(subformula[iii]->rob,hmin(TempRight[iii * (jj+2) + bl_to_bu], RMin));
													RMin = hmin(RMin,TempLeft[iii * (jj+2) + bl_to_bu]); 
												}
											}
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
									}
								}
							}
						}
					}
				}
				break;

				case V_OPER:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								subformula[iii]->rob_sec = hmin(hmax(subformula[iii]->rob,subformula[lll]->rob_sec),subformula[kkk]->rob_sec);
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						for(lll = iii; lll < jjj+1; lll++)
						{
							if(subformula[iii]->rgt == subformula[kkk] && subformula[iii]->lft == subformula[lll])
							{
								TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;
								TempLeft[iii * (jj+2) + ii] = subformula[lll]->rob_sec;
								{
								if(1)
								{
									if(subformula[iii]->time.ubd.numf.inf == 1)
									{	
										subformula[iii]->UBound = jj;
									}
									else
									{
										if(subformula[iii]->UBound != -intMax32bit)
										{
											highi = subformula[iii]->UBound;
										}
										else
										{
											highi = jj;
										}
										*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									}
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
								{
										if(subformula[iii]->LBound > subformula[iii]->UBound)
										{
											subformula[iii]->rob = subformula[iii]->rgt->rob;
											subformula[iii]->rob = SetToInf(+1,ii);
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
										else
										{	
											bl = subformula[iii]->LBound;
											bu = subformula[iii]->UBound;
											RMin = subformula[iii]->lft->rob;
											RMin = SetToInf(-1,ii);
											for(rmin_iteration = ii; rmin_iteration < bl; rmin_iteration++)
											{
												if(rmin_iteration<=jj)
												{
													RMin = hmax(RMin,TempLeft[iii * (jj+2) + rmin_iteration]);
												}
											}
											subformula[iii]->rob = RMin;
											subformula[iii]->rob = SetToInf(+1,ii);
											for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
											{
												if(bl_to_bu<=jj)
												{
													subformula[iii]->rob = hmin(subformula[iii]->rob,hmax(TempRight[iii * (jj+2) + bl_to_bu], RMin));
													RMin = hmax(RMin,TempLeft[iii * (jj+2) + bl_to_bu]); 
												}
											}
											subformula[iii]->rob_sec = subformula[iii]->rob;
										}
									}
								}
							}
						}
					}
				}
				break;

				case ALWAYS:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{							
							subformula[iii]->rob_sec = hmin(subformula[iii]->rob,subformula[kkk]->rob_sec );
						}
					}
				}
				else if(subformula[iii]->time.lbd.numf.inf == 0 && (subformula[iii]->time.lbd.numf.f_num != 0 || subformula[iii]->time.l_closed == 0) && subformula[iii]->time.ubd.numf.inf == 1)
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;
                            /* get time bound */
								if(1)
								{
									subformula[iii]->UBound = jj;
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par))&&subformula[iii]->LBindicator == 0)
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound_nxt) && tbi>=0)
											{
												TempL_nxt = subformula[iii]->time.lbd;
												if(ii + 1 <= jj)
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii+1].numf.f_num;
												}
												else
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;												
												}
												if (((*l_comp)(CurTime[tbi],TempL_nxt,p_par)))
												{
													subformula[iii]->LBound_nxt = tbi;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									bl = subformula[iii]->LBound;
									bl_plus = subformula[iii]->LBound_nxt;
								}
                            /* get time bound ends */
							if(subformula[iii]->LBound > subformula[iii]->UBound)
							{
								subformula[iii]->rob = subformula[iii]->rgt->rob;
								subformula[iii]->rob = SetToInf(+1,ii);
								subformula[iii]->rob_sec = subformula[iii]->rob;
							}
							else
							{
								lockon = 0;
								if(bl == intMax32bit || bl_plus == intMax32bit)
								{
									lockon = 1;
								}
								if(ii==jj)
								{
									subformula[iii]->rob_sec = subformula[kkk]->rob_sec;
									subformula[iii]->rob = subformula[iii]->rob_sec;
									subformula[iii]->rob = SetToInf(+1,ii);
								}
								else
								{
									if(lockon == 0)
									{
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(+1,ii);
										if(bl == intMax32bit || bl_plus == intMax32bit)
										{
											mexErrMsgTxt("mx_dp_taliro: lockon not working!");
										}
										if(bl>=0 && bl_plus>=bl)
										{
											for(bl_to_bl_plus = bl; bl_to_bl_plus <= bl_plus; bl_to_bl_plus++)
											{
												RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
											}
											subformula[iii]->rob_sec = hmin(subformula[iii]->rob,RMin);
										}
									}
									else if(lockon == 1)
									{
										if(bl == jj)
										{
											subformula[iii]->rob_sec = TempRight[iii * (jj+2) + jj];
										}
										else
										{
											RMin = subformula[iii]->rgt->rob;
											RMin = SetToInf(+1,ii);
											if(bl == intMax32bit)
											{
												mexErrMsgTxt("mx_dp_taliro: error when lockon ==1 !");
											}
											if(bl>=0 && bl_plus== intMax32bit)
											{
												for(bl_to_bl_plus = bl; bl_to_bl_plus <= jj; bl_to_bl_plus++)
												{
													RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
												}
												subformula[iii]->rob_sec = hmin(subformula[iii]->rob,RMin);
											}										
										}
									}
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;
							{
                            /*get time bound*/
								if(1)
								{
									if(subformula[iii]->UBound != -intMax32bit)
									{
										highi = subformula[iii]->UBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
                                /*get time bound ends*/
								{
									if(subformula[iii]->LBound > subformula[iii]->UBound)
									{
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(+1,ii);
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
									else
									{																
										bl = subformula[iii]->LBound;
										bu = subformula[iii]->UBound;
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(+1,ii);
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(+1,ii);
										for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
										{
											if(bl_to_bu<=jj)
											{
												RMin = hmin(RMin,TempRight[iii * (jj+2) + bl_to_bu]); 
												subformula[iii]->rob = hmin(subformula[iii]->rob,RMin);
											}
										}
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
								}
							}
						}
					}
				}
				break;

				case EVENTUALLY:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							subformula[iii]->rob_sec = hmax(subformula[iii]->rob,subformula[kkk]->rob_sec );
						}
					}				
				}
				else if(subformula[iii]->time.lbd.numf.inf == 0 && (subformula[iii]->time.lbd.numf.f_num != 0 || subformula[iii]->time.l_closed == 0) && subformula[iii]->time.ubd.numf.inf == 1)
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;
                                /*get time bound*/
								if(1)
								{
									subformula[iii]->UBound = jj;
									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par))&&subformula[iii]->LBindicator == 0)
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound_nxt) && tbi>=0)
											{
												TempL_nxt = subformula[iii]->time.lbd;
												if(ii + 1 <= jj)
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii+1].numf.f_num;
												}
												else
												{
													TempL_nxt.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;												
												}
												if (((*l_comp)(CurTime[tbi],TempL_nxt,p_par)))
												{
													subformula[iii]->LBound_nxt = tbi;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									bl = subformula[iii]->LBound;
									bl_plus = subformula[iii]->LBound_nxt;
								}
                            /* get time bound ends*/
							if(subformula[iii]->LBound > subformula[iii]->UBound)
							{
								subformula[iii]->rob = SetToInf(-1,ii);
								subformula[iii]->rob_sec = subformula[iii]->rob;
							}
							else
							{
								lockon = 0;
								if(bl == intMax32bit || bl_plus == intMax32bit)
								{
									lockon = 1;
								}
								if(ii==jj)
								{
									subformula[iii]->rob_sec = subformula[kkk]->rob_sec;
									subformula[iii]->rob = subformula[iii]->rob_sec;
									subformula[iii]->rob = SetToInf(-1,ii);
								}
								else
								{
									if(lockon == 0)
									{
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(-1,ii);
										if(bl == intMax32bit || bl_plus == intMax32bit)
										{
											mexErrMsgTxt("mx_dp_taliro: lockon not working!");
										}
										if(bl>=0 && bl_plus>=bl)
										{
											for(bl_to_bl_plus = bl; bl_to_bl_plus <= bl_plus; bl_to_bl_plus++)
											{
												RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
											}
											subformula[iii]->rob_sec = hmax(subformula[iii]->rob,RMin);
										}
									}
									else if(lockon == 1)
									{
										if(bl == jj)
										{
											subformula[iii]->rob_sec = TempRight[iii * (jj+2) + jj];
										}
										else
										{
											RMin = subformula[iii]->rgt->rob;
											RMin = SetToInf(-1,ii);
											if(bl == intMax32bit)
											{
												mexErrMsgTxt("mx_dp_taliro: error when lockon == 1!");
											}
											if(bl>=0 && bl_plus == intMax32bit)
											{
												for(bl_to_bl_plus = bl; bl_to_bl_plus <= jj; bl_to_bl_plus++)
												{
													RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bl_plus]);
												}
												subformula[iii]->rob_sec = hmax(subformula[iii]->rob,RMin);
											}										
										}
									}
								}
							}
						}
					}
				}
				else
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->rgt == subformula[kkk])
						{
							TempRight[iii * (jj+2) + ii] = subformula[kkk]->rob_sec;							
							{
                                /* get time bound*/
								if(1)
								{
									if(subformula[iii]->UBound != -intMax32bit)
                                    {
										highi = subformula[iii]->UBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = 0;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->UBound)&&subformula[iii]->UBindicator == 0 && tbi>=0)
											{
												TempU = subformula[iii]->time.ubd;
												if(subformula[iii]->time.ubd.numf.inf != 1)
												{
													TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
												}
												else
												{
													TempU.numf.f_num = infval;
												}
												if (((*u_comp)(CurTime[tbi],TempU,p_par))&&subformula[iii]->UBindicator == 0)
												{
													subformula[iii]->UBound = tbi;
													subformula[iii]->UBindicator = 1;
													*i_low = tbi - 1;
												}
											}
										}

									if(subformula[iii]->LBound!=intMax32bit)
									{
										highi = subformula[iii]->LBound;
									}
									else
									{
										highi = jj;
									}
									*i_low = highi -1;
										for(tbi = highi; tbi >= *i_low; tbi--)
										{
											if((subformula[iii]->BoundCheck == 0 || tbi <= subformula[iii]->LBound) && tbi>=0)
											{
												TempL = subformula[iii]->time.lbd;
												TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
												if (((*l_comp)(CurTime[tbi],TempL,p_par)))
												{
													subformula[iii]->LBound = tbi;
													*i_low = tbi - 1;
												}
											}
										}
									subformula[iii]->BoundCheck = 1;
									subformula[iii]->UBindicator = 0;
								}
								/* get time bound ends*/
								{
									if(subformula[iii]->LBound > subformula[iii]->UBound)
									{
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(-1,ii);
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
									else
									{
										bl = subformula[iii]->LBound;
										bu = subformula[iii]->UBound;
										RMin = subformula[iii]->rgt->rob;
										RMin = SetToInf(-1,ii);
										subformula[iii]->rob = subformula[iii]->rgt->rob;
										subformula[iii]->rob = SetToInf(-1,ii);
										for(bl_to_bu = bl; bl_to_bu <= bu; bl_to_bu++)
										{
											if(bl_to_bu<=jj && bl_to_bu <= bu)
											{
												RMin = hmax(RMin,TempRight[iii * (jj+2) + bl_to_bu]); 
												subformula[iii]->rob = hmax(subformula[iii]->rob,RMin);
											}
										}
										subformula[iii]->rob_sec = subformula[iii]->rob;
									}
								}
							}
						}
					}
				}
				break;

				case WEAKNEXT:
				if (subformula[iii]->time.l_closed)
					l_comp = &e_geq;
				else
					l_comp = &e_ge;
				if (subformula[iii]->time.u_closed)
					u_comp = &e_leq;
				else
					u_comp = &e_le;
				if (p_par->LTL||(subformula[iii]->time.lbd.numf.inf == 0 && subformula[iii]->time.lbd.numf.f_num == 0.0 && subformula[iii]->time.l_closed == 1 && subformula[iii]->time.ubd.numf.inf == 1))				
				{
					for(kkk = iii; kkk < jjj+1; kkk++)
					{
						if(subformula[iii]->lft == subformula[kkk])
						{
                            subformula[iii]->rob_sec = subformula[kkk]->rob;
						}
					}
				}
				else
				{
					if(1)
					{
						subformula[iii]->UBound = -intMax32bit;
						subformula[iii]->LBound = intMax32bit;
						for(tbi = jj; tbi >= 0; tbi--)
						{
                            TempU=subformula[iii]->time.ubd;
                            if(subformula[iii]->time.ubd.numf.inf != 1)
							{
								TempU.numf.f_num = subformula[iii]->time.ubd.numf.f_num + CurTime[ii].numf.f_num;
							}
							else
							{
								TempU.numf.f_num = infval;
							}                               
                            if ((*u_comp)(CurTime[tbi],TempU,p_par))
                            {
                                subformula[iii]->UBound = imax(subformula[iii]->UBound,tbi);
                            }
							TempL = subformula[iii]->time.lbd;
                            TempL.numf.f_num = subformula[iii]->time.lbd.numf.f_num + CurTime[ii].numf.f_num;
							if ((*l_comp)(CurTime[tbi],TempL,p_par))
							{
                                subformula[iii]->LBound = imin(subformula[iii]->LBound,tbi);
							}
						}
						subformula[iii]->BoundCheck = 1;
					}
                    if(subformula[iii]->LBound > subformula[iii]->UBound)
					{
						subformula[iii]->rob = SetToInf(1,ii);
						subformula[iii]->rob_sec = SetToInf(1,ii);
					}
					else
					{
						for(kkk = iii; kkk < jjj+1; kkk++)
						{
							if(subformula[iii]->lft == subformula[kkk])
							{
								if( ii>=subformula[iii]->LBound-1 && ii <=subformula[iii]->UBound-1)
								{
                                    subformula[iii]->rob_sec = subformula[kkk]->rob;
								}
								else
								{
            						subformula[iii]->rob = SetToInf(1,ii);
                        			subformula[iii]->rob_sec = SetToInf(1,ii);
								}
							}
						}
					}
				}
				break;
                    
				default:
                    mexPrintf("%s%d\n", "Node: ", (int)subformula[iii]->ntyp);
					mexErrMsgTxt("mx_dp_taliro: The above operator is not supported!\n");
					break;
			}
			iii--;
		}
        if (ii==0)
            subformula[1]->rob=subformula[1]->rob_sec;
	}
    
        
}



void moveNode2to1(Node **pt_node1, Node *node2)
{
	Node *tmpN;
	tmpN = (*pt_node1);
	(*pt_node1) = node2;
	releasenode(0,tmpN);
}

void moveNodeFromRight(Node **pt_node)
{
	Node *tmpN;
	tmpN = (*pt_node)->rgt;
	(*pt_node)->rgt = ZN;
	releasenode(1,(*pt_node));
	(*pt_node) = tmpN;
}

void moveNodeFromLeft(Node **pt_node)
{
	Node *tmpN;
	tmpN = (*pt_node)->lft;
	(*pt_node)->lft = ZN;
	releasenode(1,(*pt_node));
	(*pt_node) = tmpN;
}

Node *SimplifyNodeValue(Node *node)
{
	switch (node->ntyp)
	{
		/* Or node */
		case OR :
			node = SimplifyBoolConn(OR,node,moveNodeFromLeft,moveNodeFromRight,hmax);
			break;
			
		/* AND node	*/
		case AND :
			node = SimplifyBoolConn(AND,node,moveNodeFromRight,moveNodeFromLeft,hmin);
			break;

		default:
			break;
	}
	return(node);
}		

Node *SimplifyBoolConn(int BCon, Node *node, void (*MoveNodeL)(Node **), void (*MoveNodeR)(Node **), HyDis (*Comparison)(HyDis,HyDis))
{
	/* If both nodes are values, then convert to value node */
	if (node->lft->ntyp == VALUE && node->rgt->ntyp == VALUE)
	{
		node->ntyp = VALUE;
		node->rob = (*Comparison)(node->lft->rob, node->rgt->rob);
		moveNode2to1(&(node->rgt),ZN); 
		moveNode2to1(&(node->lft),ZN);
		return(node);
	}
	/* Simplify nested boolean connectives (of the same type) */ 
	/* If left leaf is a value and right node is a boolean connective */
	else if (node->lft->ntyp == VALUE && node->rgt->ntyp == BCon)
	{
		/* If the left node of the child boolean connective node is a value */
		if (node->rgt->lft->ntyp == VALUE)
		{
			node->lft->rob = (*Comparison)(node->lft->rob,node->rgt->lft->rob);
			moveNodeFromRight(&(node->rgt));
			/* node->rgt = moveNodeFromRight(node->rgt);*/
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* If the right node of the child boolean connective node is a value */
		if (node->rgt->rgt->ntyp == VALUE)
		{
			node->lft->rob = (*Comparison)(node->lft->rob,node->rgt->rgt->rob);
			moveNodeFromLeft(&(node->rgt));
			/* node->rgt = moveNodeFromLeft(node->rgt);*/
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* no value node found */
		return(node);
	}
	/* If right node is a value and left node is a boolean connective */
	else if (node->rgt->ntyp == VALUE && node->lft->ntyp == BCon)
	{
		/* If the left node of the child boolean connective node is a value */
		if (node->lft->lft->ntyp == VALUE)
		{
			node->rgt->rob = (*Comparison)(node->rgt->rob,node->lft->lft->rob);
			moveNodeFromRight(&(node->lft));
			/* node->lft = moveNodeFromRight(node->lft);*/
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* If the right node of the child boolean connective node is a value */
		if (node->lft->rgt->ntyp == VALUE)
		{
			node->rgt->rob = (*Comparison)(node->rgt->rob,node->lft->rgt->rob);
			moveNodeFromLeft(&(node->lft));
			/* node->lft = moveNodeFromLeft(node->lft);*/
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* no value node found */
		return(node);
	}
	/* If left leaf is top : case OR : +inf \/ phi <-> +inf */
	/* If left leaf is top : case AND : +inf /\ phi <-> phi */
	else if (node->lft->ntyp == TRUE)
	{
		(*MoveNodeL)(&node);
		if (BCon==AND)
			node = SimplifyNodeValue(node);
		return(node);
	}
	/* If left leaf is bottom : case OR : -inf \/ phi <-> phi */
	/* If left leaf is bottom : case AND : -inf /\ phi <-> -inf */
	else if (node->lft->ntyp == FALSE)
	{
		(*MoveNodeR)(&node);
		if (BCon==OR)
			node = SimplifyNodeValue(node);
		return(node);
	}
	/* If right leaf is top : case OR : phi \/ +inf <-> +inf */
	/* If right leaf is top : case AND : phi /\ +inf <-> phi */
	else if (node->rgt->ntyp == TRUE)
	{
		(*MoveNodeR)(&node);
		if (BCon==AND)
			node = SimplifyNodeValue(node);
		return(node);
	}
	/* If right leaf is bottom : case OR : phi \/ -inf <-> phi */
	/* If right leaf is bottom : case AND: phi /\ -inf <-> -inf */
	else if (node->rgt->ntyp == FALSE)
	{
		(*MoveNodeL)(&node);
		if (BCon==OR)
			node = SimplifyNodeValue(node);
		return(node);
	}
	else
		return(node);
}


HyDis hmax(HyDis inp1, HyDis inp2)
{
	if ((inp1.dl<inp2.dl) || ((inp1.dl==inp2.dl) && (inp1.ds<=inp2.ds)))
		return(inp2);
	else
		return(inp1);
}

HyDis hmin(HyDis inp1, HyDis inp2)
{
	if ((inp1.dl<inp2.dl) || ((inp1.dl==inp2.dl) && (inp1.ds<=inp2.ds)))
		return(inp1);
	else
		return(inp2);
}



/* Define operations on intervals */
/* Addition */
/* Double precision bounds are assumed */
Interval NumberPlusInter(Number num, Interval inter)
{
	if (inter.lbd.num.inf==0)
		inter.lbd.numf.f_num += num.numf.f_num;
	if (inter.ubd.num.inf==0)
		inter.ubd.numf.f_num += num.numf.f_num;
	return(inter);
}

/* Define comparisons over the extended real line */
int e_le(Number num1, Number num2, FWTaliroParam *p_par)
{
	if ((num1.num.inf==-1 && num2.num.inf>-1) || (num1.num.inf<1 && num2.num.inf==1))
		return(1);
	else if (num1.num.inf==0 && num2.num.inf==0)
	{
		if (p_par->ConOnSamples)
			return (num1.numi.i_num < num2.numi.i_num);
		else
			return (num1.numf.f_num < num2.numf.f_num);
	}
	else
		return(0);
}

/* Note : depending on the application it might be advisable to define		*/
/* 		  approximate equality for comparing double precision numbers		*/
int e_eq(Number num1, Number num2, FWTaliroParam *p_par)
{
	if (p_par->ConOnSamples)
		return(num1.num.inf==num2.num.inf && num1.numi.i_num==num2.numi.i_num);
	else
		return(num1.num.inf==num2.num.inf && num1.numf.f_num==num2.numf.f_num);
}

int e_leq(Number num1, Number num2, FWTaliroParam *p_par)
{
	return(e_le(num1,num2,p_par) || e_eq(num1,num2,p_par));
}

int e_ge(Number num1, Number num2, FWTaliroParam *p_par)
{
	return(!e_leq(num1,num2,p_par));
}

int e_geq(Number num1, Number num2, FWTaliroParam *p_par)
{
	return(!e_le(num1,num2,p_par));
}

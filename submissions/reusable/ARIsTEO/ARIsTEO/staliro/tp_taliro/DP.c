/***** mx_tp_taliro : DP.c *****/

/* Written by Adel Dokhanchi, ASU, U.S.A. for tp_taliro                   */
/* Copyright (c) 2017  Adel Dokhanchi							          */

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
				q->first = q->last = dupnode(phi);
				q->first = q->last = phi;							/* point first and last in the queue to the phi passed if the queue is empty*/
			}
			else {
				q->last = dupnode(phi);								/* stuff the phi passed in the last of the queue if the queue is not empty*/
				q->last = phi;
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
        q->first = dupnode(q->last);					/*  pop the first element out of the queue*/
		q->first = q->last;
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


int BFS(struct queue *q,Node *root,int *i)
{
	Node *p = NULL;
	if (root == NULL) return 0;

	enqueue(q,root);									/* enqueue the root node*/

	while (!queue_empty_p(q)) {
		if(!q->first){
			p = NULL;
		}
		else{											/* set subformula index		*/	
			if((*i)>199)
			{
				mexErrMsgTxt("mx_dp_taliro: The formula is too big to be stored in tree sturcture!");/* error message when amount of subformulas exceeds subMax*/
			}
			else
			{
				p = q->first;
				p->index = *i;
				(*i)++;
			}
		}
		
		dequeue(q);
		if (p->lft != NULL)
			BFS( q,p->lft,i);
		if (p->rgt != NULL)
			BFS( q,p->rgt,i);

	}
	return (*i-1);
} 

void print2file2(Node *n, FILE * f){
	if (!n) return;
	switch (n->ntyp)
	{
	case TRUE:
		fprintf(f, "  \"TRUE(%d)\"\n",n->index);
		break;
	case FALSE:
		fprintf(f, "  \"FALSE(%d)\"\n",n->index);
		break;
	case PREDICATE:
		fprintf(f, "  \"%s(%d)\"\n", n->sym->name,n->index);
		break;
	case NOT:
		fprintf(f, "  \"NOT(%d)\"\n",n->index);
		fprintf(f, "  \"NOT(%d)\" ->",n->index);
		print2file2(n->lft,f);
		break;
	case AND:
		fprintf(f, "  \"AND(%d)\"\n",n->index);
		fprintf(f, "  \"AND(%d)\" ->",n->index);
		print2file2(n->lft, f);
		fprintf(f, "  \"AND(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case OR:
		fprintf(f, "  \"OR(%d)\"\n",n->index);
		fprintf(f, "  \"OR(%d)\" ->",n->index);
		print2file2(n->lft, f);
		fprintf(f, "  \"OR(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case IMPLIES:
		fprintf(f, "  \"IMPLIES(%d)\"\n",n->index);
		fprintf(f, "  \"IMPLIES(%d)\" ->",n->index);
		print2file2(n->lft, f);
		fprintf(f, "  \"IMPLIES(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case NEXT:
		fprintf(f, "  \"NEXT(%d)\"\n",n->index);
		fprintf(f, "  \"NEXT(%d)\" ->",n->index);
		print2file2(n->lft, f);
		break;
	case WEAKNEXT:
		fprintf(f, "  \"WEAKNEXT(%d)\"\n",n->index);
		fprintf(f, "  \"WEAKNEXT(%d)\" ->",n->index);
		print2file2(n->lft, f);
		break;
	case U_OPER:
		fprintf(f, "  \"U(%d)\"\n",n->index);
		fprintf(f, "  \"U(%d)\" ->",n->index);
		print2file2(n->lft, f);
		fprintf(f, "  \"U(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case V_OPER:
		fprintf(f, "  \"R(%d)\"\n",n->index);
		fprintf(f, "  \"R(%d)\" ->",n->index);
		print2file2(n->lft, f);
		fprintf(f, "  \"R(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case EVENTUALLY:
		fprintf(f, "  \"<>(%d)\"\n",n->index);
		fprintf(f, "  \"<>(%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case ALWAYS:
		fprintf(f, "  \"[](%d)\"\n",n->index);
		fprintf(f, "  \"[](%d)\" ->",n->index);
		print2file2(n->rgt, f);
		break;
	case FREEZE_AT:
		fprintf(f, "  \"@ %s(%d)\"\n", n->sym->name,n->index);
		fprintf(f, "  \"@ %s(%d)\" ->", n->sym->name,n->index);
		print2file2(n->lft, f);
		break;
	case CONSTR_LE:
		fprintf(f, "  \"%s <= %f (index=%d)\"\n", n->sym->name, n->value.numf.f_num,n->index);
		break;
	case CONSTR_LS:
		fprintf(f, "  \"%s < %f (index=%d)\"\n", n->sym->name, n->value.numf.f_num,n->index);
		break;
	case CONSTR_EQ:
		fprintf(f, "  \"%s == %f (index=%d)\"\n", n->sym->name, n->value.numf.f_num,n->index);
		break;
	case CONSTR_GE:
		fprintf(f, "  \"%s >= %f (index=%d)\"\n", n->sym->name, n->value.numf.f_num,n->index);
		break;
	case CONSTR_GR:
		fprintf(f, "  \"%s > %f (index=%d)\"\n", n->sym->name, n->value.numf.f_num,n->index);
		break;
	default:
		break;
	}
}

void  setupIndeces(Node **subformula, Node *phi){
	subformula[phi->index] = phi;
	if (phi->ntyp == PREDICATE || phi->ntyp == TRUE || phi->ntyp == FALSE || phi->ntyp == VALUE || phi->ntyp == CONSTR_LE ||
		phi->ntyp == CONSTR_LS || phi->ntyp == CONSTR_EQ || phi->ntyp == CONSTR_GE || phi->ntyp == CONSTR_GR){
		phi->Lindex = 0;
		phi->Rindex = 0;
		return;
	}
	if (phi->lft != NULL){
		phi->Lindex = phi->lft->index;
		setupIndeces(subformula, phi->lft);
	}
	else{
		phi->Lindex = 0;
	}
	if (phi->rgt != NULL){
		phi->Rindex = phi->rgt->index;
		setupIndeces(subformula, phi->rgt);
	}
	else{
		phi->Rindex = 0;
	}
	return;
}

 void printTable(HyDis **MonitorTable, FWTaliroParam *p_par, int phi_size){
 	int  j, k;
     double   infval = mxGetInf();
 	for (j = 0; j < p_par->nSamp; j++){
 		mexPrintf("----------------");
 	}
 	mexPrintf("\n");
 	for (k = 1; k <= phi_size; k++){
 		mexPrintf("%d |", k);
 		for (j = 0; j < p_par->nSamp; j++)
 				mexPrintf(" %f |", MonitorTable[k][j].ds);
 		mexPrintf("\n");
 	}
 	for (j = 0; j < p_par->nSamp; j++){
 		mexPrintf("----------------");
 	}
 	mexPrintf("\n\n");
 }

void   DP_LTL(Node **subformula, HyDis **MonitorTable, FWTaliroParam *p_par, int phi_size, int i,int g){
	int  k;
	for (k = phi_size; k >= 1; k--){
        if(subformula[k]->group != g)
            continue;
		switch (subformula[k]->ntyp)
		{
		case TRUE:
		case FALSE:
		case PREDICATE:
		case CONSTR_LE:
		case CONSTR_GE:
		case CONSTR_LS:
		case CONSTR_GR:
		case CONSTR_EQ:
		case VALUE:
			break;
		case AND:
			MonitorTable[k][i] = hmin(MonitorTable[subformula[k]->Lindex][i], MonitorTable[subformula[k]->Rindex][i]);
			break;
		case OR:
			MonitorTable[k][i] = hmax(MonitorTable[subformula[k]->Lindex][i], MonitorTable[subformula[k]->Rindex][i]);
			break;
		case NOT:
			MonitorTable[k][i].ds = (-1)*(MonitorTable[subformula[k]->Lindex][i].ds);
			MonitorTable[k][i].dl = (-1)*(MonitorTable[subformula[k]->Lindex][i].dl);
			break;
		case NEXT:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = MonitorTable[subformula[k]->Lindex][i+1];
            else
                MonitorTable[k][i] = SetToInf(-1, i);
            break;
		case WEAKNEXT:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = MonitorTable[subformula[k]->Lindex][i+1];
            else
                MonitorTable[k][i] = SetToInf(+1, i);
            break;
		case ALWAYS:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = hmin( MonitorTable[k][i+1] , MonitorTable[subformula[k]->Rindex][i] );
            else
                MonitorTable[k][i] = MonitorTable[subformula[k]->Rindex][i];
            break;
		case EVENTUALLY:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = hmax( MonitorTable[k][i+1] , MonitorTable[subformula[k]->Rindex][i] );
            else
                MonitorTable[k][i] = MonitorTable[subformula[k]->Rindex][i];
            break;
		case U_OPER:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = hmax( MonitorTable[subformula[k]->Rindex][i] , hmin( MonitorTable[k][i+1] , MonitorTable[subformula[k]->Lindex][i] ) );
            else
                MonitorTable[k][i] = MonitorTable[subformula[k]->Rindex][i];
            break;
		case V_OPER:
            if( i<p_par->nSamp -1 )
                MonitorTable[k][i] = hmin( MonitorTable[subformula[k]->Rindex][i] , hmax( MonitorTable[k][i+1] , MonitorTable[subformula[k]->Lindex][i] ) );
            else
                MonitorTable[k][i] = MonitorTable[subformula[k]->Rindex][i];
            break;
		case FREEZE_AT:
            MonitorTable[k][i] = MonitorTable[subformula[k]->Lindex][i];
			break;
		default:
			break;
		}
	}
}

 void   Resolve_Constraint(Node **subformula, HyDis **MonitorTable, double * time_stamps, FWTaliroParam *p_par, int phi_size, int i,int g,double frz){
 	int  k;
 	for (k = phi_size; k >= 1; k--){
        if(subformula[k]->group != g)
             continue;
 		switch (subformula[k]->ntyp)
 		{
 		case CONSTR_LE:
             if(  time_stamps[i] - frz <= subformula[k]->value.numf.f_num )
                 MonitorTable[k][i] = SetToInf(+1, i);
             else
                 MonitorTable[k][i] = SetToInf(-1, i);
 			break;
 		case CONSTR_GE:
             if(  time_stamps[i] - frz >= subformula[k]->value.numf.f_num )
                 MonitorTable[k][i] = SetToInf(+1, i);
             else
                 MonitorTable[k][i] = SetToInf(-1, i);
 			break;
 		case CONSTR_LS:
             if(  time_stamps[i] - frz < subformula[k]->value.numf.f_num )
                 MonitorTable[k][i] = SetToInf(+1, i);
             else
                 MonitorTable[k][i] = SetToInf(-1, i);
 			break;
 		case CONSTR_GR:
             if(  time_stamps[i] - frz > subformula[k]->value.numf.f_num )
                 MonitorTable[k][i] = SetToInf(+1, i);
             else
                 MonitorTable[k][i] = SetToInf(-1, i);
 			break;
 		case CONSTR_EQ:
             if(  ( time_stamps[i] - frz ) == subformula[k]->value.numf.f_num )
                 MonitorTable[k][i] = SetToInf(+1, i);
             else
                 MonitorTable[k][i] = SetToInf(-1, i);
 			break;
		default:
 			break;
 		}
 	}
 }


mxArray *DP(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par, Miscellaneous *miscell)
{
	mwIndex ii = 0;							/* used for mapping predicate and passing state vector*/
	mwIndex jj = 0;							/* used for passing state vector*/
    mwIndex kk = 0;							/* used for passing state vector*/
	Symbol *tmpsym;
	double infval;							/*	infinite value*/
	double *sysTraj;							/*	state vector for system trajectory*/
	char last = 0;
	const char *fields[] = { "dl", "ds", "most_related_iteration", "most_related_predicate_index" };
	mxArray *tmp;
	int iii = 0;								/* used for check the index for subformula*/
	int jjj = 0;								/* length-1 of the subformula array */
	int *qi;
	int temp = 1;
	/* Initialize some variables for BFS */
    int phi_size;
	int maxTimeVariable=0;
    double freezeTimeValue;
    Node **subformula;/* subformula array as a cross-reference for TPTL phi*/
    HyDis **MonitorTable;/* monitoring table for TPTL phi*/
    double  *time_stamps;
	queue q;
	queue *Q = &q;
	init_queue(Q);							/*initial the queue*/
	qi = &temp;
	infval = mxGetInf();
	/*-----BFS for formula--------------*/
    phi_size=BFS(Q,phi,qi);
    /*  For GraphViz */ 
    /*FILE * pFile;
 	pFile = fopen("GraphViz.txt", "w");
 	if (pFile != NULL)
 	{
 		fputs("Check with: http://www.webgraphviz.com/ :", pFile);
 		fputs("\ndigraph G {\n", pFile);
 	}
	print2file2(phi, pFile);
	fputs("}\n", pFile);
	fclose(pFile);
    /*  For GraphViz */
    subformula=(Node**)emalloc(sizeof(Node*)*(phi_size+1));
	setupIndeces(subformula,phi);
	for (iii = 1; iii <= phi_size; iii++)			/*	check the index for subformula*/
	{
		if (iii != subformula[iii]->index)
			mexErrMsgTxt("mx_dp_taliro: Breadth-First-Traversal failed, subformulas are not matched to right index!");
	}
	MonitorTable = (HyDis**)emalloc(sizeof(HyDis*)*(phi_size + 1));
	/*mexPrintf("Number of sample is %d\nMonitoring Table is of the size %d x %d \n", p_par->nSamp, phi_size, p_par->nSamp);*/
	for (iii = 1; iii <= phi_size; iii++){
		MonitorTable[iii] = (HyDis*)emalloc(sizeof(HyDis)*(p_par->nSamp));
        if( subformula[iii]->group > maxTimeVariable)
            maxTimeVariable = subformula[iii]->group;
	}
	/*mexPrintf("Number of Time Variables is %d\n", maxTimeVariable);*/
	/* map each predicate to a set */
	for (ii = 0; ii<p_par->nPred; ii++)
	{
		if (predMap[ii].true_pred)
		{
			tmpsym = tl_lookup(predMap[ii].str, miscell);
			tmpsym->set = &(predMap[ii].set);
			tmpsym->Normalized = predMap[ii].Normalized;
			tmpsym->NormBounds = predMap[ii].NormBounds;
		}
	}
    if (p_par->nInp>4 && p_par->nCLG==1)
       sysTraj = (double *)emalloc((p_par->SysDim+1)*sizeof(double));
    else
    	sysTraj = (double *)emalloc((p_par->SysDim)*sizeof(double));
  
    time_stamps = (double *)emalloc((p_par->nSamp)*sizeof(double));
    /*mexPrintf("Total Samples is %d \n",p_par->nSamp);*/
	for (ii = 0; ii < p_par->nSamp; ii++){
        time_stamps[ii] = TStamps[ii];
		for (jj = 0; jj < p_par->SysDim; jj++)			/* time stamp for DP */
		{
			sysTraj[jj] = XTrace[ii+ jj*p_par->nSamp];
		}
        if (p_par->nInp>4 && p_par->nCLG==1)
            sysTraj[p_par->SysDim] = LTrace[ii];
		for (iii = 1; iii <= phi_size; iii++){
			switch (subformula[iii]->ntyp)
			{
			case TRUE:
				MonitorTable[iii][ii] = SetToInf(+1, ii);
				break;
			case FALSE:
				MonitorTable[iii][ii] = SetToInf(-1, ii);
				break;
			case PREDICATE:
                if (!subformula[iii]->sym->set)
            	{
            		mexPrintf("%s%s\n", "Predicate: ", subformula[iii]->sym->name);
            		mexErrMsgTxt("mx_tp_taliro: The set for the above predicate has not been defined!\n");
                }
                if ((p_par->nInp==6) && (subformula[iii]->sym->set->nloc>0))
                {
                    MonitorTable[iii][ii]=SignedHDist0(sysTraj,subformula[iii]->sym->set,p_par->SysDim,p_distData->LDist,p_par->tnLoc);
                    MonitorTable[iii][ii].iteration = ii;
                    MonitorTable[iii][ii].preindex = subformula[iii]->sym->index;
                }
                else
                {
    				MonitorTable[iii][ii].ds = SignedDist(sysTraj, subformula[iii]->sym->set, p_par->SysDim);
        			MonitorTable[iii][ii].dl = 0;
               		MonitorTable[iii][ii].iteration = ii;
            		MonitorTable[iii][ii].preindex = subformula[iii]->sym->index;
                }
				break;
			default:
				break;
			}
		}
	}
	if (p_par->LTL==1){
		for (jj = p_par->nSamp -1 ; jj >=0 ; jj--)			/* time stamps for DP*/
		{
			DP_LTL(subformula,MonitorTable, p_par, phi_size, (int)jj,0);
		}
	} else if (p_par->TPTL==1){
        for (ii = maxTimeVariable ; ii >=1 ; ii--)		/* time stamps for DP */
		{
            for (jj = 0; jj < p_par->nSamp ; jj++)			/* time stamps for DP*/
        	{
                freezeTimeValue = time_stamps[jj];
                for (kk = p_par->nSamp -1 ; kk >=jj ; kk--)
                    Resolve_Constraint(subformula,MonitorTable,time_stamps, p_par, phi_size, kk,ii,freezeTimeValue);
                for (kk = p_par->nSamp -1 ; kk >=jj ; kk--)
                	DP_LTL(subformula,MonitorTable, p_par, phi_size, kk,ii);
            }
        }
        for (jj = p_par->nSamp -1 ; jj >=0 ; jj--)			/* time stamps for DP */
		{
			DP_LTL(subformula,MonitorTable, p_par, phi_size, jj,0);
		}
	}
	/*  For Printing Monitoring Table */
	/*printTable(MonitorTable, p_par, phi_size);
    mexPrintf("TS |");
    for (jj = 0; jj < p_par->nSamp ; jj++)			/* time stamps for DP */
    {
        mexPrintf(" %f |",time_stamps[jj]);
    }
    mexPrintf("\n");
	/*  For Printing Monitoring Table */
	phi->rob = MonitorTable[1][0];
    
   	mxFree(time_stamps);
	for (iii = 1; iii <= phi_size; iii++){
		mxFree(MonitorTable[iii]);
	}
	mxFree(subformula);
	mxFree(MonitorTable);
    mxFree(sysTraj);
	tmp = mxCreateStructMatrix(1, 1, 4, fields);
	if (phi->ntyp == TRUE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(infval));
		return(tmp);
	}
	else if (phi->ntyp == FALSE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(-infval));
		return(tmp);
	}
	else
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(phi->rob.dl));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(phi->rob.ds));
		mxSetField(tmp, 0, "most_related_iteration", mxCreateDoubleScalar(phi->rob.iteration+1));
		mxSetField(tmp, 0, "most_related_predicate_index", mxCreateDoubleScalar(phi->rob.preindex));
		return(tmp);      
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

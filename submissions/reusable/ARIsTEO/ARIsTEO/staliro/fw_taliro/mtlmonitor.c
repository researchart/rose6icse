/***** mx_fw_taliro : mtlmonitor.c *****/
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

#include <time.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "monitor.h"

extern Number zero;

mxArray *monitor(Node *phi, PMap *predMap, double *XTrace, double *TStamps, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par)
{
	mwIndex ii = 0;
	mwIndex jj = 0;
	double t_cur = 0;
	double t_nxt = 0; 
	Symbol *tmpsym;
	double infval;
	double *xx;
	char last = 0;
	Number dt, ct;
	const char *fields[] = {"dl", "ds"};
    mxArray *tmp;

	/* Initialize some variables */
	infval = mxGetInf();
	dt = zero;
	ct = zero;

	/* reserve space for the state vector 
	   +1 for the current location appended at the end of the vector */
    xx = (double *)emalloc((p_par->SysDim+1)*sizeof(double));
		
	/* Read state vector */
	for (jj=0; jj<p_par->SysDim; jj++)
		xx[jj] = XTrace[jj*p_par->nSamp];
	if (p_par->nInp>4)
		xx[p_par->SysDim] = LTrace[0];

	/* read current time */
	if (!p_par->ConOnSamples && !p_par->LTL)
		t_cur = TStamps[0];

	/* this is only for next time operators */
	if (p_par->ConOnSamples)
		dt.numi.i_num = 1; 

	/* map each predicate to a set */
	for (ii=0;ii<p_par->nPred;ii++)
	{
		tmpsym = tl_lookup(predMap[ii].str);
		tmpsym->set = &(predMap[ii].set);
	}
  
	/* Compute the robustness degree */
	ii = 0;
	while(ii<p_par->nSamp-1)
	{
		
		/* Get time period if the logic is MTL */
		if (!p_par->LTL && !p_par->ConOnSamples)
		{
			t_nxt = TStamps[ii+1];
			dt.numf.f_num = t_nxt-t_cur;
			ct.numf.f_num = t_cur;
			t_cur = t_nxt;
		}
		
		/* Progress formula */
		phi = ProgRob(phi,xx,p_distData,&ct,&dt,&last,p_par);

		/* Update state vector */
		ii++;
 	    for (jj=0; jj<p_par->SysDim; jj++)
			xx[jj] = XTrace[ii+jj*p_par->nSamp];
		if (p_par->nInp>4)
			xx[p_par->SysDim] = LTrace[ii];
	}

	/* This is the last iteration */
	last = 1;
	/* Last timestamp */
	if (!p_par->ConOnSamples && !p_par->LTL)
		ct.numf.f_num = t_cur;
	phi = ProgRob(phi,xx,p_distData,&ct,&dt,&last,p_par);
	
	/* Done with xx */
	mxFree(xx);

	/* Output the result */
	tmp = mxCreateStructMatrix(1, 1, 2, fields);
	if (phi->ntyp==TRUE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(infval));
		return(tmp);
	}
	else if (phi->ntyp==FALSE)
	{
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(-infval));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(-infval));
		return(tmp);
	}
	else 
	{
		/* assertion */
		if (phi->ntyp!=VALUE)
			mexErrMsgTxt("mx_fw_taliro: There is a problem! This line should not have been reached! \n");
		mxSetField(tmp, 0, "dl", mxCreateDoubleScalar(phi->rob.dl));
		mxSetField(tmp, 0, "ds", mxCreateDoubleScalar(phi->rob.ds));
		return(tmp);
	}

}

Node *ProgRob(Node *phi, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par)
{	

	switch (phi->ntyp)
	{
		
		case TRUE:
		case FALSE:
		case VALUE:
			break;
			
		case PREDICATE:
			phi->ntyp = VALUE;
			if (!phi->sym->set)
			{
				mexPrintf("%s%s\n", "Predicate: ", phi->sym->name);
				mexErrMsgTxt("mx_fw_taliro: The set for the above predicate has not been defined!\n");
			}
			if ((p_par->nInp==6) && (phi->sym->set->nloc>0))
				phi->rob = SignedHDist0(xx,phi->sym->set,p_par->SysDim,p_distData->LDist,p_par->tnLoc);
			else if ((p_par->nInp==8) && (phi->sym->set->nloc>0))
				phi->rob = SignedHDistG(xx,phi->sym->set,p_par->SysDim,p_distData,p_par->tnLoc);
			else
			{
				phi->rob.dl = 0;
				phi->rob.ds = SignedDist(xx,phi->sym->set,p_par->SysDim);
			}
			break;

		case NOT: 
			phi->lft = ProgRob(phi->lft, xx, p_distData, pct, pdt, plast, p_par);
			if (phi->lft->ntyp==TRUE)
			{
				releasenode(1,phi);
				phi = False;
				break;
			}
			if (phi->lft->ntyp==FALSE)
			{
				releasenode(1,phi);
				phi = True;
				break;
			}
			if (phi->lft->ntyp==VALUE)
			{
				moveNode2to1(&phi,phi->lft);
				phi->rob.dl = -phi->rob.dl;
				phi->rob.ds = -phi->rob.ds;
				break;
			}
			break;
	
		case AND:
		case OR:
			phi->lft = ProgRob(phi->lft, xx, p_distData, pct, pdt, plast, p_par);
			phi->rgt = ProgRob(phi->rgt, xx, p_distData, pct, pdt, plast, p_par);
			phi = SimplifyNodeValue(phi);
			break;
			
		case NEXT:
			phi = NextOperator(phi,NEXT,*pdt,*plast,p_par);
			break;

		case WEAKNEXT:
			phi = NextOperator(phi,WEAKNEXT,*pdt,*plast,p_par); 
			break;

		/* phi_1 U_[a,b] phi_2 */
		case U_OPER:
			if (p_par->ConOnSamples || p_par->LTL)
				phi = TempOperator(phi, U_OPER, xx, p_distData, pct, pdt, plast, p_par);
			else
			{
				/* change to modified until */
				phi->ntyp = U_MOD;
				phi->time = NumberPlusInter(*pct,phi->time);
				phi = TempOperator(phi, U_OPER, xx, p_distData, pct, pdt, plast, p_par);
			}
			break;

		/* phi_1 V_[a,b] phi_2 */
		case V_OPER:
			if (p_par->ConOnSamples || p_par->LTL)
				phi = TempOperator(phi, V_OPER, xx, p_distData, pct, pdt, plast, p_par);
			else
			{
				/* change to modified until */
				phi->ntyp = V_MOD;
				phi->time = NumberPlusInter(*pct,phi->time);
				phi = TempOperator(phi, V_OPER, xx, p_distData, pct, pdt, plast, p_par);
			}
			break;

		case U_MOD:
			phi = TempOperator(phi, U_OPER, xx, p_distData, pct, pdt, plast, p_par);
			break;

		case V_MOD:
			phi = TempOperator(phi, V_OPER, xx, p_distData, pct, pdt, plast, p_par);
			break;

		default:
			mexPrintf("%s%s\n", "Node: ", phi->ntyp);
			mexErrMsgTxt("mx_fw_taliro: The above operator is not supported!\n");
	}
	return(phi);
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
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* If the right node of the child boolean connective node is a value */
		if (node->rgt->rgt->ntyp == VALUE)
		{
			node->lft->rob = (*Comparison)(node->lft->rob,node->rgt->rgt->rob);
			moveNodeFromLeft(&(node->rgt));
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
			node = SimplifyNodeValue(node);
			return(node);
		}
		/* If the right node of the child boolean connective node is a value */
		if (node->lft->rgt->ntyp == VALUE)
		{
			node->rgt->rob = (*Comparison)(node->rgt->rob,node->lft->rgt->rob);
			moveNodeFromLeft(&(node->lft));
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

Node *NextOperator(Node *phi, int Nxt, Number dt, char last, FWTaliroParam *p_par)
{
	Node *Const;
	int (*l_comp)(Number, Number, FWTaliroParam *);
	int (*u_comp)(Number, Number, FWTaliroParam *);

	if (Nxt==NEXT)
		Const = False;
	else if (Nxt==WEAKNEXT)
		Const = True;
	else
		mexErrMsgTxt("NextOperator is called with illegal arguments.\n");

	/* if the state is not the last in the trace */
	if (!last) 
	{
		/* if it is an LTL formula */
		if (p_par->LTL) 
			moveNode2to1(&phi,phi->lft); 
		/* if it is an MTL formula */
		else 
		{
			if (phi->time.l_closed)
				l_comp = &e_leq;
			else
				l_comp = &e_le;
			if (phi->time.u_closed)
				u_comp = &e_leq;
			else
				u_comp = &e_le;
			/* If the timing constraints are satisfied */
			if ((*l_comp)(phi->time.lbd,dt,p_par) && (*u_comp)(dt,phi->time.ubd,p_par)) 
				moveNode2to1(&phi,phi->lft);
			else
			{ 	
				releasenode(1,phi);
				phi = Const;
			}
		}
	}
	/* if the state is the last in the trace */
	else
	{ 	
		releasenode(1,phi);
		phi = Const;
	}
	return(phi);
}

Node *TempOperator(Node *phi, int Until, double *xx, DistCompData *p_distData, Number *pct, Number *pdt, char *plast, FWTaliroParam *p_par)
{
	Node *psi, *tmpnd, *Top, *Bottom;
	int BConAnd, BConOr;
	int (*l_comp)(Number, Number, FWTaliroParam *);
	int (*u_comp)(Number, Number, FWTaliroParam *);
	Number num;

	if (Until==U_OPER)
	{
		BConAnd = AND;
		BConOr = OR;
		Top = True;
		Bottom = False;
	}
	else
	{
		BConAnd = OR;
		BConOr = AND;
		Top = False;
		Bottom = True;
	}

	if (p_par->LTL) /* if it is an LTL formula */
	{
		if (!*plast) /* if it is NOT the last state in the trace */
		{
			psi = dupnode(phi);
			phi->lft = ProgRob(phi->lft, xx, p_distData, pct, pdt, plast, p_par);
			tmpnd = tl_nn(BConAnd,phi->lft,psi);
			tmpnd = SimplifyNodeValue(tmpnd);
			phi->rgt = ProgRob(phi->rgt, xx, p_distData, pct, pdt, plast, p_par);
			phi->ntyp = BConOr;
			phi->lft = tmpnd;
			phi = SimplifyNodeValue(phi);
		}
		/* if it IS the last state in the trace */
		else 
		{
			phi->rgt = ProgRob(phi->rgt, xx, p_distData, pct, pdt, plast, p_par);
			tmpnd = phi->rgt;
			phi->rgt = ZN;
			releasenode(1,phi);
			phi = tmpnd;
		}
		return(phi);
	}
	/* if it is an MTL formula */
	else 
	{
		/* determine comparison operators */
		if (phi->time.l_closed)
			l_comp = &e_leq;
		else
			l_comp = &e_le;
		if (phi->time.u_closed)
			u_comp = &e_leq;
		else
			u_comp = &e_le;

		/* Do we have to compare with zero? */
		if (p_par->ConOnSamples)
			num = zero;
		else
			num = *pct;

		/* if it is NOT the last state in the trace */
		if (!*plast) 
		{
			/* Progress left operant */
			if ((*u_comp)(num,phi->time.ubd,p_par))
			{
				psi = dupnode(phi);
				/* update time bounds */
				if (p_par->ConOnSamples)
				{
					if (psi->time.lbd.num.inf==0)
						psi->time.lbd.numi.i_num -= 1; 
					if (psi->time.ubd.num.inf==0)
						psi->time.ubd.numi.i_num -= 1; 
				}
				/* update node */
				phi->lft = ProgRob(phi->lft, xx, p_distData, pct, pdt, plast, p_par);
				tmpnd = tl_nn(BConAnd,phi->lft,psi);
				tmpnd = SimplifyNodeValue(tmpnd);
			}
			else
			{
				releasenode(1,phi);
				phi = Bottom;
				return(phi);
			}
			/* Progress right operant */
			if ((*l_comp)(phi->time.lbd,num,p_par) && (*u_comp)(num,phi->time.ubd,p_par))
				phi->rgt = ProgRob(phi->rgt, xx, p_distData, pct, pdt, plast, p_par);
			else
			{
				releasenode(1,phi->rgt);
				phi->rgt = Bottom;
			}
			phi->ntyp = BConOr;
			phi->lft = tmpnd;
			phi = SimplifyNodeValue(phi);
			return(phi);
		}
		/* if it IS the last state in the trace */
		else 
		{
			if ((*l_comp)(phi->time.lbd,num,p_par) && (*u_comp)(num,phi->time.ubd,p_par))
			{
				phi->rgt = ProgRob(phi->rgt, xx, p_distData, pct, pdt, plast, p_par);
				tmpnd = phi->rgt;
				phi->rgt = ZN;
				releasenode(1,phi);
				phi = tmpnd;
			}
			else
			{
				releasenode(1,phi);
				phi = Bottom;
			}
			return(phi);
		}
	}
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

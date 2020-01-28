/***** mx_debugging : mtl_vacuity.c *****/

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
#include <stdlib.h>
#include <math.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "vacuity.h"
#define BUFF_LEN 4096

extern Number zero;
extern char mtl[];
extern char ltl[];
/* extern Node *conjunctNodes[];
 extern Node *conjLits[];*/
extern int litNum;
extern int conjNum;
extern int antecNum;

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
   			node->lft = SimplifyNodeValue(node->lft);
			node->rgt = SimplifyNodeValue(node->rgt);
			node = SimplifyBoolConn(OR,node,moveNodeFromLeft,moveNodeFromRight,hmax);
			break;
			
		/* AND node	*/
		case AND :
   			node->lft = SimplifyNodeValue(node->lft);
			node->rgt = SimplifyNodeValue(node->rgt);
			node = SimplifyBoolConn(AND,node,moveNodeFromRight,moveNodeFromLeft,hmin);
			break;
		/* UNTIL node For Eventually Only */
		case U_OPER :
			node->lft = SimplifyNodeValue(node->lft);
			node->rgt = SimplifyNodeValue(node->rgt);
			if (node->rgt->ntyp == TRUE || node->rgt->ntyp == FALSE || node->lft->ntyp == FALSE)
				node = node->rgt;
			break;

		/* RELEASE node For Always Only */
		case V_OPER :
			node->lft = SimplifyNodeValue(node->lft);
			node->rgt = SimplifyNodeValue(node->rgt);
			if (node->rgt->ntyp == FALSE ||  node->rgt->ntyp == TRUE ||  node->lft->ntyp == TRUE)
				node = node->rgt;
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
	/*else if (node->rgt->ntyp == V_OPER || node->rgt->ntyp == U_OPER || node->lft->ntyp == V_OPER || node->lft->ntyp == U_OPER)
	{
		node->rgt = SimplifyNodeValue(node->rgt);
		node->lft = SimplifyNodeValue(node->lft);
	}*/
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

void mtl2qtl(Node *phi){
    char    *l,*u;
    int    ubd,lbd;
    char   operator[10],bounds[100];
    
    if (!phi) return;
    
    switch (phi->ntyp)
	{
		case TRUE:
            strcat(mtl,"true");
            break;
		case FALSE:
            strcat(mtl,"false");
            break;
        case PREDICATE: 
            strcat(mtl,phi->sym->name);
     	    break;
		case NOT: 
            strcat(mtl," ( !! ");
            mtl2qtl(phi->lft);
            strcat(mtl," ) ");
     	    break;
   		case AND:
            strcat(mtl," ( && ");
            mtl2qtl(phi->lft);  
            strcat(mtl," ");
            mtl2qtl(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case OR:
            strcat(mtl," ( || ");
            mtl2qtl(phi->lft);  
            strcat(mtl," ");
            mtl2qtl(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case U_OPER:
            if(phi->lft->ntyp==TRUE){
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1){
                        l="[";
                        strcpy (operator,"F_i");
                    }
                    else{
                        l="(";
                        strcpy (operator,"F_e");
                    }
                    if(phi->time.u_closed == 1){
                        u="]";
                        strcat(operator,"i");
                    }
                    else{
                        u=")";
                        strcat(operator,"e");
                        mexErrMsgTxt("mx_debugging: Left-open interval is not supported.");
                    }
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    sprintf(bounds," ( %s %d %d ",operator,lbd,ubd);
                    strcat(mtl,bounds);
                    mtl2qtl(phi->rgt);
                    strcat(mtl," ) ");
                }
                else
                    mexErrMsgTxt("mx_debugging: Unbounded Time Interval is not supported.");
            }
            else{
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1)
                        l="[";
                    else
                        l="(";
                    if(phi->time.u_closed == 1)
                        u="]";
                    else
                        mexErrMsgTxt("mx_debugging: Left-open interval is not supported.");
                        //u=")";
                    strcat(mtl," ( ");
                    mtl2qtl(phi->lft);  
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    strcat(mtl," ) U ( ");
                    mtl2qtl(phi->rgt);
                    strcat(mtl," ) ");
                }
                else
                    mexErrMsgTxt("mx_debugging: Unbounded Time Interval is not supported.");
            }
     	    break;
   		case V_OPER:
            if(phi->lft->ntyp==FALSE){
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1){
                        l="[";
                        strcpy (operator,"G_i");
                    }
                    else{
                        l="(";
                        strcpy (operator,"G_e");
                    }
                    if(phi->time.u_closed == 1){
                        u="]";
                        strcat(operator,"i");
                    }
                    else{
                        u=")";
                        strcat(operator,"e");
                        mexErrMsgTxt("mx_debugging: Left-open interval is not supported.");
                    }
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    sprintf(bounds," ( %s %d %d ",operator,lbd,ubd);
                    strcat(mtl,bounds);
                    mtl2qtl(phi->rgt);
                    strcat(mtl," ) ");
                }
                else
                    mexErrMsgTxt("mx_debugging: Unbounded Time Interval is not supported.");
            }
            else{
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1)
                        l="[";
                    else
                        l="(";
                    if(phi->time.u_closed == 1)
                        u="]";
                    else
                        mexErrMsgTxt("mx_debugging: Left-open interval is not supported.");
                        //u=")";
                    strcat(mtl," ( ");
                    mtl2qtl(phi->lft);  
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    strcat(mtl," ) R ( ");
                    mtl2qtl(phi->rgt);
                    strcat(mtl," ) ");
                }
                else
                    mexErrMsgTxt("mx_debugging: Unbounded Time Interval is not supported.");
            }
     	    break;
        default:
     	    break;
    }
}

void mtl_print(Node *phi){
    char    *l,*u;
    int    ubd,lbd;
    
    if (!phi) return;
    switch (phi->ntyp)
	{
		case TRUE:
            mexPrintf("true");
            break;
		case FALSE:
            mexPrintf("false");
            break;
        case PREDICATE: 
            mexPrintf("%s",phi->sym->name);
     	    break;
		case NOT: 
            mexPrintf(" ! ( ");
            mtl_print(phi->lft);
            mexPrintf(" ) ");
     	    break;
   		case AND:
            mexPrintf(" ");
            mtl_print(phi->lft);  
            mexPrintf(" /\\ ");
            mtl_print(phi->rgt);
            mexPrintf(" ");
     	    break;
   		case OR:
            mexPrintf(" ");
            mtl_print(phi->lft);  
            mexPrintf(" \\/ ");
            mtl_print(phi->rgt);
            mexPrintf(" ");
     	    break;
   		case IMPLIES:
            mexPrintf(" ");
            mtl_print(phi->lft);  
            mexPrintf(" -> ");
            mtl_print(phi->rgt);
            mexPrintf(" ");
     	    break;
        case NEXT:
			mexPrintf(" X ( ");
			mtl_print(phi->lft);
			mexPrintf(" ) ");
			break;
		case WEAKNEXT:
			mexPrintf(" W ( ");
			mtl_print(phi->lft);
			mexPrintf(" ) ");
			break;
   		case U_OPER:
            if(phi->lft->ntyp==TRUE){
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1){
                        l="[";
                    }
                    else{
                        l="(";
                    }
                    if(phi->time.u_closed == 1){
                        u="]";
                    }
                    else{
                        u=")";
                    }
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    mexPrintf(" <>_%s%d,%d%s ( ",l,lbd,ubd,u);
                    mtl_print(phi->rgt);
                    mexPrintf(" ) ");
                }
            }
            else{
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1)
                        l="[";
                    else
                        l="(";
                    if(phi->time.u_closed == 1)
                        u="]";
                    else
                        u=")";
                    mexPrintf(" ( ");
                    mtl_print(phi->lft);  
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    if(lbd==ubd)
                        mexErrMsgTxt("Interval Error: MITL interval's Lower Bound and Upper Bound should not be the same");
                    mexPrintf(" ) U_%s%d,%d%s ( ",l,lbd,ubd,u);
                    mtl_print(phi->rgt);
                    mexPrintf(" ) ");
                }
            }
     	    break;
   		case V_OPER:
            if(phi->lft->ntyp==FALSE){
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1){
                        l="[";
                    }
                    else{
                        l="(";
                    }
                    if(phi->time.u_closed == 1){
                        u="]";
                    }
                    else{
                        u=")";
                    }
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    mexPrintf(" []_%s%d,%d%s ( ",l,lbd,ubd,u);
                    mtl_print(phi->rgt);
                    mexPrintf(" ) ");
                }
            }
            else{
                if(phi->time.ubd.numf.inf==0){
                    if(phi->time.l_closed == 1)
                        l="[";
                    else
                        l="(";
                    if(phi->time.u_closed == 1)
                        u="]";
                    else
                        u=")";
                    mexPrintf(" ( ");
                    mtl_print(phi->lft);  
                    lbd=(int)floor(phi->time.lbd.numf.f_num);
                    ubd=(int)floor(phi->time.ubd.numf.f_num);
                    if(lbd==ubd)
                        mexErrMsgTxt("Interval Error: MITL interval's Lower Bound and Upper Bound should not be the same");
                    mexPrintf(" ) R_%s%d,%d%s ( ",l,lbd,ubd,u);
                    mtl_print(phi->rgt);
                    mexPrintf(" ) ");
                }
            }
     	    break;
        default:
     	    break;
    }
}


void countLiterals(Node *phi){
    if (!phi) return;
    
    if( phi->ntyp==NOT || phi->ntyp==PREDICATE ){
        litNum++;
        return;
    }
    else{
        countLiterals(phi->lft);
        countLiterals(phi->rgt);
    }
}

void countConjunctions(Node *phi){
    if (!phi) return;
    
    if( phi->ntyp==AND ){
        conjNum++;
        countConjunctions(phi->rgt);
        countConjunctions(phi->lft);
        return;
    }
    else{
        return;
    }
}

void findConjuncts(Node *phi,Node **conjNodes){
    if (!phi) return;
    
    if( phi->ntyp==AND ){
        if (phi->rgt->ntyp==AND){
            findConjuncts(phi->rgt,conjNodes);
        }
        else{
            conjNodes[conjNum] = phi->rgt;
            conjNum++;
        }
        if (phi->lft->ntyp==AND){
            findConjuncts(phi->lft,conjNodes);
        }
        else{
            conjNodes[conjNum] = phi->lft;
            conjNum++;
        }
        return;
    }
    else{
        return;
    }
}

 int changeLiteral(Node *phi,int litIndex,Node *falseNode){
     int isItFound;
     isItFound=0;
     
     if (!phi) return 0;
/*     else if (phi->ntyp==PREDICATE){
         litNum++;
         if(litNum==litIndex){
             phi=falseNode;
             return 1;
         }
     }*/
     else if(phi->rgt!=ZN){
         if( phi->rgt->ntyp==NOT || phi->rgt->ntyp==PREDICATE ){
             litNum++;
             if(litNum==litIndex){
                 phi->rgt=falseNode;
                 return 1;
             }
         }
         else{
             isItFound=changeLiteral(phi->rgt,litIndex,falseNode);
         }
         if (isItFound==1)
             return 1;
     }
     if(phi->lft!=ZN){
         if( phi->lft->ntyp==NOT || phi->lft->ntyp==PREDICATE ){
             litNum++;
             if(litNum==litIndex){
                 phi->lft=falseNode;
                 return 1;
             }
         }
         else{
             isItFound=changeLiteral(phi->lft,litIndex,falseNode);
         }
         if (isItFound==1)
             return 1;
     }
     
     if(isItFound!=0)
         mexErrMsgTxt("Error in branch"); 
     return 0;
     
/*      if( phi->ntyp==NOT || phi->ntyp==PREDICATE ){
          litNum++;
          return 1;
      }
      else{
          isItFound=changeLiteral(phi->lft,litIndex,falseNode);
          if (isItFound==1){
              phi->lft=falseNode;
              return 2;
          }else if(isItFound==2){
              return 2;
          }
          isItFound=changeLiteral(phi->rgt,litIndex,falseNode);
          if (isItFound==1){
              phi->rgt=falseNode;
              return 2;
          }else if(isItFound==2){
              return 2;
          }
      }*/
 }
 
void countAntecedent(Node *phi){
    if (!phi) 
        return;
    if(phi->antecedent==1){
        mexPrintf("Antecedent is ");
        mtl_print(phi);
        mexPrintf("\n");
        if(phi->observableWin.ubd.numf.inf==1)
            mexPrintf("Interval is %c%f,inf)\n",(phi->observableWin.l_closed?'[':'('),phi->observableWin.lbd.numf.f_num);
        else
            mexPrintf("Interval is %c%f,%f%c\n",(phi->observableWin.l_closed?'[':'('),phi->observableWin.lbd.numf.f_num,phi->observableWin.ubd.numf.f_num,(phi->observableWin.u_closed?']':')')
);
        antecNum++;
    }
    countAntecedent(phi->lft);
    countAntecedent(phi->rgt);
}


void extractAntecedent(Node *phi,int antcdIndex){
    char   interval[100];
    if (!phi) return;
    if(phi->antecedent==1){
        antecNum++;
        if(antecNum==antcdIndex){
            if(phi->observableWin.ubd.numf.inf == 0 && phi->observableWin.ubd.numf.f_num == 0){
                strcpy (mtl,"!(");
            }
            else{
                strcpy (mtl,"[]_");
                if(phi->observableWin.ubd.numf.inf==1)
                    sprintf(interval,"%c%f,inf) !(",(phi->observableWin.l_closed?'[':'('),phi->observableWin.lbd.numf.f_num);
                else
                    sprintf(interval,"%c%f,%f%c !(",(phi->observableWin.l_closed?'[':'('),phi->observableWin.lbd.numf.f_num,phi->observableWin.ubd.numf.f_num,(phi->observableWin.l_closed?']':')'));
                strcat(mtl, interval);
            }
            mtl2str(phi);
            return ;
        }
    }
    extractAntecedent(phi->lft,antcdIndex);
    extractAntecedent(phi->rgt,antcdIndex);
}


void mtl2str(Node *phi){
    char    *l,*u;
    double    ubd,lbd;
    char   temp_operator[100];
    
    if (!phi) return;
    
    switch (phi->ntyp)
	{
		case TRUE:
            strcat(mtl,"true");
            break;
		case FALSE:
            strcat(mtl,"false");
            break;
        case PREDICATE: 
            strcat(mtl,phi->sym->name);
     	    break;
		case NOT: 
            strcat(mtl," !( ");
            mtl2str(phi->lft);
            strcat(mtl," ) ");
     	    break;
   		case AND:
            strcat(mtl," ( ");
            mtl2str(phi->lft);  
            strcat(mtl," ) /\\ ( ");
            mtl2str(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case OR:
            strcat(mtl," ( ");
            mtl2str(phi->lft);  
            strcat(mtl," ) \\/ ( ");
            mtl2str(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case IMPLIES:
            strcat(mtl," ( ");
            mtl2str(phi->lft);  
            strcat(mtl," ) -> ( ");
            mtl2str(phi->rgt);
            strcat(mtl," ) ");
     	    break;
		case NEXT:
			if (phi->time.l_closed == 1 && phi->time.lbd.numf.f_num == 0 && phi->time.ubd.numf.inf == 1)
				strcat(mtl, " X ( ");
			else{
				if (phi->time.l_closed == 1){
					l = "[";
				}
				else{
					l = "(";
				}
				if (phi->time.u_closed == 1){
					u = "]";
				}
				else{
					u = ")";
				}
				lbd = phi->time.lbd.numf.f_num;
				if (phi->time.ubd.numf.inf == 0){
					ubd = phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " X_%s %f,%f %s ( ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " X_%s %f,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
			}
		    mtl2str(phi->lft);
			strcat(mtl, " ) ");
			break;
		case WEAKNEXT:
			if (phi->time.l_closed == 1 && phi->time.lbd.numf.f_num == 0 && phi->time.ubd.numf.inf == 1)
				strcat(mtl, " W ( ");
			else{
				if (phi->time.l_closed == 1){
					l = "[";
				}
				else{
					l = "(";
				}
				if (phi->time.u_closed == 1){
					u = "]";
				}
				else{
					u = ")";
				}
				lbd = phi->time.lbd.numf.f_num;
				if (phi->time.ubd.numf.inf == 0){
					ubd = phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " W_%s %f,%f %s ( ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " W_%s %f,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
			}
			mtl2str(phi->lft);
			strcat(mtl, " ) ");
			break;
		case U_OPER:
            if(phi->lft->ntyp==TRUE){
                if(phi->time.l_closed == 1){
                   l="[";
                }
                else{
                    l="(";
                }
                if(phi->time.u_closed == 1){
                    u="]";
                }
                else{
                     u=")";
                }
                lbd=phi->time.lbd.numf.f_num;
                if(phi->time.ubd.numf.inf==0){
                    ubd=phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " <>_%s %f,%f %s ( ", l, lbd, ubd, u);
                }else{
					sprintf(temp_operator, " <>_%s %f,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
                mtl2str(phi->rgt);
                strcat(mtl," ) ");
                
            }
            else{
                if(phi->time.l_closed == 1)
                    l="[";
                else
                    l="(";
                if(phi->time.u_closed == 1)
                    u="]";
                else
                    u=")";
                lbd=phi->time.lbd.numf.f_num;
                mtl2str(phi->lft);
                
				if (phi->time.ubd.numf.inf == 0){
					ubd = phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " U_%s %f,%f %s ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " U_%s %f,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);

                mtl2str(phi->rgt);
            }
     	    break;
   		case V_OPER:
            if(phi->lft->ntyp==FALSE){
                if(phi->time.l_closed == 1){
                   l="[";
                }
                else{
                    l="(";
                }
                if(phi->time.u_closed == 1){
                    u="]";
                }
                else{
                     u=")";
                }
                lbd=phi->time.lbd.numf.f_num;

				if (phi->time.ubd.numf.inf == 0){
					ubd = phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " []_%s %f,%f %s ( ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " []_%s %f,inf %s ( ", l, lbd, u);
				}

				strcat(mtl, temp_operator);
				mtl2str(phi->rgt);
                strcat(mtl," ) ");
            }
            else{
                if(phi->time.l_closed == 1)
                    l="[";
                else
                    l="(";
                if(phi->time.u_closed == 1)
                    u="]";
                else
                    u=")";
                lbd=phi->time.lbd.numf.f_num;
                mtl2str(phi->lft);
				if (phi->time.ubd.numf.inf == 0){
					ubd = phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " R_%s %f,%f %s ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " R_%s %f,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
				mtl2str(phi->rgt);
            }
     	    break;
        default:
     	    break;
    }
}
void mtl2strI(Node *phi){
    char    *l,*u;
    int    ubd,lbd;
    char   temp_operator[100];
    
    if (!phi) return;
    
    switch (phi->ntyp)
	{
		case TRUE:
            strcat(mtl,"true");
            break;
		case FALSE:
            strcat(mtl,"false");
            break;
        case PREDICATE: 
            strcat(mtl,phi->sym->name);
     	    break;
		case NOT: 
            strcat(mtl," !( ");
            mtl2strI(phi->lft);
            strcat(mtl," ) ");
     	    break;
   		case AND:
            strcat(mtl," ( ");
            mtl2strI(phi->lft);  
            strcat(mtl," ) /\\ ( ");
            mtl2strI(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case OR:
            strcat(mtl," ( ");
            mtl2strI(phi->lft);  
            strcat(mtl," ) \\/ ( ");
            mtl2strI(phi->rgt);
            strcat(mtl," ) ");
     	    break;
   		case IMPLIES:
            strcat(mtl," ( ");
            mtl2strI(phi->lft);  
            strcat(mtl," ) -> ( ");
            mtl2strI(phi->rgt);
            strcat(mtl," ) ");
     	    break;
		case NEXT:
			strcat(mtl, " X ( ");
			mtl2strI(phi->lft);
			strcat(mtl, " ) ");
			break;
		case WEAKNEXT:
			strcat(mtl, " W ( ");
			mtl2strI(phi->lft);
			strcat(mtl, " ) ");
			break;
		case U_OPER:
            if(phi->lft->ntyp==TRUE){
                if(phi->time.l_closed == 1){
                   l="[";
                }
                else{
                    l="(";
                }
                if(phi->time.u_closed == 1){
                    u="]";
                }
                else{
                     u=")";
                }
                lbd=(int)phi->time.lbd.numf.f_num;
                if(phi->time.ubd.numf.inf==0){
                    ubd=(int)phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " <>_%s %d,%d %s ( ", l, lbd, ubd, u);
                }else{
					sprintf(temp_operator, " <>_%s %d,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
                mtl2strI(phi->rgt);
                strcat(mtl," ) ");
                
            }
            else{
                if(phi->time.l_closed == 1)
                    l="[";
                else
                    l="(";
                if(phi->time.u_closed == 1)
                    u="]";
                else
                    u=")";
                lbd=(int)phi->time.lbd.numf.f_num;
                mtl2strI(phi->lft);
                
				if (phi->time.ubd.numf.inf == 0){
					ubd =(int) phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " U_%s %d,%d %s ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " U_%s %d,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);

                mtl2strI(phi->rgt);
            }
     	    break;
   		case V_OPER:
            if(phi->lft->ntyp==FALSE){
                if(phi->time.l_closed == 1){
                   l="[";
                }
                else{
                    l="(";
                }
                if(phi->time.u_closed == 1){
                    u="]";
                }
                else{
                     u=")";
                }
                lbd=(int)phi->time.lbd.numf.f_num;

				if (phi->time.ubd.numf.inf == 0){
					ubd = (int)phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " []_%s %d,%d %s ( ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " []_%s %d,inf %s ( ", l, lbd, u);
				}

				strcat(mtl, temp_operator);
				mtl2strI(phi->rgt);
                strcat(mtl," ) ");
            }
            else{
                if(phi->time.l_closed == 1)
                    l="[";
                else
                    l="(";
                if(phi->time.u_closed == 1)
                    u="]";
                else
                    u=")";
                lbd=(int)phi->time.lbd.numf.f_num;
                mtl2strI(phi->lft);
				if (phi->time.ubd.numf.inf == 0){
					ubd=(int)phi->time.ubd.numf.f_num;
					sprintf(temp_operator, " R_%s %d,%d %s ", l, lbd, ubd, u);
				}
				else{
					sprintf(temp_operator, " R_%s %d,inf %s ( ", l, lbd, u);
				}
				strcat(mtl, temp_operator);
				mtl2strI(phi->rgt);
            }
     	    break;
        default:
     	    break;
    }
}

void findIntervals(Node *phi,Interval bounds){
    Interval  timeWindow;
    if (!phi) 
        return;
    else
        phi->observableWin=bounds;
    
    switch (phi->ntyp)
	{
		case TRUE:
		case FALSE:
        case PREDICATE: 
     	    break;
		case NOT: 
            findIntervals(phi->lft,bounds);
     	    break;
   		case AND:
   		case OR:
   		case IMPLIES:
            findIntervals(phi->rgt,bounds);
            findIntervals(phi->lft,bounds);
     	    break;
        case U_OPER:
            if(phi->lft->ntyp==TRUE){
                timeWindow=phi->time;
                if(phi->time.l_closed==0 || bounds.l_closed==0)
                    timeWindow.l_closed=0;
                else
                    timeWindow.l_closed=1;
                if ( timeWindow.ubd.numf.inf == 1 || bounds.ubd.numf.inf == 1){
                    timeWindow.ubd.numf.inf = 1;
                    timeWindow.u_closed=0;
                }
                else{
                    if(phi->time.u_closed==0 || bounds.u_closed==0)
                        timeWindow.u_closed=0;
                    else
                        timeWindow.u_closed=1;
                    timeWindow.ubd.numf.f_num += bounds.ubd.numf.f_num;             
                }
                timeWindow.lbd.numf.f_num += bounds.lbd.numf.f_num;
                if(timeWindow.ubd.numf.inf == 0)
                    mexPrintf("findIntervals is %c%f,%f%c\n",(timeWindow.l_closed?'[':'('),timeWindow.lbd.numf.f_num,timeWindow.ubd.numf.f_num,(timeWindow.u_closed?']':')'));
                else
                    mexPrintf("findIntervals is %c%f,inf)\n",(timeWindow.l_closed?'[':'('),timeWindow.lbd.numf.f_num);
                findIntervals(phi->rgt,timeWindow);
            }
            else{
                mexErrMsgTxt("findIntervals: is not available for Until operator");
            }
            break;
        case V_OPER:
            if(phi->lft->ntyp==FALSE){
/*                if(phi->time.l_closed==0||phi->time.u_closed==0)
                    mexErrMsgTxt("findIntervals: intervals should be left and right closed");
                timeWindow.l_closed=1;
                timeWindow.u_closed=1;
                timeWindow=phi->time;*/
                timeWindow=phi->time;
                if ( timeWindow.ubd.numf.inf == 1 || bounds.ubd.numf.inf == 1){
                    timeWindow.ubd.numf.inf = 1;
                    timeWindow.u_closed=0;
                }
                else{
                    if(phi->time.u_closed==0 || bounds.u_closed==0)
                        timeWindow.u_closed=0;
                    else
                        timeWindow.u_closed=1;
                    timeWindow.ubd.numf.f_num += bounds.ubd.numf.f_num;             
                }
                timeWindow.lbd.numf.f_num += bounds.lbd.numf.f_num;
                if(timeWindow.ubd.numf.inf == 0)
                    mexPrintf("findIntervals is %c%f,%f%c\n",(timeWindow.l_closed?'[':'('),timeWindow.lbd.numf.f_num,timeWindow.ubd.numf.f_num,(timeWindow.u_closed?']':')'));
                else
                    mexPrintf("findIntervals is %c%f,inf)\n",(timeWindow.l_closed?'[':'('),timeWindow.lbd.numf.f_num);
                findIntervals(phi->rgt,timeWindow);
            }
            else{
                mexErrMsgTxt("findIntervals is not available for Release operator");
            }
            break;
		case NEXT:
		case WEAKNEXT:
            mexPrintf("findIntervals is not available for Next operator\n");
            break;
        default:
     	    break;
    }
    return;
}

int checkSingleTemporal (){
    char *Gs,*Fs;
    int hasF,hasG;
    hasF=0;
    hasG=0;
    Gs=strchr(mtl,'G');
    Fs=strchr(mtl,'F');
    if(Gs!=NULL)
        hasG=1;
    if(Fs!=NULL)
        hasF=1;
    if ( hasF==1 && hasG==1 )
        return 0;
    else
        return 1;
}

void mtl2ltl(Node *phi){
    
    if (!phi) return;
    
    switch (phi->ntyp)
	{
		case TRUE:
            strcat(ltl,"TRUE");
            break;
		case FALSE:
            strcat(ltl,"FALSE");
            break;
        case PREDICATE: 
            strcat(ltl,phi->sym->name);
     	    break;
		case NOT: 
            strcat(ltl," !( ");
            mtl2ltl(phi->lft);
            strcat(ltl," ) ");
     	    break;
   		case AND:
            strcat(ltl," ( ");
            mtl2ltl(phi->lft);  
            strcat(ltl," ) & ( ");
            mtl2ltl(phi->rgt);
            strcat(ltl," ) ");
     	    break;
   		case OR:
            strcat(ltl," ( ");
            mtl2ltl(phi->lft);  
            strcat(ltl," ) | ( ");
            mtl2ltl(phi->rgt);
            strcat(ltl," ) ");
     	    break;
   		case IMPLIES:
            strcat(ltl," ( ");
            mtl2ltl(phi->lft);  
            strcat(ltl," ) -> ( ");
            mtl2ltl(phi->rgt);
            strcat(ltl," ) ");
     	    break;
		case NEXT:
			strcat(ltl, " X ( ");
			mtl2ltl(phi->lft);
			strcat(ltl, " ) ");
			break;
		case WEAKNEXT:
			strcat(ltl, " X ( ");
			mtl2ltl(phi->lft);
			strcat(ltl, " ) ");
			break;
		case U_OPER:
            if(phi->lft->ntyp==TRUE){
				strcat(ltl, " F ( " );
                mtl2ltl(phi->rgt);
                strcat(ltl," ) ");
            }
            else{
                mtl2ltl(phi->lft);
				strcat(ltl, " U " );
                mtl2ltl(phi->rgt);
            }
     	    break;
   		case V_OPER:
            if(phi->lft->ntyp==FALSE){
				strcat(ltl, " G ( " );
                mtl2ltl(phi->rgt);
                strcat(ltl," ) ");
            }
            else{
                mtl2ltl(phi->lft);
				strcat(ltl, " R " );
                mtl2ltl(phi->rgt);
            }
     	    break;
        default:
     	    break;
    }
}

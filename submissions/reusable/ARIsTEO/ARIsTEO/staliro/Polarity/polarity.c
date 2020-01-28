/***** polarity : polarity.c *****/

/* Written by Hengyi Yang, Adel Dokhanchi, ASU, U.S.A. for polarity       */
/* Copyright (c) 2012  Hengyi Yang								          */
/* Copyright (c) 2013  Adel Dokhanchi							          */

/* Send bug-reports and/or questions to: fainekos@gmail.com			      */

/* the definition of polarity is defined in paper [Parametric Identification of Temporal Properties]*/

/* this function returns a polarity with regards to a predicate.b value and a formula(here a predicate.range value)*/
/* it also generate and organize a predicate list which indicates what predicates are used in the formula */

/* The main structure is similar to dp_taliro since it is developed based on dp_taliro*/
/*
	a new data structure Polarity and its field 'p->polar' is defined to indicate polarity and could be expanded in the future,
	p->polar is initialed with the value UNDEFINED_POLAR and would get its value in the polarity calculation section.
	output polarity values and its meaning is defined below:

	POSITIVE_POLAR = 1,
	NEGATIVE_POLAR = -1,
	MIXED_POLAR = 0,
	UNDEFINED_POLAR = 2,


	A parameter list would be shown as one output as well. 
	In the list it would output as many predicates/parameters defined in the .m function
	1 at position n stands for index n is a predicate used in the formula,
	2 at position n stands for index n is a time parameter used in the formula,
	3 at position n stands for index n is a predicate with magnitude parameter in the formula,
	0 at position n stands for index n is not used in the formmula.

	For example if user defined a test with predicates:

		i=1;
		pred(i).str = 'p1';
		pred(i).A = -1;
		pred(i).b = -1.5;
		pred(i).range = [-2 2];

		i=2;
		pred(i).par = 'q';
		pred(i).value = 0;
		pred(i).range = [0 1];

		i=3;
		pred(i).str = 'p2';
		pred(i).A = 1;
		pred(i).b = -1.5;
		pred(i).range = [-1 2];

        i=4;
        pred(i).str = 'p3';
        pred(i).par = 'p3par';
        pred(i).A = 1;
        pred(i).b = -1.5;
        pred(i).value = 5;
        pred(i).range = [4 6];
 
		and the formula is '[]_(0,q) p1 /\ p3'

		the the output of list_param would be:

		list_param = 

			1	2	0	3

*/


#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"

void make_predicate_list(Miscellaneous *miscell, Polarity *p);
int pos(int p);
int neg(int p);
int flip(int p);
int mix(int p1, int p2);
int enqueue(struct queue *q, Node *phi);
int dequeue(struct queue *q);
void init_queue(struct queue *q);
int queue_empty_p(const struct queue *q);
int BreadthFirstTraversal(struct queue *q,Node *root,Node *subformula[],int *i);


mxArray *get_polarity(Miscellaneous *miscell, PMap *predMap, Node *phi)
{
    /* Peer reviewed on 2013.07.22 by Dokhanchi, Adel */
    const char *fields[] = {"polarity", "index"};
    mxArray *tmp, *Array;
	/*mwSize *dims;*/
    mwSize dims;
	double *pr;
	int temp_pol = 0;
	Polarity *p;
	int i = 0,ii;
	int iii=0;								/* used for check the index for subformula*/
	int jjj=0;								/* length-1 of the subformula array */
	int *qi;
	int temp = 1;
#define subMax 200							/*	biggest number of iterations the subformula could store*/
	Node *subformula[subMax];				/* subformula array as a cross-reference for the phi*/

	/* Initialize some variables for BFS */
	queue q;
	queue *Q = &q;
	init_queue(Q);							/*initial the queue*/
	qi = &temp;
	/*----------------------------------*/

	p = (Polarity *)emalloc(sizeof(Polarity));
	p->polar = UNDEFINED_POLAR;
	tmp = mxCreateStructMatrix(1, 1, 2, fields);

	/*-----BFS for formula--------------*/
	jjj = BreadthFirstTraversal(Q,phi,subformula,qi);
		for(iii=1; iii<jjj; iii++)			/*	check the index for subformula*/
		{
			if(iii != subformula[iii]->index)
				mexErrMsgTxt("mx_dp_taliro: subformula not in right index!");
		}


	make_predicate_list(miscell, p);

/* predicate list*/
	pr = mxCalloc(miscell->dp_taliro_param.nPred, sizeof(double));
	/*dims = &(miscell->dp_taliro_param.nPred);*/
    dims = (mwSize)(miscell->dp_taliro_param.nPred);
	Array = mxCreateDoubleMatrix (1, dims, mxREAL);
	for(i = 0;i<miscell->dp_taliro_param.nPred;i++)
	{
		pr[i] = miscell->pList.pindex[i];
		if(pr[i] == -1)
		{
			pr[i] = 0;
		}
	}
	mxSetPr(Array,pr);
/* predicate list ends*/
	/* polarity calculation*/
	i = jjj;
	while(i>0)
	{
		switch (subformula[i]->ntyp)
		{
			case TRUE:
				subformula[i]->pol = UNDEFINED_POLAR;
				break;	
			case FALSE:
				subformula[i]->pol = UNDEFINED_POLAR;
				break;	
			case VALUE:
				subformula[i]->pol = UNDEFINED_POLAR;
				break;	
			case PREDICATE:
              		/* match predicate index*/
        		for(ii = 0; ii < miscell->dp_taliro_param.nPred; ii++)
                {
                    if(miscell->predMap[ii].str != NULL)
                    {
                        if(strcmp(subformula[i]->sym->name,predMap[ii].str)==0)
                        {
                            if(predMap[ii].parameter!=NULL){
                                subformula[i]->pol = POSITIVE_POLAR;   
                            }
                            else{
                   				subformula[i]->pol = UNDEFINED_POLAR;
                           }
                    	}
                    }
                }
				break;
			case NOT:
				subformula[i]->pol = flip(subformula[i]->lft->pol);
				/*p->polar = flip(p->polar);*/
				break;
			case AND:
				subformula[i]->pol = mix(subformula[i]->lft->pol, subformula[i]->rgt->pol);
				break;
			case OR:
				subformula[i]->pol = mix(subformula[i]->lft->pol, subformula[i]->rgt->pol);
				break;
			case NEXT:
				subformula[i]->pol = subformula[i]->lft->pol;
				break;
			case WEAKNEXT:
				subformula[i]->pol = subformula[i]->lft->pol;
				break;
			case ALWAYS:
				if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 0)
				{
					subformula[i]->pol = pos(subformula[i]->rgt->pol);
				}
				else if(subformula[i]->time.l_par == 0 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = neg(subformula[i]->rgt->pol);
				}
				else if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = MIXED_POLAR;
				}
				else
				{
					subformula[i]->pol = subformula[i]->rgt->pol;
				}
				break;
			case EVENTUALLY:
				if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 0)
				{
					subformula[i]->pol = neg(subformula[i]->rgt->pol);
				}
				else if(subformula[i]->time.l_par == 0 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = pos(subformula[i]->rgt->pol);
				}
				else if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = MIXED_POLAR;
				}
				else
				{
					subformula[i]->pol = subformula[i]->rgt->pol;
				}
				break;
			case U_OPER:
				if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 0)
				{
					temp_pol = NEGATIVE_POLAR;
					subformula[i]->pol = mix(temp_pol,mix(subformula[i]->lft->pol,subformula[i]->rgt->pol));
				}
				else if(subformula[i]->time.l_par == 0 && subformula[i]->time.u_par == 1)
				{
					temp_pol = POSITIVE_POLAR;
					subformula[i]->pol = mix(temp_pol,mix(subformula[i]->lft->pol,subformula[i]->rgt->pol));
				}
				else if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = MIXED_POLAR;
				}
				else
				{
					subformula[i]->pol = mix(subformula[i]->lft->pol,subformula[i]->rgt->pol);
				}
				break;
			case V_OPER:
				if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 0)
				{
/* 					temp_pol = POSITIVE_POLAR;
 					subformula[i]->pol = mix(temp_pol,mix(subformula[i]->lft->pol,subformula[i]->rgt->pol));*/
					temp_pol = NEGATIVE_POLAR;
					subformula[i]->pol = flip(mix(temp_pol,mix(flip(subformula[i]->lft->pol),flip(subformula[i]->rgt->pol))));
				}
				else if(subformula[i]->time.l_par == 0 && subformula[i]->time.u_par == 1)
				{
/* 					temp_pol = NEGATIVE_POLAR;
 					subformula[i]->pol = mix(temp_pol,mix(subformula[i]->lft->pol,subformula[i]->rgt->pol));*/
					temp_pol = POSITIVE_POLAR;
					subformula[i]->pol = flip(mix(temp_pol,mix(flip(subformula[i]->lft->pol),flip(subformula[i]->rgt->pol))));
				}
				else if(subformula[i]->time.l_par == 1 && subformula[i]->time.u_par == 1)
				{
					subformula[i]->pol = MIXED_POLAR;
				}
				else
				{
					subformula[i]->pol = mix(subformula[i]->lft->pol,subformula[i]->rgt->pol);
				}
				break;
			default:
				break;
		}
	i--;
	}
	/* polarity calculation ends*/


	mxSetField(tmp, 0, "polarity", mxCreateDoubleScalar(subformula[1]->pol));
	mxSetField(tmp, 0, "index", Array);

	return (tmp);
}

/* flip is used as if a negation operator of polarity*/
int flip(int p)
{
	int temp = 0;

	if(p == UNDEFINED_POLAR)
	{
		temp = UNDEFINED_POLAR;
	}
	else if(p == POSITIVE_POLAR)
	{
		temp = NEGATIVE_POLAR;
	}
	else if(p == NEGATIVE_POLAR)
	{
		temp = POSITIVE_POLAR;
	}
	else if(p == MIXED_POLAR)
	{
		temp = MIXED_POLAR;
	}
	else
	{
		mexErrMsgTxt("mx_dp_taliro: wrong type of polarity");
	}
	return(temp);
}

int mix(int p1, int p2)
{
	int temp = 0;

	if(p1 == UNDEFINED_POLAR && p2 == UNDEFINED_POLAR)
	{
		temp = UNDEFINED_POLAR;
	}
	else if((p1 == UNDEFINED_POLAR && p2 == NEGATIVE_POLAR)||(p1 == NEGATIVE_POLAR && p2 == UNDEFINED_POLAR))
	{
		temp = NEGATIVE_POLAR;
	}
	else if((p1 == UNDEFINED_POLAR && p2 == POSITIVE_POLAR)||(p1 == POSITIVE_POLAR && p2 == UNDEFINED_POLAR))
	{
		temp = POSITIVE_POLAR;
	}
	else if((p1 == MIXED_POLAR)||(p2 == MIXED_POLAR))
	{
		temp = MIXED_POLAR;
	}
	else if((p1 == NEGATIVE_POLAR && p2 == POSITIVE_POLAR)||(p1 == POSITIVE_POLAR && p2 == NEGATIVE_POLAR))
	{
		temp = MIXED_POLAR;
	}
	else if(p1 == NEGATIVE_POLAR && p2 == NEGATIVE_POLAR)
	{
		temp = NEGATIVE_POLAR;
	}
	else if(p1 == POSITIVE_POLAR && p2 == POSITIVE_POLAR)
	{
		temp = POSITIVE_POLAR;
	}
	else
	{
		mexErrMsgTxt("mx_dp_taliro: wrong type of polarity");
	}
	return(temp);
}

int pos(int p)
{
	int temp = 0;

	if(p == UNDEFINED_POLAR)
	{
		temp = POSITIVE_POLAR;
	}
	else if(p == POSITIVE_POLAR)
	{
		temp = POSITIVE_POLAR;
	}
	else if(p == NEGATIVE_POLAR)
	{
		temp = MIXED_POLAR;
	}
	else if(p == MIXED_POLAR)
	{
		temp = MIXED_POLAR;
	}
	else
	{
		mexErrMsgTxt("mx_dp_taliro: wrong type of polarity");
	}
	return(temp);
}

int neg(int p)
{
	int temp = 0;

	if(p == UNDEFINED_POLAR)
	{
		temp = NEGATIVE_POLAR;
	}
	else if(p == POSITIVE_POLAR)
	{
		temp = MIXED_POLAR;
	}
	else if(p == NEGATIVE_POLAR)
	{
		temp = NEGATIVE_POLAR;
	}
	else if(p == MIXED_POLAR)
	{
		temp = MIXED_POLAR;
	}
	else
	{
		mexErrMsgTxt("tl_monotonicity: undefined type of monotonicity");
	}
	return(temp);
}




void make_predicate_list(Miscellaneous *miscell, Polarity *p)
{
	bool sign;
	int i,t;
	sign = true;
	i = 0;
	t = 0;
	
	miscell->pList.total = miscell->dp_taliro_param.nPred;
	while(sign)
	{
		if(miscell->pList.pindex[i] == PRED || miscell->pList.pindex[i] == PREDPAR || miscell->pList.pindex[i] == PAR)
		{
			t++;
			miscell->pList.used = t;
		}
		else if(miscell->pList.pindex[i] == 0)
		{
			sign = false;
		}
		i++;
	}
}



int enqueue(struct queue *q, Node *phi)
{

    if (phi == NULL) {
 /*       errno = ENOMEM;*/
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
		else{											/* set subformula index*/
			p = dupnode(q->first);
			p = q->first;
			p->index = *i;
			subformula[*i] = dupnode(p);
			subformula[*i] = p;
			subformula[*i]->BoundCheck = 0;
			subformula[*i]->UBound = -infval;
			subformula[*i]->LBound = infval;
			subformula[*i]->LBound_nxt = infval;
			subformula[*i]->UBindicator = 0;
			subformula[*i]->LBindicator = 0;
			subformula[*i]->LBindicator_nxt = 0;
			subformula[*i]->loop_end = 0;

			(*i)++;
		}
		
		dequeue(q);
		if (p->lft != NULL)
			BreadthFirstTraversal( q,p->lft,subformula,i);
		if (p->rgt != NULL)
			BreadthFirstTraversal( q,p->rgt,subformula,i);

	}
	return (*i-1);
} 


/***** mx_polarity : mx_polarity.c *****/

/* Written by Georgios Fainekos, ASU, U.S.A. for fw_taliro                */
/* Modified by Hengyi Yang, ASU, U.S.A. for polarity                      */
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


#include <stdlib.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "param.h"


/* Default parameters */
#define BUFF_LEN 4096

mxArray *get_polarity(Miscellaneous *miscell, PMap *predMap, Node *phi);

/* Global variables */

/* Definitions */

char * emalloc(size_t n)
{       
	char *tmp;
	
	if (!(tmp = (char *) mxMalloc(n)))
        mexErrMsgTxt("mx_polarity: not enough memory!");
	memset(tmp, 0, n);
	return tmp;
}

int tl_Getchar(int *cnt, size_t hasuform, char *uform)
{
	if (*cnt < hasuform)
		return uform[(*cnt)++];
	(*cnt)++;
	return -1;
}

void tl_UnGetchar(int *cnt)
{
	if (*cnt > 0) (*cnt)--;
}

#define Binop(a)		\
		fprintf(miscell->tl_out, "(");	\
		dump(n->lft, miscell);		\
		fprintf(miscell->tl_out, a);	\
		dump(n->rgt, miscell);		\
		fprintf(miscell->tl_out, ")")

static void sdump(Node *n, char	*dumpbuf)
{
	switch (n->ntyp) {
	case PREDICATE:	strcat(dumpbuf, n->sym->name);
			break;
	case U_OPER:	strcat(dumpbuf, "U");
			goto common2;
	case V_OPER:	strcat(dumpbuf, "V");
			goto common2;
	case OR:	strcat(dumpbuf, "|");
			goto common2;
	case AND:	strcat(dumpbuf, "&");
common2:		sdump(n->rgt,dumpbuf);
common1:		sdump(n->lft,dumpbuf);
			break;
	case NEXT:	strcat(dumpbuf, "X");
			goto common1;
	case NOT:	strcat(dumpbuf, "!");
			goto common1;
	case TRUE:	strcat(dumpbuf, "T");
			break;
	case FALSE:	strcat(dumpbuf, "F");
			break;
	default:	strcat(dumpbuf, "?");
			break;
	}
}

Symbol *DoDump(Node *n, char *dumpbuf, Miscellaneous *miscell)
{
	if (!n) return ZS;

	if (n->ntyp == PREDICATE)
		return n->sym;

	dumpbuf[0] = '\0';
	sdump(n,dumpbuf);
	return tl_lookup(dumpbuf, miscell);
}

void dump(Node *n, Miscellaneous *miscell)
{
	if (!n) return;

	switch(n->ntyp) {
	case OR:	Binop(" || "); break;
	case AND:	Binop(" && "); break;
	case U_OPER:	Binop(" U ");  break;
	case V_OPER:	Binop(" V ");  break;
	case NEXT:
		fprintf(miscell->tl_out, "X");
		fprintf(miscell->tl_out, " (");
		dump(n->lft, miscell);
		fprintf(miscell->tl_out, ")");
		break;
	case NOT:
		fprintf(miscell->tl_out, "!");
		fprintf(miscell->tl_out, " (");
		dump(n->lft, miscell);
		fprintf(miscell->tl_out, ")");
		break;
	case FALSE:
		fprintf(miscell->tl_out, "false");
		break;
	case TRUE:
		fprintf(miscell->tl_out, "true");
		break;
	case PREDICATE:
		fprintf(miscell->tl_out, "(%s)", n->sym->name);
		break;
	case -1:
		fprintf(miscell->tl_out, " D ");
		break;
	default:
		printf("Unknown token: ");
		tl_explain(n->ntyp);
		break;
	}
}

void tl_explain(int n)
{
	switch (n) {
	case ALWAYS:	printf("[]"); break;
	case EVENTUALLY: printf("<>"); break;
	case IMPLIES:	printf("->"); break;
	case EQUIV:	printf("<->"); break;
	case PREDICATE:	printf("predicate"); break;
	case OR:	printf("||"); break;
	case AND:	printf("&&"); break;
	case NOT:	printf("!"); break;
	case U_OPER:	printf("U"); break;
	case V_OPER:	printf("V"); break;
	case NEXT:	printf("X"); break;
	case TRUE:	printf("true"); break;
	case FALSE:	printf("false"); break;
	case ';':	printf("end of formula"); break;
	default:	printf("%c", n); break;
	}
}

static void non_fatal(char *s1, char *s2, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	int i;

	printf("TaLiRo: ");
	if (s2)
		printf(s1, s2);
	else
		printf(s1);
	if ((*tl_yychar) != -1 && (*tl_yychar) != 0)
	{	printf(", saw '");
		tl_explain((*tl_yychar));
		printf("'");
	}
	printf("\nTaLiRo: %s\n---------", uform);
	for (i = 0; i < (*cnt); i++)
		printf("-");
	printf("^\n");
	fflush(stdout);
	(miscell->tl_errs)++;
}

void
tl_yyerror(char *s1, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
	Fatal(s1, (char *) 0, cnt, uform, tl_yychar, miscell);
}

void
Fatal(char *s1, char *s2, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
  non_fatal(s1, s2, cnt, uform, tl_yychar, miscell);
  tl_exit(0);
}

void fatal(char *s1, char *s2, int *cnt, char *uform, int *tl_yychar, Miscellaneous *miscell)
{
        non_fatal(s1, s2, cnt, uform, tl_yychar, miscell);
		tl_exit(0);
}

void put_uform(char *uform, Miscellaneous *miscell)
{
	fprintf(miscell->tl_out, "%s", uform);
}

void tl_exit(int i)
{
	mexErrMsgTxt("mx_polarity: unexpected error, tl_exit executed.");
}

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{	
	/* Peer reviewed on 2013.12.20 by Dokhanchi, Adel */
    /* Variables needed to process the input */
	int status, pstatus;
    mwSize buflen, pbuflen;
	size_t NElems;
	mwSize ndimA, ndimb, ndim, ndimR, ndimV, pdim;
	const mwSize *dimsA, *dimsb, *dims, *dimsR, *dimsV, *pardims;
	mwIndex jstruct, iii, jjj;
	mxArray *tmp;	
	/* Variables needed for monitor */
	Node *node;
	PMap *predMap; 
	int ll;
	bool par_on;
    bool str_on;
	bool initial_of_par;
	int npred, npar;

	static char	uform[BUFF_LEN];
	static size_t hasuform=0;
	static int *cnt;
	int temp = 0,i;
	Miscellaneous *miscell = (Miscellaneous *) emalloc(sizeof(Miscellaneous));
	int *tl_yychar = (int *) emalloc(sizeof(int));
	miscell->dp_taliro_param.LTL = 1; 
	miscell->dp_taliro_param.ConOnSamples = 0; 
	miscell->dp_taliro_param.SysDim = 0; 
	miscell->dp_taliro_param.nSamp = 0; 
	miscell->dp_taliro_param.nPred = 0; 
	miscell->dp_taliro_param.true_nPred = 0; 
	miscell->dp_taliro_param.tnLoc = 0; 
	miscell->dp_taliro_param.nInp = 0; 
	miscell->tl_errs = 0;
	miscell->type_temp = 0;

	/* Reset cnt to 0:
		cnt is the counter that points to the next symbol in the formula
		to be processed. This is a static variable and it retains its 
		value between Matlab calls to mx_polarity. */
	cnt = &temp;

	/* Other initializations */
	miscell->dp_taliro_param.nInp = nrhs;
	par_on = false;
	initial_of_par = false;
	npred = 0;
	npar= 0;
 
	/* Make sure the I/O are in the right form */
/*    if(nrhs != 2)
		mexErrMsgTxt("mx_polarity: 2 inputs are required.");
    else*/ if(nlhs > 1)
      mexErrMsgTxt("mx_polarity: Too many output arguments.");
    else if(!mxIsChar(prhs[0]))
      mexErrMsgTxt("mx_polarity: 1st input must be a string with TL formula.");
    else if(!mxIsStruct(prhs[1]))
      mexErrMsgTxt("mx_polarity: 2nd input must be a structure (predicate map).");

	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);

	/* Process inputs */

	/* Get the formula */
	ndim = mxGetNumberOfDimensions(prhs[0]);
	dims = mxGetDimensions(prhs[0]);
	buflen = dims[1]*sizeof(mxChar)+1;
	if (buflen >= BUFF_LEN)
	{
      mexPrintf("%s%d%s\n", "The formula must be less than ", BUFF_LEN," characters.");
      mexErrMsgTxt("mx_polarity: Formula too long.");
	}
	status = mxGetString(prhs[0], uform, buflen);   
    hasuform = strlen(uform);
    for (iii=0; iii<hasuform; iii++)
	{
		if (uform[iii] == '\t' || uform[iii] == '\"' || uform[iii] == '\n')						
			uform[iii] = ' ';
	}

	/* Get state trace */	    
/*	ndim = mxGetNumberOfDimensions(prhs[2]);
	if (ndim>2)
		mexErrMsgTxt("mx_polarity: The state trace is not in proper form!"); 
	dims = mxGetDimensions(prhs[2]);
	miscell->dp_taliro_param.nSamp = dims[0];
	miscell->dp_taliro_param.SysDim = dims[1];
	XTrace = mxGetPr(prhs[2]);

	/* Get time stamps */	   
/*	if (nrhs>3)
	{
		ndim = mxGetNumberOfDimensions(prhs[3]);
		if (ndim>2)
			mexErrMsgTxt("mx_polarity: The time stamp sequence is not in proper form!"); 
		dims = mxGetDimensions(prhs[3]);
		if (miscell->dp_taliro_param.nSamp != dims[0])
			mexErrMsgTxt("mx_polarity: The lengths of the time stamp sequence and the state trace do not match!"); 
		TStamps = mxGetPr(prhs[3]);
	}



	/* Get predicate map*/
    NElems = mxGetNumberOfElements(prhs[1]);
	miscell->dp_taliro_param.nPred = NElems;
	miscell->dp_taliro_param.true_nPred = NElems;
    if (NElems==0)
        mexErrMsgTxt("mx_polarity: the predicate map is empty!");
    predMap = (PMap *)emalloc(NElems*sizeof(PMap));
	miscell->parMap = (ParMap *)emalloc(NElems*sizeof(ParMap));
	miscell->predMap = (PMap *)emalloc(NElems*sizeof(PMap));

	/* Peer reviewed on 2013.06.08 by Dokhanchi, Adel */
    miscell->pList.pindex=(int *)emalloc(NElems*sizeof(int));

	/* initial predicate list*/
	for(ll = 0; ll < NElems; ll++)
	{
		miscell->pList.pindex[ll] = -1;
	}

	for(jstruct = 0; jstruct < NElems; jstruct++) 
	{
        str_on=false;
        par_on=false;
        /* Get predicate name */
        tmp = mxGetField(prhs[1], jstruct, "str");
		if(tmp == NULL)
		{
            str_on = false;
            tmp = mxGetField(prhs[1], jstruct, "par");
			if(tmp == NULL) 
			{
				mexPrintf("%s%d\n", "Predicate no ", jstruct+1);
				mexErrMsgTxt("mx_polarity: The above parameter must has 'str' field or 'par' field!");
			}
			else
			{	
				par_on = true;
				npar++;
			}
		}
		else
		{
			par_on = false;
            tmp = mxGetField(prhs[1], jstruct, "par");
            if(tmp != NULL){
				par_on = true;
				npar++;
            }
            str_on = true;
			npred++;
		}
		if( par_on==true)
		{
			tmp = mxGetField(prhs[1], jstruct, "par");
            if(!initial_of_par)
			{
				miscell->dp_taliro_param.true_nPred = jstruct;
				initial_of_par = true;
			}
			/* Get name of the parameter */
			pdim = mxGetNumberOfDimensions(tmp);
			pardims = mxGetDimensions(tmp);
        	/* Peer reviewed on 2013.07.10 by Dokhanchi, Adel */
			pbuflen = pardims[1]*sizeof(mxChar)+1;
			miscell->parMap[jstruct].str = (char *)emalloc(pbuflen);   
			miscell->parMap[jstruct].index = (int) jstruct;   
			predMap[jstruct].true_pred = false;
			pstatus = mxGetString(tmp, miscell->parMap[jstruct].str, pbuflen);
		
			/* Get value */
			tmp = mxGetField(prhs[1], jstruct, "value");
			if(tmp == NULL) /* TODO */
			{
				tmp = mxGetField(prhs[1], jstruct, "range");
				if(tmp == NULL)
				{
					mexPrintf("%s%s \n", "Predicate: ", miscell->parMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: both 'value' and 'range' do not exist!"); 
				}
			}
			else if(mxIsEmpty(tmp))
			{ 
				mexPrintf("%s%s \n", "Predicate: ", miscell->parMap[jstruct].str);
				mexErrMsgTxt("mx_polarity: Above predicate: 'value' is empty when 'par' exist which is not allowed !"); 
			}
			else
			{
    /* Peer reviewed on 2013.12.17 by Dokhanchi, Adel */
				ndimV = mxGetNumberOfDimensions(tmp);
                dimsV = mxGetDimensions(tmp);
                if(dimsV[1]!=1){
                     mexPrintf("%s%s ", "Predicate: ", miscell->parMap[jstruct].str);
                     mexErrMsgTxt("mx_polarity: Above predicate: 'value' dimention is not correct");
                  }
    /* Peer reviewed on 2013.12.17 by Dokhanchi, Adel */
                miscell->parMap[jstruct].value = mxGetPr(tmp);
			}

			/* Get range*/
			tmp = mxGetField(prhs[1], jstruct, "value");
			if(tmp != NULL)
			{	
				tmp = mxGetField(prhs[1], jstruct, "range");	
				if(tmp != NULL)
				{
/*					mexPrintf("%s%s \n", "Predicate: ", miscell->parMap[jstruct].str);
					mexPrintf("%s \n", "mx_polarity: The above parameter has both the 'value' field and 'range' field. So the value would take over the range");					
*/				}
			}
			tmp = mxGetField(prhs[1], jstruct, "range");
			if(tmp != NULL)
			{
    /* Peer reviewed on 2013.12.17 by Dokhanchi, Adel */
				ndimR = mxGetNumberOfDimensions(tmp);
				dimsR = mxGetDimensions(tmp);
                if(dimsR[1]!=2){
                    mexPrintf("%s%s ", "Predicate: ", miscell->parMap[jstruct].str);
                    mexErrMsgTxt("mx_polarity: Above predicate: 'range' dimention is not correct");
                }
    /* Peer reviewed on 2013.12.17 by Dokhanchi, Adel */
				miscell->parMap[jstruct].Range = mxGetPr(tmp);
                if( miscell->parMap[jstruct].value != NULL){
                     if(dimsR[0]!=dimsV[0])
                     {
                         mexPrintf("%s%s ", "Predicate: ", miscell->parMap[jstruct].str);
                         mexErrMsgTxt("mx_polarity: Above predicate: 'value' and 'range' do not have the same size");             
                     }
                     else{
                         for(i=0;i<dimsR[0];i++){/* Number of constraints */
                              if(miscell->parMap[jstruct].Range[i+0*dimsR[0]]>miscell->parMap[jstruct].value[i] || miscell->parMap[jstruct].Range[i+1*dimsR[0]]<miscell->parMap[jstruct].value[i]){
                                   mexPrintf("%s%s constraint%d Range [%f,%f] Value %f\n", "Predicate:", miscell->parMap[jstruct].str,i,miscell->parMap[jstruct].Range[i+0*dimsR[0]],miscell->parMap[jstruct].Range[i+1*dimsR[0]],miscell->parMap[jstruct].value[i]);
                                   mexErrMsgTxt("mx_polarity: Above predicate: 'value' is not inside the 'range'");                             
                              }
                         }                 
                     }
                }
			}
		}
        if( str_on==true )
		{
			/* Get name of the predicate */
            tmp = mxGetField(prhs[1], jstruct, "str");
			ndim = mxGetNumberOfDimensions(tmp);
			dims = mxGetDimensions(tmp);
			buflen = dims[1]*sizeof(mxChar)+1;
			predMap[jstruct].str = (char *)emalloc(buflen); 
			miscell->predMap[jstruct].str = (char *)emalloc(buflen); /* Unused*/
			predMap[jstruct].set.idx = (int) jstruct;   
			predMap[jstruct].true_pred = true;
			status = mxGetString(tmp, predMap[jstruct].str, buflen);
			status = mxGetString(tmp, miscell->predMap[jstruct].str, buflen);   /* Unused*/

			/* Get range*//* Unused*/
			tmp = mxGetField(prhs[1], jstruct, "range");
			if(tmp != NULL)/* Unused*/
			{/* Unused*/
				ndim = mxGetNumberOfDimensions(tmp);/* Unused*/
				dims = mxGetDimensions(tmp);/* Unused*/
				buflen = dims[1]*sizeof(mxChar)+1;/* Unused*/
				predMap[jstruct].Range = mxGetPr(tmp);/* Unused*/
				miscell->predMap[jstruct].Range = mxGetPr(tmp);/* Unused*/
			}
        
			/* Get set */
			tmp = mxGetField(prhs[1], jstruct, "A");
			/* If A is empty, then we should have an interval */
			if(tmp == NULL) /* TODO */
			{ 
				tmp = mxGetField(prhs[1], jstruct, "Int");
				if(tmp == NULL) {
					mexPrintf("%s%s \n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: Both fields 'A' and 'Int' do not exist!"); 
				}
			}
			else if(mxIsEmpty(tmp))
			{ 
				predMap[jstruct].set.isSetRn = true;
				predMap[jstruct].set.ncon = 0;
			}
			else
			{
				predMap[jstruct].set.isSetRn = false;
				/* get A */
				ndimA = mxGetNumberOfDimensions(tmp);
				if (ndimA>2)
				{
					mexPrintf("%s%s \n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: The set constraints are not in proper form!"); 
				}
				dimsA = mxGetDimensions(tmp);
				miscell->dp_taliro_param.SysDim = dimsA[1];/* the number of variables (columns) */
				if (miscell->dp_taliro_param.SysDim != dimsA[1])
				{
					mexPrintf("%s%s \n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: The dimensions of the set constraints and the state trace do not match!"); 
				}
				predMap[jstruct].set.ncon = dimsA[0]; /* the number of constraints (rows) */
				if (predMap[jstruct].set.ncon>2 && miscell->dp_taliro_param.SysDim==1)
				{
					mexPrintf("%s%s \n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: For 1D signals only up to two constraints per predicate are allowed!\n More than two are redundant!"); 
				}
				predMap[jstruct].set.A = (double **)emalloc(predMap[jstruct].set.ncon*sizeof(double*));
				for (iii=0; iii<predMap[jstruct].set.ncon; iii++)
				{
					predMap[jstruct].set.A[iii] = (double *)emalloc(miscell->dp_taliro_param.SysDim*sizeof(double));
					for (jjj=0; jjj<miscell->dp_taliro_param.SysDim; jjj++)
						predMap[jstruct].set.A[iii][jjj] = (mxGetPr(tmp))[iii+jjj*predMap[jstruct].set.ncon];
			    }
			
				/* get b */
				tmp = mxGetField(prhs[1], jstruct, "b");
				if(tmp == NULL) 
				{ 
					mexPrintf("%s%s\n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: Field 'b' is empty!"); 
				}
				ndimb = mxGetNumberOfDimensions(tmp);
				if (ndimb>2)
				{
					mexPrintf("%s%s\n", "Predicate: ", predMap[jstruct].str);
					mexErrMsgTxt("mx_polarity: Above predicate: The set constraints are not in proper form!"); 
				}
				dimsb = mxGetDimensions(tmp);
				if (predMap[jstruct].set.ncon != dimsb[0])
				{
					mexPrintf("%s%s\n", "Predicate: ", predMap[jstruct].str);
                    mexPrintf("A=%d  b=%d\n",(int)dimsA[0],(int)dimsb[0]);
					mexErrMsgTxt("mx_polarity: Above predicate: The number of constraints between A and b do not match!"); 
				}
                if(dimsb[1]!=1){
                    mexPrintf("%s%s ", "Predicate: ", predMap[jstruct].str);
                    mexErrMsgTxt("mx_polarity: Above predicate: the dimention of b is not correct");
                }
				predMap[jstruct].set.b = mxGetPr(tmp);
				if (predMap[jstruct].set.ncon==2 && miscell->dp_taliro_param.SysDim==1)
				{
					if ((predMap[jstruct].set.A[0][0]>0 && predMap[jstruct].set.A[1][0]>0) || 
						(predMap[jstruct].set.A[0][0]<0 && predMap[jstruct].set.A[1][0]<0))
					{
						mexPrintf("%s%s\n", "Predicate: ", predMap[jstruct].str);
						mexErrMsgTxt("mx_dp_taliro: Above predicate: The set has redundant constraints! Please remove redundant constraints."); 
					}
					if (!((predMap[jstruct].set.A[0][0]<0 && (predMap[jstruct].set.b[0]/predMap[jstruct].set.A[0][0]<=predMap[jstruct].set.b[1]/predMap[jstruct].set.A[1][0])) || 
						  (predMap[jstruct].set.A[1][0]<0 && (predMap[jstruct].set.b[1]/predMap[jstruct].set.A[1][0]<=predMap[jstruct].set.b[0]/predMap[jstruct].set.A[0][0]))))
					{
						mexPrintf("%s%s\n", "Predicate: ", predMap[jstruct].str);
						mexErrMsgTxt("mx_dp_taliro: Above predicate: The set is empty! Please modify the constraints."); 
					}
				}
                /* Peer reviewed on 2013.12.19 by Dokhanchi, Adel */
                /* Check that the number of constaint is equal to the value and the range of magnitude parameters */
                if(par_on==true){
                    if( miscell->parMap[jstruct].value != NULL)
                    {   
                        if(dimsV[0]!=predMap[jstruct].set.ncon){
                            mexPrintf("%s%s has confilict with %s%s\n", "Predicate: ", predMap[jstruct].str," parameter: ", miscell->parMap[jstruct].str);
                            mexErrMsgTxt("mx_polarity: Above predicate/parameter: The number of constraints for value is not correct"); 
                        }
                    }
                    if( miscell->parMap[jstruct].Range != NULL)
                    {   
                        dims = mxGetDimensions(tmp);
                        if(dimsR[0]!=predMap[jstruct].set.ncon){
                            mexPrintf("%s%s has confilict with %s%s\n", "Predicate: ", predMap[jstruct].str," parameter: ", miscell->parMap[jstruct].str);
                            mexErrMsgTxt("mx_polarity: Above predicate/parameter: The number of constraints for range is not correct"); 
                        }
                    }
                    predMap[jstruct].parameter=&(miscell->parMap[jstruct]);
                }
                else{
                    predMap[jstruct].parameter=NULL;
                }
                /* Peer reviewed on 2013.12.19 by Dokhanchi, Adel */
			}			
		}
    }

	miscell->tl_out = stdout; /* TODO: For parallerl toolbox all global variables must be removed */

	/* set up some variables wrt to timing constraints */
	miscell->zero2inf.l_closed = 1;
	miscell->zero2inf.u_closed = 0;
	miscell->emptyInter.l_closed = 0;
	miscell->emptyInter.u_closed = 0;
	if (miscell->dp_taliro_param.ConOnSamples)
	{	
		miscell->zero.numi.inf = 0;
		miscell->zero.numi.i_num = 0;
		miscell->inf.numi.inf = 1;
		miscell->inf.numi.i_num = 0;
		miscell->zero2inf.lbd = miscell->zero; 
		miscell->zero2inf.ubd = miscell->inf;
		miscell->emptyInter.lbd = miscell->zero;
		miscell->emptyInter.ubd = miscell->zero;
	}
	else
	{	
		miscell->zero.numf.inf = 0;
		miscell->zero.numf.f_num = 0.0;
		miscell->inf.numf.inf = 1;
		miscell->inf.numf.f_num = 0.0;
		miscell->zero2inf.lbd = miscell->zero;
		miscell->zero2inf.ubd = miscell->inf;
		miscell->emptyInter.lbd = miscell->zero;
		miscell->emptyInter.ubd = miscell->zero;
	}

	node = tl_parse(cnt,hasuform,uform, miscell, tl_yychar);

	plhs[0] = get_polarity(miscell, predMap, node);

	/* Peer reviewed on 2013.07.10 by Dokhanchi, Adel */
	/* Clean-up data for consecutive executions of dp_taliro */
	for (iii=0; iii<miscell->dp_taliro_param.true_nPred; iii++)
	{
		tl_clearlookup(predMap[iii].str, miscell);
		for (jjj=0;jjj<predMap[iii].set.ncon;jjj++)
			mxFree(predMap[iii].set.A[jjj]);
		mxFree(predMap[iii].set.A);
		mxFree(predMap[iii].str);
	}
	for (iii=0; iii<miscell->dp_taliro_param.true_nPred; iii++)
	{
        mxFree(miscell->parMap[iii].str);
	}
    mxFree(miscell->pList.pindex);
	mxFree(miscell->predMap);
	mxFree(miscell->parMap);
	mxFree(predMap);
	mxFree(tl_yychar);
	mxFree(miscell);
} 



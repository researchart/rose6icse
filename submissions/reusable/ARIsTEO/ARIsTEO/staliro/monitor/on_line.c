/*
 * File : on_line.c
 */


#define S_FUNCTION_NAME  on_line
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#include "mex.h"
#include "string.h"
#include "stdlib.h"
#include "math.h"
#include "ltl2tree.h"
#include "errno.h"
#include "time.h"

time_t tstart, tend; 

Symbol *symtab[Nhash+1];
static Node	*tl_level(int);

static int	prec[2][4] = {
	{ U_OPER,  V_OPER, S_OPER,  T_OPER},  /* left associative */
	{ OR, AND, IMPLIES, EQUIV, },	/* left associative */
};



#define Token(y)			tl_yylval = tl_nn(y,ZN,ZN); return y
#define MetricToken(y)		tl_yylval = tl_nn(y,ZN,ZN); tl_yylval->time = TimeCon; return y

typedef struct Cache {
	Node *before;
	Node *after;
	int same;
	struct Cache *nxt;
} Cache;

Cache	*stored = (Cache *) 0;
unsigned long	Caches, CacheHits;


static Node	*can = ZN;
HyDis monitor(Node *phi, PMap *predMap, double *XTrace, double TStamp, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par);

#define intMax32bit 2147483647
int enqueue(struct queue *q, Node *phi);
int dequeue(struct queue *q);
void init_queue(struct queue *q);
int queue_empty_p(const struct queue *q);
int BreadthFirstTraversal(struct queue *q,Node *root,int *i);
 void	*emalloc(size_t);	




void  computeHorizon(Miscellaneous *misc,Node *phi);

HyDis FH_Taliro(Miscellaneous *misc, PMap *predMap, double *XTrace, int i, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par);

void  UpdateRob(Miscellaneous *misc,int k,int horizon, double *xx, DistCompData *p_distData, FWTaliroParam *p_par);

void  UpdateRobPast(Miscellaneous *misc,int k,int horizon, double *xx, int i, DistCompData *p_distData, FWTaliroParam *p_par);
        
double infval;

HyDis  SetToInf(int sign);


int isItZero2Inf(Interval);
int isItAny2Inf(Interval);



void printTable(Miscellaneous*);

static void mdlSetInputPortDimensionInfo(SimStruct        *S,
                                  int_T            port,
                                  const DimsInfo_T *dimsInfo)
{
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
}
/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
   
    tstart = time(0);
    ssSetNumSFcnParams(S, 3);
    
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth( S, 0, DYNAMICALLY_SIZED );
    ssSetInputPortDataType( S, 0, DYNAMICALLY_TYPED );
    ssSetInputPortDirectFeedThrough( S, 0, 1 );
    
  
    
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 1);


    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_USE_TLC_WITH_ACCELERATOR);
    
}

#define MDL_INITIALIZE_CONDITIONS   /*Change to #undef to remove */
                                    /*function*/
#if defined(MDL_INITIALIZE_CONDITIONS)

static void mdlInitializeConditions(SimStruct *S)
{
  int i;
  real_T *xcont    = ssGetContStates(S);
  int_T   nCStates = ssGetNumContStates(S);
  real_T *xdisc    = ssGetRealDiscStates(S);
  int_T   nDStates = ssGetNumDiscStates(S);

  	
  
  for (i = 0; i < nCStates; i++) {
    *xcont++ = 1.0;
  }

  for (i = 0; i < nDStates; i++) {
    *xdisc++ = 1.0;
  }

}
#endif /* MDL_INITIALIZE_CONDITIONS */

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{

}


#define MDL_START                      /* Change to #undef to remove function */
#if defined(MDL_START)
/* Function: mdlStart ==========================================================
 * Abstract:
 *      Here we cache the state (true/false) of the XDATAEVENLYSPACED parameter.
 *      We do this primarily to illustrate how to "cache" parameter values (or
 *      information which is computed from parameter values) which do not change
 *      for the duration of the simulation (or in the generated code). In this
 *      case, rather than repeated calls to mxGetPr, we save the state once.
 *      This results in a slight increase in performance.
 */
static void mdlStart(SimStruct *S)
{
	    /* Variables needed to process the input */
    int status;
    char msg[256];
    mwSize buflen;
	size_t NElems;
	mwSize ndimA, ndimb,ndim;
	const mwSize *dimsA, *dimsb, *dims;
	mwIndex jstruct, iii, jjj;
    mxArray *tmp;
	int ii,jj; 
    int *qi;
	int temp = 1;
	queue q; 
	queue *Q = &q;
    Symbol *tmpsym;
    int_T  inputSize;
    int_T  systemDimention;
    Miscellaneous  * misc;
    misc = (Miscellaneous*)emalloc(sizeof(Miscellaneous));
    misc->Globally=0;
    misc->Prediction=0;
    systemDimention = (int)mxGetScalar((mxArray*)ssGetSFcnParam(S,0));
    misc->MTLformula = (mxArray*)ssGetSFcnParam(S,1);
    misc->ObservationMap = (mxArray*)ssGetSFcnParam(S,2);
    fw_taliro_param.SysDim=systemDimention;
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
    inputSize = ssGetInputPortWidth(S,0);
    fw_taliro_param.szInp=inputSize;
    if(inputSize>fw_taliro_param.SysDim&&inputSize%fw_taliro_param.SysDim==0){
        fw_taliro_param.predictorHorizon=(inputSize/(fw_taliro_param.SysDim))-1;
        ssPrintf(" Predictor Horizon is %d System Dimention is %d\n",fw_taliro_param.predictorHorizon,fw_taliro_param.SysDim);
        misc->Prediction=1;
        misc->XTrace=(double*)malloc(sizeof(double)*inputSize);
    }
    else if(inputSize==fw_taliro_param.SysDim){
        ssPrintf("System Dimention is %d\n",fw_taliro_param.SysDim); 
        misc->Prediction=0;
        misc->XTrace=(double*)malloc(sizeof(double)*fw_taliro_param.SysDim);
    }
    else{
        mexPrintf("The Input size %d should be devisible by the System Dimention %d !\n",inputSize,fw_taliro_param.SysDim);
        sprintf(msg,"The Input size %d should be devisible by the System Dimention %d !\n",inputSize,fw_taliro_param.SysDim);
        ssSetErrorStatus(S,msg);
        return;
    }

    
    dumpbuf=(char*)malloc(sizeof(char)*BUFF_LEN);
    uform=(char*)malloc(sizeof(char)*BUFF_LEN);
 	yytext=(char*)malloc(sizeof(char)*2048);

    cnt = 0;
    
  	infval = mxGetInf();	
    
    
    /* Get the formula */
   	ndim = mxGetNumberOfDimensions(misc->MTLformula);
	dims = mxGetDimensions(misc->MTLformula);
	buflen = dims[1]*sizeof(mxChar)+1;
	if (buflen >= BUFF_LEN)
	{
      mexPrintf("%s%d%s\n", "The formula must be less than ", BUFF_LEN," characters.");
      mexErrMsgTxt("Error: Formula too long.");
	}
	status = mxGetString(misc->MTLformula, uform, buflen);   
    hasuform = strlen(uform);
    for ( iii=0; iii<hasuform; iii++)
	{
		if (uform[iii] == '\t' || uform[iii] == '\"' || uform[iii] == '\n')						
			uform[iii] = ' ';
	}
    /*---------------------------------------------------------------------------------*/
    /* Get predicate map*/
    NElems = mxGetNumberOfElements(misc->ObservationMap);
	fw_taliro_param.nPred = NElems;
    if (NElems==0){
        mexPrintf("Error: the predicate map is empty!");
        sprintf(msg,"Error: the predicate map is empty!");
        ssSetErrorStatus(S,msg);
        return;
    }
    misc->predMap = (PMap *)emalloc(NElems*sizeof(PMap));
	for(jstruct = 0; jstruct < NElems; jstruct++) 
	{
        /* Get predicate name */
        tmp = mxGetField(misc->ObservationMap, jstruct, "str");
	    if(tmp == NULL) 
		{
            mexPrintf("%s%d\n", "Predicate no ", jstruct+1);
            mexPrintf("Error: The above predicate is missing the 'str' field!");
            sprintf(msg,"%s%d\n Error: The above predicate is missing the 'str' field!", "Predicate no ", jstruct+1);
            ssSetErrorStatus(S,msg);
            return;
	    }
		/* Get name of the predicate */
		ndim = mxGetNumberOfDimensions(tmp);
		dims = mxGetDimensions(tmp);
		buflen = dims[1]*sizeof(mxChar)+1;
        misc->predMap[jstruct].str = (char *)emalloc(buflen);   
        misc->predMap[jstruct].set.idx = (int) jstruct;   
        status = mxGetString(tmp, misc->predMap[jstruct].str, buflen);   
        
        /* Get set */
        tmp = mxGetField(misc->ObservationMap, jstruct, "A");
	    /* If A is empty, then we should have an interval */
		if(tmp == NULL)
		{ 
            tmp = mxGetField(misc->ObservationMap, jstruct, "Int");
			if(tmp == NULL) {
				mexPrintf("%s%s \n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: Both fields 'A' and 'Int' do not exist!"); 
                sprintf(msg,"%s%s \n Error: Above predicate: Both fields 'A' and 'Int' do not exist!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
	    }
		else if(mxIsEmpty(tmp))
		{ 
			misc->predMap[jstruct].set.isSetRn = true;
			misc->predMap[jstruct].set.ncon = 0;
	    }
		else{
			misc->predMap[jstruct].set.isSetRn = false;
			/* get A */
		    ndimA = mxGetNumberOfDimensions(tmp);
			if (ndimA>2)
			{
				mexPrintf("%s%s \n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: The set constraints are not in proper form!"); 
                sprintf(msg,"%s%s \nError: Above predicate: The set constraints are not in proper form!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
			dimsA = mxGetDimensions(tmp);
			if (fw_taliro_param.SysDim != dimsA[1])
			{
				mexPrintf("%s%s \n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: The dimensions of the set constraints and the state trace do not match!"); 
                sprintf(msg,"%s%s \nError: Above predicate: The dimensions of the set constraints and the state trace do not match!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
			misc->predMap[jstruct].set.ncon = dimsA[0]; /* the number of constraints */
			if (misc->predMap[jstruct].set.ncon>2 && fw_taliro_param.SysDim==1)
			{
				mexPrintf("%s%s \n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: For 1D signals only up to two constraints per predicate are allowed!\n More than two are redundant!"); 
                sprintf(msg,"%s%s \nError: Above predicate: For 1D signals only up to two constraints per predicate are allowed!\n More than two are redundant!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
            
			misc->predMap[jstruct].set.A = (double **)emalloc(misc->predMap[jstruct].set.ncon*sizeof(double*));
			for (iii=0; iii<misc->predMap[jstruct].set.ncon; iii++)
			{
                misc->predMap[jstruct].set.A[iii] = (double *)emalloc(fw_taliro_param.SysDim*sizeof(double));
		        for (jjj=0; jjj<fw_taliro_param.SysDim; jjj++)
					misc->predMap[jstruct].set.A[iii][jjj] = (mxGetPr(tmp))[iii+jjj*misc->predMap[jstruct].set.ncon];
		   }
			
			/* get b */
			tmp = mxGetField(misc->ObservationMap, jstruct, "b");
			if(tmp == NULL) 
			{ 
				mexPrintf("%s%s\n", "Predicate: ", misc->predMap[jstruct].str);
				mexErrMsgTxt("Error: Above predicate: Field 'b' is empty!"); 
                sprintf(msg,"%s%s\nError: Above predicate: Field 'b' is empty!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
			ndimb = mxGetNumberOfDimensions(tmp);
			if (ndimb>2)
			{
				mexPrintf("%s%s\n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: The set constraints are not in proper form!"); 
                sprintf(msg,"%s%s\nError: Above predicate: The set constraints are not in proper form!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
			dimsb = mxGetDimensions(tmp);
			if (misc->predMap[jstruct].set.ncon != dimsb[0])
			{
				mexPrintf("%s%s\n", "Predicate: ", misc->predMap[jstruct].str);
				mexPrintf("Error: Above predicate: The number of constraints between A and b do not match!"); 
                sprintf(msg,"%s%s\nError: Above predicate: The number of constraints between A and b do not match!", "Predicate: ", misc->predMap[jstruct].str);
                ssSetErrorStatus(S,msg);
                return;
			}
			misc->predMap[jstruct].set.b = mxGetPr(tmp);
			if (misc->predMap[jstruct].set.ncon==2 && fw_taliro_param.SysDim==1)
			{
				if ((misc->predMap[jstruct].set.A[0][0]>0 && misc->predMap[jstruct].set.A[1][0]>0) || 
					(misc->predMap[jstruct].set.A[0][0]<0 && misc->predMap[jstruct].set.A[1][0]<0) ||
					!((misc->predMap[jstruct].set.A[0][0]<0 && (misc->predMap[jstruct].set.A[0][0]/misc->predMap[jstruct].set.b[0]<=misc->predMap[jstruct].set.A[1][0]/misc->predMap[jstruct].set.b[1])) || 
					  (misc->predMap[jstruct].set.A[1][0]<0 && (misc->predMap[jstruct].set.A[1][0]/misc->predMap[jstruct].set.b[1]<=misc->predMap[jstruct].set.A[0][0]/misc->predMap[jstruct].set.b[0]))))
				{
					mexPrintf("%s%s\n", "Predicate: ", misc->predMap[jstruct].str);
					mexPrintf("Error: Above predicate: The constraint is the empty set!");
                    sprintf(msg,"%s%s\nError: Above predicate: The constraint is the empty set!", "Predicate: ", misc->predMap[jstruct].str);
                    ssSetErrorStatus(S,msg);
                    return;
				}
			}
		}

        
    }
	;
    /*---------------------------------------------------------------------------------*/
    
  	zero2inf.l_closed = 1;
	zero2inf.u_closed = 0;
	emptyInter.l_closed = 0;
	emptyInter.u_closed = 0;

		zero.numf.inf = 0;
		zero.numf.f_num = 0.0;
		inf.numf.inf = 1;
		inf.numf.f_num = 0.0;
		zero2inf.lbd = zero;
		zero2inf.ubd = inf;
		emptyInter.lbd = zero;
		emptyInter.ubd = zero;

    misc->node = tl_parse();
    /* Initialize some variables for BFS */
	init_queue(Q);	/*initial the queue*/
	qi = &temp;

	/*-----BFS for formula--------------*/
	misc->phi_size=BreadthFirstTraversal(Q,misc->node,qi);
    
    misc->subformula=(Node**)emalloc(sizeof(Node*)*(misc->phi_size+1));
    
    computeHorizon(misc,misc->node);
    misc->FH = misc->node->FiniteHorizon;
    misc->History = misc->node->History+misc->FH;/*Hst=Hrz+hst(\phi)*/
    
 	ssPrintf("The size of the formula is %d   Finite Horizon=%d   History=%d  \n",misc->phi_size,misc->FH,misc->History);

    misc->RobTable=(HyDis**)emalloc(sizeof(HyDis*)*(misc->phi_size+1));
    misc->pre=(HyDis*)emalloc(sizeof(HyDis)*(misc->phi_size+1));
    for(ii=0;ii<=misc->phi_size;ii++)
        misc->RobTable[ii]=(HyDis*)emalloc(sizeof(HyDis)*(misc->FH+misc->History+1));
    for(ii=1;ii<=misc->phi_size;ii++){
         switch(misc->subformula[ii]->ntyp) {
		    case U_OPER:
		    case S_OPER:
			case EVENTUALLY:
			case EVENTUALLY_PAST:
			case PREV:
			case NEXT:
		        for(jj=0;jj<=(misc->FH+misc->History);jj++){
			        misc->RobTable[ii][jj]=SetToInf(-1);
				}

		        break;
			case V_OPER:
			case T_OPER:
			case ALWAYS:
			case ALWAYS_PAST:
			case WEAKPREV:
			case WEAKNEXT:
		        for(jj=0;jj<=(misc->FH+misc->History);jj++){
		            misc->RobTable[ii][jj]=SetToInf(+1);
				}
				break;
		default:
		        for(jj=0;jj<=(misc->FH+misc->History);jj++){
		            misc->RobTable[ii][jj].ds=0;
		            misc->RobTable[ii][jj].dl=0;
				}
				break;
		}

	}
    misc->lastRobustness=SetToInf(+1);
    
    
   	/* map each predicate to a set */
    for (ii=0;ii<fw_taliro_param.nPred;ii++)
	{
		tmpsym = tl_lookup(misc->predMap[ii].str);
		tmpsym->set = &(misc->predMap[ii].set);
	}
     for(ii=1;ii<=misc->phi_size;ii++){
         if(misc->subformula[ii]->ntyp==PREDICATE) {
              if(!misc->subformula[ii]->sym->set){
                 mexPrintf("%s%s\n", "Predicate: ", misc->subformula[ii]->sym->name);
                 mexPrintf("Error: The set for the above predicate has not been defined!\n");
                 sprintf(msg,"%s%s\nError: The set for the above predicate has not been defined!\n", "Predicate: ", misc->subformula[ii]->sym->name);
                 ssSetErrorStatus(S,msg);
                 return;
              }
         }
     }
	ssSetUserData(S,(void*)misc);
	misc->SampleNum=-1;
    if(misc->Prediction==1 && misc->FH<fw_taliro_param.predictorHorizon){
         mexPrintf("Error: Predictor's Horizon= %d is more than Formula's Horizon= %d\n",fw_taliro_param.predictorHorizon,misc->FH);
         sprintf(msg,"Error: Predictor's Horizon= %d is more than Formula's Horizon= %d\n",misc->FH,fw_taliro_param.predictorHorizon);
         ssSetErrorStatus(S,msg);
         return;
    }
     free(dumpbuf);
     free(uform);
 	 free(yytext);

}
#endif /*  MDL_START */
HyDis  SetToInf(int sign){
	HyDis   temp;
	double infval = mxGetInf();	
	if( sign == -1 ){
		temp.dl= (-1)*intMax32bit;
		temp.ds= (-1)*infval;
	}
	else{
		temp.dl= intMax32bit;
		temp.ds= infval;
	}
	return  temp;
}


void  computeHorizon(Miscellaneous *misc,Node *phi){
    int  left_horizon,right_horizon,left_history,right_history;
    misc->subformula[phi->index]=phi;
    phi->past=-1;
    if( phi->ntyp==PREDICATE || phi->ntyp==TRUE || phi->ntyp==FALSE || phi->ntyp==VALUE){
        phi->FiniteHorizon=0;
        phi->History=0;
		phi->Lindex=0;
		phi->Rindex=0;
        return;
    }
    if(phi->lft != NULL){
        computeHorizon(misc,phi->lft);
        left_horizon=phi->lft->FiniteHorizon;
        left_history=phi->lft->History;
        phi->Lindex = phi->lft->index;
    }else{
        phi->Lindex=0;
    }
    if(phi->rgt != NULL){
        computeHorizon(misc,phi->rgt);
        right_horizon=phi->rgt->FiniteHorizon;
        right_history=phi->rgt->History;
        phi->Rindex = phi->rgt->index;
    }else{
        phi->Rindex=0;
    }
    switch(phi->ntyp) {
	case NOT:
		phi->FiniteHorizon=left_horizon;
		phi->History=left_history;
		break;
	case OR:	
	case AND:	
    case EQUIV:
    case IMPLIES:
        if(left_horizon>right_horizon)
            phi->FiniteHorizon=left_horizon;
        else
            phi->FiniteHorizon=right_horizon;
        if(left_history>right_history)
            phi->History=left_history;
        else
            phi->History=right_history;
		break;
    case U_OPER:
        phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
        left_horizon = left_horizon + phi->UBound -1;
        right_horizon = right_horizon + phi->UBound;
        if(left_horizon>right_horizon)
            phi->FiniteHorizon=left_horizon;
        else
            phi->FiniteHorizon=right_horizon;
        if(left_history>right_history)
            phi->History=left_history;
        else
            phi->History=right_history;
        break;
    case S_OPER:
        phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
		if(isItAny2Inf(phi->time)){
            left_history = left_history + phi->LBound -1;
            right_history = right_history + phi->LBound;
		}
		else{
            left_history = left_history + phi->UBound -1;
            right_history = right_history + phi->UBound;
		}
        if(left_history>right_history)
            phi->History=left_history;
        else
            phi->History=right_history;
        if(left_horizon>right_horizon)
            phi->FiniteHorizon=left_horizon;
        else
            phi->FiniteHorizon=right_horizon;
        break;
	case V_OPER:
	    phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
        if(left_horizon>right_horizon)
            phi->FiniteHorizon=left_horizon;
        else
            phi->FiniteHorizon=right_horizon;
        if(left_history>right_history)
            phi->History=left_history;
        else
            phi->History=right_history;
        phi->FiniteHorizon = phi->FiniteHorizon + phi->UBound;
        break;
	case T_OPER:
	    phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
        if(left_horizon>right_horizon)
            phi->FiniteHorizon=left_horizon;
        else
            phi->FiniteHorizon=right_horizon;
        if(left_history>right_history)
            phi->History=left_history;
        else
            phi->History=right_history;
		if(isItAny2Inf(phi->time))
	        phi->History = phi->History + phi->LBound;
		else
            phi->History = phi->History + phi->UBound;
        break;
    case NEXT:
    case WEAKNEXT:
        if( isItZero2Inf(phi->time) ){
            phi->FiniteHorizon = left_horizon + 1; 
            phi->History = left_history;
        }
        else
            ssPrintf("ERROR: Incorrect interval for next/prev operator \n");
        break;
    case PREV:
    case WEAKPREV:
        if( isItZero2Inf(phi->time) ){
            phi->History = left_history + 1;
            phi->FiniteHorizon = left_horizon; 
        }
        else
            ssPrintf("ERROR: Incorrect interval for next/prev operator \n");
        break;
	case ALWAYS:
	case EVENTUALLY:
        phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
        phi->FiniteHorizon = right_horizon + phi->UBound;
        phi->History = right_history;
        break;
	case ALWAYS_PAST:
	case EVENTUALLY_PAST:
        phi->LBound = (int) phi->time.lbd.numf.f_num;
        phi->UBound = (int) phi->time.ubd.numf.f_num;
		if(isItAny2Inf(phi->time))
	        phi->History = right_history + phi->LBound;
		else
            phi->History = right_history + phi->UBound;
        phi->FiniteHorizon = right_horizon;
        break;
	default:
		break;
    }
    switch(phi->ntyp) {
	case NOT:
	case OR:	
	case AND:	
    case EQUIV:
    case IMPLIES:
    case U_OPER:
	case V_OPER:
	case ALWAYS:
	case EVENTUALLY:
    case NEXT:
    case WEAKNEXT:
            phi->past=0;
        break;
    case S_OPER:
	case T_OPER:
	case ALWAYS_PAST:
	case EVENTUALLY_PAST:
    case PREV:
    case WEAKPREV:
            phi->past=1;
		break;
    }
    return;
}

int isItZero2Inf(Interval time){
  	if(time.l_closed != 1)
        return 0;
  	if(time.u_closed != 0)
        return 0;
    if(time.lbd.numf.inf != 0)
        return 0;
    if(time.lbd.numf.f_num != 0.0)
        return 0;
    if(time.ubd.numf.inf != 1)
        return 0;
    if(time.ubd.numf.f_num != 0.0)
        return 0;
    return 1;
}

int isItAny2Inf(Interval time){
  	if(time.u_closed != 0)
        return 0;
    if(time.ubd.numf.inf != 1)
        return 0;
    if(time.ubd.numf.f_num != 0.0)
        return 0;
    return 1;
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T             i;
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    int_T             width = ssGetOutputPortWidth(S,0);
	HyDis rob;
    Miscellaneous *misc;
    Node *phi;
    misc=(Miscellaneous*)ssGetUserData(S);
    phi=misc->node;
    
    if(misc->Prediction==0)
        for (i=0; i<fw_taliro_param.SysDim; i++) {
        /*
         * This example does not implement complex signal handling.
         * To find out see an example about how to handle complex signal in
         * S-function, see sdotproduct.c for details.
         */
            misc->XTrace[i]=(*uPtrs[i]);
        }
    else
        for (i=0; i<fw_taliro_param.szInp; i++) {
        /*
         * This example does not implement complex signal handling.
         * To find out see an example about how to handle complex signal in
         * S-function, see sdotproduct.c for details.
         */
            misc->XTrace[i]=(*uPtrs[i]);
        }
        
	misc->SampleNum++;
    rob=FH_Taliro(misc,misc->predMap,misc->XTrace,misc->SampleNum,misc->LTrace,&misc->distData,&fw_taliro_param);
    for (i=0; i<width; i++) {
        /*
         * This example does not implement complex signal handling.
         * To find out see an example about how to handle complex signal in 
         * S-function, see sdotproduct.c for details.
         */
        *y++ =  rob.ds; 
    }
    
}


void printTable(Miscellaneous *misc){
    int  j,k;
    for(j=0;j<=(misc->FH+misc->History);j++){
            ssPrintf("----------------");
    }
    ssPrintf("\n");
    for(k=1;k<=misc->phi_size;k++){
        for(j=0;j<=(misc->FH+misc->History);j++){
            ssPrintf(" %f |",misc->RobTable[k][j].ds);
        }        
        ssPrintf("\n");
    }
    for(j=0;j<=(misc->FH+misc->History);j++){
            ssPrintf("----------------");
    }
    ssPrintf("\n\n");
}

 HyDis FH_Taliro(Miscellaneous *misc, PMap *predMap, double *XTrace, int i, double *LTrace, DistCompData *p_distData, FWTaliroParam *p_par){
     int j,k;
     HyDis  robustness;
     int SD=fw_taliro_param.SysDim;
     int PH=fw_taliro_param.predictorHorizon;
     robustness=SetToInf(+1);

     misc->iHst=misc->History;
     if(i>(misc->History)){/*  pre variable should be updated pre <- now */
          for(k=1;k<=misc->phi_size;k++){
             misc->pre[k]=misc->RobTable[k][misc->subformula[k]->History]; 
          }
     }else
         misc->iHst=i;
	 if (i>(misc->History))
		for(j=1;j<=(misc->FH+misc->History);j++){ 
			  for(k=1;k<=misc->phi_size;k++){
				  if(misc->subformula[k]->ntyp==PREDICATE){
					 misc->RobTable[k][j-1]=misc->RobTable[k][j]; 
				  }
			  }
        }
     
     for(k=misc->phi_size;k>=1;k--){
         if(misc->subformula[k]->past<1){
             if(misc->subformula[k]->ntyp!=PREDICATE)
				 if (misc->iHst == misc->History)
					 for(j=(misc->FH+misc->History);j>=misc->subformula[k]->History;j--)
					 	 UpdateRob(misc,k,j,XTrace,p_distData,p_par); 
				 else
					 for (j = (misc->FH + misc->iHst); j >= 0; j--)/*for (j = (FH + History); j >= 0; j--)*/
						 UpdateRob(misc, k, j, XTrace, p_distData, p_par);

             else{
                 if(misc->Prediction==0){
                     if (misc->iHst == misc->History){
                        UpdateRob(misc, k, misc->History, XTrace, p_distData, p_par);
                        for (j = misc->History+1; j <=misc->FH + misc->History ; j++)
                            misc->RobTable[k][j]=misc->RobTable[k][j-1]; 
                     }
                     else{
                         UpdateRob(misc, k, misc->iHst, XTrace, p_distData, p_par);
                         for (j = misc->iHst+1; j <= misc->FH + misc->iHst ; j++)/*for (j = (FH + History); j >= iHst; j--)*/
                             misc->RobTable[k][j]=misc->RobTable[k][j-1]; 
                     }
                 }
                 else{
                     if (misc->iHst == misc->History){
                        UpdateRob(misc, k, misc->History, XTrace, p_distData, p_par);
                        for (j = 1; j <=PH ; j++)
                            UpdateRob(misc, k, misc->History+j, XTrace+(SD*j), p_distData, p_par);
                        for (j = misc->History+PH+1; j <=misc->FH + misc->History ; j++)
                            misc->RobTable[k][j]=misc->RobTable[k][j-1]; 
                     }
                     else{
                         UpdateRob(misc, k, misc->iHst, XTrace, p_distData, p_par);
                         for (j = 1; j <=PH ; j++)
                             UpdateRob(misc, k, misc->iHst+j, XTrace+(SD*j), p_distData, p_par);
                         for (j = misc->iHst+PH+1; j <= misc->FH + misc->iHst ; j++)/*for (j = (FH + History); j >= iHst; j--)*/
                             misc->RobTable[k][j]=misc->RobTable[k][j-1]; 
                     }                    
                 }
             }
		 }
         else{
			 if (misc->iHst == misc->History)
				 for (j = misc->subformula[k]->History; j <= (misc->FH + misc->History); j++)
					 UpdateRobPast(misc, k, j, XTrace, i, p_distData, p_par);
			 else
				 for (j = 0; j <= (misc->FH + misc->iHst); j++)
					 UpdateRobPast(misc, k, j, XTrace, i, p_distData, p_par);
         }
     }
		 if (misc->iHst == misc->History)
			robustness = misc->RobTable[1][misc->History];
		 else
			robustness = misc->RobTable[1][misc->iHst];
     
	 return robustness;
 }

void UpdateRobPast(Miscellaneous *misc,int k,int evalTime, double *xx, int i, DistCompData *p_distData, FWTaliroParam *p_par){
    HyDis min,max,tmp_S;
    int   n,iterUp,iterDown;
      switch ( misc->subformula[k]->ntyp )
            {
       		case PREV:
                 iterUp = evalTime - 1;/*j-1'*/
                 if( misc->subformula[k]->Lindex!=0 ){
                     iterDown=evalTime - 1;/*j-1'*/
                     max=SetToInf(-1);
                     if(iterDown>=0){
                         for( n=iterUp ; n>=iterDown ; n-- ){/*j-1'<=j'<=j-1'*/
                             max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]); 
                          }
                     }
  				     else{
						 for (n = iterUp; n >= 0; n--){/*0<=j'<=j-1'*/
							 max = hmax(max, misc->RobTable[misc->subformula[k]->Lindex][n]);
						 }
					}
                     misc->RobTable[k][evalTime]=max;
                 }else{
                     ssPrintf("Error: UpdateRob for PREV: right index is not valid!\n");
                 }
				break;
       		case WEAKPREV:
                iterUp = evalTime - 1;/*j-1'*/
                if( misc->subformula[k]->Lindex!=0 ){
                     iterDown=evalTime - 1;/*j-1'*/
                     max=SetToInf(-1);
                     if(iterDown>=0){
                         for( n=iterUp ; n>=iterDown ; n-- ){/*j-1'<=j'<=j-1'*/
                             max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]); 
                          }
                     }
  				     else{
						 for (n = iterUp; n >= 0; n--){/*0<=j'<=j-1'*/
							 max = hmax(max, misc->RobTable[misc->subformula[k]->Lindex][n]);
						 }
					}
                     misc->RobTable[k][evalTime]=max;
                 }else{
                     ssPrintf("Error: UpdateRob for WEAKPREV: right index is not valid!\n");
                 }
				break;
      		case EVENTUALLY_PAST:
                if( isItAny2Inf(misc->subformula[k]->time) ){
                    if( misc->subformula[k]->Rindex!=0 ){
                        max=SetToInf(-1);
                        iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                        if( i>(misc->History) ){/*Use Pre*/
                            if(evalTime==(misc->subformula[k]->History))/* line 30*/
                                tmp_S=misc->pre[k];/* line 31*/
                            else
                                tmp_S=misc->RobTable[k][evalTime-1];/* line 33*/
                            max = hmax(misc->RobTable[misc->subformula[k]->Rindex][iterUp],tmp_S);/* line 35*/
                        }
                        else{
							for (n = iterUp; n >= 0; n--){
								max = hmax(max, misc->RobTable[misc->subformula[k]->Rindex][n]);
							}
                        }
                        misc->RobTable[k][evalTime]=max;
                    }else{
                        ssPrintf("Error: UpdateRobPast for EVENTUALLY_PAST: right index is not valid!\n");
                    }                        
                        
                }
                else {
                    iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                    if( misc->subformula[k]->Rindex!=0 ){
                        iterDown=evalTime - misc->subformula[k]->UBound;/*j-u'*/
                        max=SetToInf(-1);
                        if(iterDown>=0){
                            for( n=iterUp ; n>=iterDown ; n-- ){/*j-u'<=j'<=j-l'*/
                                max=hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n]); 
                            }
                        }
						else{
							for (n = iterUp; n >= 0; n--){/*0<=j'<=j-l' for the initialization of the History table*/
								max = hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n]);
							}
						}
                        misc->RobTable[k][evalTime]=max;
                    }else{
                        ssPrintf("Error: UpdateRobPast for EVENTUALLY_PAST: right index is not valid!\n");
                    }
				}	
                break;
      		case S_OPER:
                if( isItAny2Inf(misc->subformula[k]->time) ){
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0 ){
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
						for( n=evalTime ; n>iterUp ; n-- ){/*j-l'<j'<=j*/
							min=hmin(min,misc->RobTable[misc->subformula[k]->Lindex][n]);
						}
                        if( i>(misc->History) ){/*Use Pre*/
                            if(evalTime==(misc->subformula[k]->History))/* line 30*/
                                tmp_S=hmin(misc->pre[k],misc->RobTable[misc->subformula[k]->Lindex][evalTime]);/* line 31*/
                            else
                                tmp_S=hmin(misc->RobTable[k][evalTime-1],misc->RobTable[misc->subformula[k]->Lindex][evalTime]);/* line 33*/
                            max = hmax(hmin(misc->RobTable[misc->subformula[k]->Rindex][iterUp],min),tmp_S);/* line 35*/
                        }
                        else{
							for (n = iterUp; n >= 0; n--){
								max = hmax(max, hmin(min, misc->RobTable[misc->subformula[k]->Rindex][n]));
								min = hmin(min, misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
                        }
                        misc->RobTable[k][evalTime]=max;
                    }else{
                        ssPrintf("Error: UpdateRobPast for SINCE : right/left index is not valid!\n");
                    }                        
                        
                }
                else {
                    iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0 ){
                        iterDown=evalTime - misc->subformula[k]->UBound;/*j-u'*/
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        if(iterDown>=0){
							for( n=evalTime ; n>iterUp ; n-- ){/*j-l'<j'<=j*/
								min=hmin(min,misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
                            for( n=iterUp ; n>=iterDown ; n-- ){/*j-u'<=j'<=j-l'*/
                                max=hmax(max,hmin(min,misc->RobTable[misc->subformula[k]->Rindex][n])); 
								min=hmin(min,misc->RobTable[misc->subformula[k]->Lindex][n]);
                            }
                        }
						else{
							for (n = evalTime; n>iterUp; n--){/*j-l'<j'<=j*/
								min = hmin(min, misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
							for (n = iterUp; n >= 0; n--){/*j-u'<=j'<=j-l'*/
								max = hmax(max, hmin(min, misc->RobTable[misc->subformula[k]->Rindex][n]));
								min = hmin(min, misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
						}
                        misc->RobTable[k][evalTime]=max;
                    }else{
                        ssPrintf("Error: UpdateRobPast for SINCE: right/left index is not valid!\n");
                    }
				}
				break;
      		case T_OPER:
                 if( isItAny2Inf(misc->subformula[k]->time) ){
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0 ){
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
						for( n=evalTime ; n>iterUp ; n-- ){/*j-l'<j'<=j*/
							max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
						}
                        if( i>(misc->History) ){/*Use Pre*/
                            if(evalTime==(misc->subformula[k]->History))/* line 30*/
                                tmp_S=hmax(misc->pre[k],misc->RobTable[misc->subformula[k]->Lindex][evalTime]);/* line 31*/
                            else
                                tmp_S=hmax(misc->RobTable[k][evalTime-1],misc->RobTable[misc->subformula[k]->Lindex][evalTime]);/* line 33*/
                            min = hmin(hmax(misc->RobTable[misc->subformula[k]->Rindex][iterUp],max),tmp_S);/* line 35*/
                        }
                        else{
							for (n = iterUp; n >= 0; n--){
								min = hmin(min, hmax(max, misc->RobTable[misc->subformula[k]->Rindex][n]));
								max = hmax(max, misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
						}
                        misc->RobTable[k][evalTime]=min;
                    }else{
                        ssPrintf("Error: UpdateRobPast for TRIGGER : right/left index is not valid!\n");
                    }                        
                        
                }
                else {
                    iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0 ){
                        iterDown=evalTime - misc->subformula[k]->UBound;/*j-u'*/
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        if(iterDown>=0){
							for( n=evalTime ; n>iterUp ; n-- ){/*j-l'<j'<=j*/
								max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
                            for( n=iterUp ; n>=iterDown ; n-- ){/*j-u'<=j'<=j-l'*/
                                min=hmin(min,hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n])); 
								max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
                            }
                        }
						else{
							for( n=evalTime ; n>iterUp ; n-- ){/*j-l'<j'<=j*/
								max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
							}
                            for( n=iterUp ; n>=0 ; n-- ){/*j-u'<=j'<=j-l'*/
                                min=hmin(min,hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n])); 
								max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
                            }                            
						}
                        misc->RobTable[k][evalTime]=min;
                    }else{
                        ssPrintf("Error: UpdateRobPast for DELAY: right/left index is not valid!\n");
                    }
				}
				break;
      		case ALWAYS_PAST:
                 if( isItAny2Inf(misc->subformula[k]->time) ){
                    if( misc->subformula[k]->Rindex!=0 ){
                        min=SetToInf(+1);
                        iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                        if( i>(misc->History) ){/*Use Pre*/
                            if(evalTime==(misc->subformula[k]->History))/* line 30*/
                                tmp_S=misc->pre[k];/* line 31*/
                            else
                                tmp_S=misc->RobTable[k][evalTime-1];/* line 33*/
                            min = hmin(misc->RobTable[misc->subformula[k]->Rindex][iterUp],tmp_S);/* line 35*/
                        }
                        else{
							for (n = iterUp; n >= 0; n--){
								min = hmin(min, misc->RobTable[misc->subformula[k]->Rindex][n]);
							}
                        }
                        misc->RobTable[k][evalTime]=min;
                    }else{
                        ssPrintf("Error: UpdateRobPast for ALWAYS_PAST: right index is not valid!\n");
                    }                        
                        
                }
                else {
                    iterUp = evalTime - misc->subformula[k]->LBound;/*j-l'*/
                    if( misc->subformula[k]->Rindex!=0 ){
                        iterDown=evalTime - misc->subformula[k]->UBound;/*j-u'*/
                        min=SetToInf(+1);
                        if(iterDown>=0){
                            for( n=iterUp ; n>=iterDown ; n-- ){/*j-u'<=j'<=j-l'*/
                                min=hmin(min,misc->RobTable[misc->subformula[k]->Rindex][n]);
                            }
                        }
						else{
							for (n = iterUp; n >= 0; n--){/*0<=j'<=j-l' for the initialization of the History table*/ 
								min = hmin(min, misc->RobTable[misc->subformula[k]->Rindex][n]);
							}
						}
                        misc->RobTable[k][evalTime]=min;
                    }else{
                        ssPrintf("Error: UpdateRobPast for ALWAYS_PAST: right index is not valid!\n");
                    }
				}	
                break;
            default:
                ssPrintf("Error 2 node(%d=%d): UpdateRobPast for %d: left index is not valid!\n",k,misc->subformula[k]->index,misc->subformula[k]->ntyp);
    			break;
            }
      return;
}
 
void UpdateRob(Miscellaneous *misc,int k,int horizon, double *xx, DistCompData *p_distData, FWTaliroParam *p_par){
    HyDis min,max;
    int   n,iterBegin,iterEnd;
            switch ( misc->subformula[k]->ntyp )
            {
       		case TRUE:
                misc->RobTable[k][horizon] = SetToInf(+1);
				break;
            case FALSE:
                misc->RobTable[k][horizon] = SetToInf(-1);
				break;
    		case VALUE:
    		case PREDICATE:
                    if (misc->subformula[k]->sym->set)
                    {
                        misc->RobTable[k][horizon].ds = SignedDist(xx,misc->subformula[k]->sym->set,p_par->SysDim);
                        misc->RobTable[k][horizon].dl = 0;
                    }
    			break;
            case NOT:
                if( misc->subformula[k]->Lindex!=0 ){
                    misc->RobTable[k][horizon].ds = (-1)*(misc->RobTable[misc->subformula[k]->Lindex][horizon].ds);
                    misc->RobTable[k][horizon].dl = (-1)*(misc->RobTable[misc->subformula[k]->Lindex][horizon].dl);
                }
                else
                    ssPrintf("Error: UpdateRob for NOT: left index is not valid!\n");
				break;
            case AND:
                if( misc->subformula[k]->Lindex!=0 &&  misc->subformula[k]->Rindex!=0 ){
                    misc->RobTable[k][horizon] = hmin(misc->RobTable[misc->subformula[k]->Lindex][horizon],misc->RobTable[misc->subformula[k]->Rindex][horizon]);
                }
                else{
                    ssPrintf("Error: UpdateRob for AND: left or right index is not valid!\n");
                }
				break;
            case OR:
                if( misc->subformula[k]->Lindex!=0 &&  misc->subformula[k]->Rindex!=0 ){
                    misc->RobTable[k][horizon] = hmax(misc->RobTable[misc->subformula[k]->Lindex][horizon], misc->RobTable[misc->subformula[k]->Rindex][horizon]);
                }
                else{
                    ssPrintf("Error: UpdateRob for OR: left or right index is not valid!\n");
                }
				break;
       		case NEXT:
                if(horizon==(misc->FH+misc->History))
                    misc->RobTable[k][horizon] = SetToInf(-1);
                else  
                    if( misc->subformula[k]->Lindex!=0){
                        misc->RobTable[k][horizon] = misc->RobTable[misc->subformula[k]->Lindex][horizon+1];
                    }
                    else{
                        ssPrintf("Error: UpdateRob for NEXT: left or right index is not valid!\n");
                    }
				break;
       		case WEAKNEXT:
                if(horizon==(misc->FH+misc->History))
                    misc->RobTable[k][horizon] = SetToInf(+1);
                else
                    if( misc->subformula[k]->Lindex!=0){
                        misc->RobTable[k][horizon] = misc->RobTable[misc->subformula[k]->Lindex][horizon+1];
                    }
                    else{
                        ssPrintf("Error: UpdateRob for WEAKNEXT: left or right index is not valid!\n");
                    }
				break;
       		case EVENTUALLY:
                if( ( horizon + misc->subformula[k]->LBound ) <= (misc->FH+misc->History) ){
                    max=SetToInf(-1);
                    iterBegin = horizon+misc->subformula[k]->LBound;
                    if( misc->subformula[k]->Rindex!=0){
                        if(horizon + misc->subformula[k]->UBound < (misc->FH+misc->History) ) 
                            iterEnd=horizon + misc->subformula[k]->UBound;
                        else
                            iterEnd=(misc->FH+misc->History);
                        for( n=iterBegin ; n<=iterEnd ; n++ ){
                            max=hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n]); 
                        }
                        misc->RobTable[k][horizon]=max;
                    }else{
                        ssPrintf("Error: UpdateRob for EVENTUALLY: right index is not valid!\n");
                    }
                }
                else
                    misc->RobTable[k][horizon] = SetToInf(-1);;
				break;
       		case ALWAYS:
                if( ( horizon + misc->subformula[k]->LBound ) <= (misc->FH+misc->History) ){
                    min=SetToInf(+1);
                    iterBegin = horizon+misc->subformula[k]->LBound;
                    if( misc->subformula[k]->Rindex!=0){
                        if(horizon + misc->subformula[k]->UBound < (misc->FH+misc->History) ) 
                            iterEnd=horizon + misc->subformula[k]->UBound;
                        else
                            iterEnd=(misc->FH+misc->History);
                        for( n=iterBegin ; n<=iterEnd ; n++ ){
                            min=hmin(min,misc->RobTable[misc->subformula[k]->Rindex][n]); 
                        }
                        misc->RobTable[k][horizon]=min;
                    }else{
                        ssPrintf("Error: UpdateRob for ALWAYS: right index is not valid!\n");
                    }
                }
                else
                    misc->RobTable[k][horizon] = SetToInf(+1);;
				break;
       		case U_OPER:
                if( ( horizon + misc->subformula[k]->LBound ) <= (misc->FH+misc->History) ){
                    
                    iterBegin = horizon+misc->subformula[k]->LBound;
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0){
                        if(horizon + misc->subformula[k]->UBound < (misc->FH+misc->History) ) 
                            iterEnd=horizon + misc->subformula[k]->UBound;
                        else
                            iterEnd=(misc->FH+misc->History);
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        for(n=horizon ; n<iterBegin ; n++){
                           min=hmin(min,misc->RobTable[misc->subformula[k]->Lindex][n]);
                        }
                        for( n=iterBegin ; n<=iterEnd ; n++ ){
                            max=hmax(max,hmin(min,misc->RobTable[misc->subformula[k]->Rindex][n]));
                            min=hmin(min,misc->RobTable[misc->subformula[k]->Lindex][n]); 
                        }
                        misc->RobTable[k][horizon]=max;                    
                    }else{
                        ssPrintf("Error: UpdateRob for EVENTUALLY: right index is not valid!\n");
                    }
                    
                }
                 else
                     misc->RobTable[k][horizon] = SetToInf(-1);;
				break;
       		case V_OPER:
                if( ( horizon + misc->subformula[k]->LBound ) <= (misc->FH+misc->History) ){

                    iterBegin = horizon+misc->subformula[k]->LBound;
                    if( misc->subformula[k]->Rindex!=0 && misc->subformula[k]->Lindex!=0){
                        if(horizon + misc->subformula[k]->UBound < (misc->FH+misc->History) ) 
                            iterEnd=horizon + misc->subformula[k]->UBound;
                        else
                            iterEnd=(misc->FH+misc->History);
                        max=SetToInf(-1);
                        min=SetToInf(+1);
                        for(n=horizon ; n<iterBegin ; n++){
                           max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]);
                        }
                        for( n=iterBegin ; n<=iterEnd ; n++ ){
                            min=hmin(min,hmax(max,misc->RobTable[misc->subformula[k]->Rindex][n]));
                            max=hmax(max,misc->RobTable[misc->subformula[k]->Lindex][n]); 
                        }
                        misc->RobTable[k][horizon]=min;
                    }else{
                        ssPrintf("Error: UpdateRob for EVENTUALLY: right index is not valid!\n");
                    }
                    
                }
                 else
                     misc->RobTable[k][horizon] = SetToInf(+1);;
				break;
            default:
                ssPrintf("Error 2 node(%d=%d): UpdateRob for %d: left index is not valid!\n",k,misc->subformula[k]->index,misc->subformula[k]->ntyp);
    			break;
            }
      return;
}

 
/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
     tend = time(0); 
}

/* Definitions */

void* emalloc(size_t n)
{   int i=0;
    return  (void *) malloc(n);
}

void efree(void * ptr)
{
    free(ptr);
    return;
}

int tl_Getchar(void)
{
	if (cnt < hasuform)
		return uform[cnt++];
	cnt++;
	return -1;
}

void tl_UnGetchar(void)
{
	if (cnt > 0) cnt--;
}

#define Binop(a)		\
		fprintf(tl_out, "(");	\
		dump(n->lft);		\
		fprintf(tl_out, a);	\
		dump(n->rgt);		\
		fprintf(tl_out, ")")

static void sdump(Node *n)
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
common2:		sdump(n->rgt);
common1:		sdump(n->lft);
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

Symbol *DoDump(Node *n)
{
	if (!n) return ZS;

	if (n->ntyp == PREDICATE)
		return n->sym;

	dumpbuf[0] = '\0';
	sdump(n);
	return tl_lookup(dumpbuf);
}

void dump(Node *n)
{
	if (!n) return;

	switch(n->ntyp) {
	case OR:	Binop(" || "); break;
	case AND:	Binop(" && "); break;
	case U_OPER:	Binop(" U ");  break;
	case V_OPER:	Binop(" V ");  break;
	case NEXT:
		fprintf(tl_out, "X");
		fprintf(tl_out, " (");
		dump(n->lft);
		fprintf(tl_out, ")");
		break;
	case NOT:
		fprintf(tl_out, "!");
		fprintf(tl_out, " (");
		dump(n->lft);
		fprintf(tl_out, ")");
		break;
	case FALSE:
		fprintf(tl_out, "false");
		break;
	case TRUE:
		fprintf(tl_out, "true");
		break;
	case PREDICATE:
		fprintf(tl_out, "(%s)", n->sym->name);
		break;
	case -1:
		fprintf(tl_out, " D ");
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

static void non_fatal(char *s1, char *s2)
{	extern int tl_yychar;
	int i;

	printf("TaLiRo: ");
	if (s2)
		printf(s1, s2);
	else
		printf(s1);
	if (tl_yychar != -1 && tl_yychar != 0)
	{	printf(", saw '");
		tl_explain(tl_yychar);
		printf("'");
	}
	printf("\nTaLiRo: %s\n---------", uform);
	for (i = 0; i < cnt; i++)
		printf("-");
	printf("^\n");
	fflush(stdout);
	tl_errs++;
}

void
tl_yyerror(char *s1)
{
	Fatal(s1, (char *) 0);
}

void
Fatal(char *s1, char *s2)
{
  non_fatal(s1, s2);
}

void fatal(char *s1, char *s2)
{
        non_fatal(s1, s2);
}

void put_uform(void)
{
	fprintf(tl_out, "%s", uform);
}

void tl_exit(int i)
{
	exit(i);
}

/***** from parse.c *****/

static int
implies(Node *a, Node *b)
{
  return
    (isequal(a,b) ||
     b->ntyp == TRUE ||
     a->ntyp == FALSE ||
     (b->ntyp == AND && implies(a, b->lft) && implies(a, b->rgt)) ||
     (a->ntyp == OR && implies(a->lft, b) && implies(a->rgt, b)) ||
     (a->ntyp == AND && (implies(a->lft, b) || implies(a->rgt, b))) ||
     (b->ntyp == OR && (implies(a, b->lft) || implies(a, b->rgt))) ||
     (b->ntyp == U_OPER && implies(a, b->rgt)) ||
     (a->ntyp == V_OPER && implies(a->rgt, b)) ||
     (a->ntyp == U_OPER && implies(a->lft, b) && implies(a->rgt, b)) ||
     (b->ntyp == V_OPER && implies(a, b->lft) && implies(a, b->rgt)) ||
     ((a->ntyp == U_OPER || a->ntyp == V_OPER) && a->ntyp == b->ntyp && 
         implies(a->lft, b->lft) && implies(a->rgt, b->rgt)));
}

static Node *bin_simpler(Node *ptr)
{	Node *a, *b;

	if (ptr)
	switch (ptr->ntyp) {
	case U_OPER:
		if (ptr->rgt->ntyp == TRUE
		||  ptr->rgt->ntyp == FALSE
		||  ptr->lft->ntyp == FALSE)
		{	ptr = ptr->rgt;
			break;
		}
		if (implies(ptr->lft, ptr->rgt)) /* NEW */
		{	ptr = ptr->rgt;
		        break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->lft, ptr->rgt))
		{	/* (p U q) U p = (q U p) */
			ptr->lft = ptr->lft->rgt;
			break;
		}
		if (ptr->rgt->ntyp == U_OPER
		&&  implies(ptr->lft, ptr->rgt->lft))
		{	/* NEW */
			ptr = ptr->rgt;
			break;
		}
		/* X p U X q == X (p U q) */
		if (ptr->rgt->ntyp == NEXT
		&&  ptr->lft->ntyp == NEXT)
		{	ptr = tl_nn(NEXT,
				tl_nn(U_OPER,
					ptr->lft->lft,
					ptr->rgt->lft), ZN);
		        break;
		}

		/* NEW : F X p == X F p */
		if (ptr->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == NEXT) {
		  ptr = tl_nn(NEXT, tl_nn(U_OPER, True, ptr->rgt->lft), ZN);
		  break;
		}

		/* NEW : F G F p == G F p */
		if (ptr->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == V_OPER &&
		    ptr->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->rgt->ntyp == U_OPER &&
		    ptr->rgt->rgt->lft->ntyp == TRUE) {
		  ptr = ptr->rgt;
		  break;
		}

		/* NEW */
		if (ptr->lft->ntyp != TRUE && 
		    implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)), ptr->lft))
		{       ptr->lft = True;
		        break;
		}
		break;
	case V_OPER:
		if (ptr->rgt->ntyp == FALSE
		||  ptr->rgt->ntyp == TRUE
		||  ptr->lft->ntyp == TRUE)
		{	ptr = ptr->rgt;
			break;
		}
		if (implies(ptr->rgt, ptr->lft))
		{	/* p V p = p */	
			ptr = ptr->rgt;
			break;
		}
		/* F V (p V q) == F V q */
		if (ptr->lft->ntyp == FALSE
		&&  ptr->rgt->ntyp == V_OPER)
		{	ptr->rgt = ptr->rgt->rgt;
			break;
		}
		/* NEW : G X p == X G p */
		if (ptr->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == NEXT) {
		  ptr = tl_nn(NEXT, tl_nn(V_OPER, False, ptr->rgt->lft), ZN);
		  break;
		}
		/* NEW : G F G p == F G p */
		if (ptr->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == U_OPER &&
		    ptr->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->rgt->ntyp == V_OPER &&
		    ptr->rgt->rgt->lft->ntyp == FALSE) {
		  ptr = ptr->rgt;
		  break;
		}

		/* NEW */
		if (ptr->rgt->ntyp == V_OPER
		&&  implies(ptr->rgt->lft, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}

		/* NEW */
		if (ptr->lft->ntyp != FALSE && 
		    implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN))))
		{       ptr->lft = False;
		        break;
		}
		break;
	case NEXT:
		/* NEW : X G F p == G F p */
		if (ptr->lft->ntyp == V_OPER &&
		    ptr->lft->lft->ntyp == FALSE &&
		    ptr->lft->rgt->ntyp == U_OPER &&
		    ptr->lft->rgt->lft->ntyp == TRUE) {
		  ptr = ptr->lft;
		  break;
		}
		/* NEW : X F G p == F G p */
		if (ptr->lft->ntyp == U_OPER &&
		    ptr->lft->lft->ntyp == TRUE &&
		    ptr->lft->rgt->ntyp == V_OPER &&
		    ptr->lft->rgt->lft->ntyp == FALSE) {
		  ptr = ptr->lft;
		  break;
		}
		break;
	case IMPLIES:
		if (implies(ptr->lft, ptr->rgt))
		  {	ptr = True;
			break;
		}
		ptr = tl_nn(OR, Not(ptr->lft), ptr->rgt);
		ptr = rewrite(ptr);
		break;
	case EQUIV:
		if (implies(ptr->lft, ptr->rgt) &&
		    implies(ptr->rgt, ptr->lft))
		  {	ptr = True;
			break;
		}
		a = rewrite(tl_nn(AND,
			dupnode(ptr->lft),
			dupnode(ptr->rgt)));
		b = rewrite(tl_nn(AND,
			Not(ptr->lft),
			Not(ptr->rgt)));
		ptr = tl_nn(OR, a, b);
		ptr = rewrite(ptr);
		break;
	case AND:
		/* p && (q U p) = p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->lft;
			break;
		}
		if (ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt))
		{	ptr = ptr->rgt;
			break;
		}

		/* p && (q V p) == q V p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}
		if (ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) && (r U q) = (p && r) U q*/
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft->rgt))
		{	ptr = tl_nn(U_OPER,
				tl_nn(AND, ptr->lft->lft, ptr->rgt->lft),
				ptr->lft->rgt);
			break;
		}

		/* (p V q) && (p V r) = p V (q && r) */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft))
		{	ptr = tl_nn(V_OPER,
				ptr->rgt->lft,
				tl_nn(AND, ptr->lft->rgt, ptr->rgt->rgt));
			break;
		}
		/* X p && X q == X (p && q) */
		if (ptr->rgt->ntyp == NEXT
		&&  ptr->lft->ntyp == NEXT)
		{	ptr = tl_nn(NEXT,
				tl_nn(AND,
					ptr->rgt->lft,
					ptr->lft->lft), ZN);
			break;
		}
		/* (p V q) && (r U q) == p V q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = ptr->lft;
			break;
		}

		if (isequal(ptr->lft, ptr->rgt)	/* (p && p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p && F) == F */
		||  ptr->lft->ntyp == TRUE	/* (T && p) == p */
		||  implies(ptr->rgt, ptr->lft))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p && T) == p */
		||  ptr->lft->ntyp == FALSE	/* (F && p) == F */
		||  implies(ptr->lft, ptr->rgt))/* NEW */
		{	ptr = ptr->lft;
			break;
		}
		
		/* NEW : F G p && F G q == F G (p && q) */
		if (ptr->lft->ntyp == U_OPER &&
		    ptr->lft->lft->ntyp == TRUE &&
		    ptr->lft->rgt->ntyp == V_OPER &&
		    ptr->lft->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->ntyp == U_OPER &&
		    ptr->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->rgt->ntyp == V_OPER &&
		    ptr->rgt->rgt->lft->ntyp == FALSE)
		  {
		    ptr = tl_nn(U_OPER, True,
				tl_nn(V_OPER, False,
				      tl_nn(AND, ptr->lft->rgt->rgt,
					    ptr->rgt->rgt->rgt)));
		    break;
		  }

		/* NEW */
		if (implies(ptr->lft, 
			    push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)))
		 || implies(ptr->rgt, 
			    push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN))))
		{       ptr = False;
		        break;
		}
		break;

	case OR:
		/* p || (q U p) == q U p */
		if (ptr->rgt->ntyp == U_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->rgt;
			break;
		}

		/* p || (q V p) == p */
		if (ptr->rgt->ntyp == V_OPER
		&&  isequal(ptr->rgt->rgt, ptr->lft))
		{	ptr = ptr->lft;
			break;
		}

		/* (p U q) || (p U r) = p U (q || r) */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == U_OPER
		&&  isequal(ptr->rgt->lft, ptr->lft->lft))
		{	ptr = tl_nn(U_OPER,
				ptr->rgt->lft,
				tl_nn(OR, ptr->lft->rgt, ptr->rgt->rgt));
			break;
		}

		if (isequal(ptr->lft, ptr->rgt)	/* (p || p) == p */
		||  ptr->rgt->ntyp == FALSE	/* (p || F) == p */
		||  ptr->lft->ntyp == TRUE	/* (T || p) == T */
		||  implies(ptr->rgt, ptr->lft))/* NEW */
		{	ptr = ptr->lft;
			break;
		}	
		if (ptr->rgt->ntyp == TRUE	/* (p || T) == T */
		||  ptr->lft->ntyp == FALSE	/* (F || p) == p */
		||  implies(ptr->lft, ptr->rgt))/* NEW */
		{	ptr = ptr->rgt;
			break;
		}

		/* (p V q) || (r V q) = (p || r) V q */
		if (ptr->rgt->ntyp == V_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = tl_nn(V_OPER,
				tl_nn(OR, ptr->lft->lft, ptr->rgt->lft),
				ptr->rgt->rgt);
			break;
		}

		/* (p V q) || (r U q) == r U q */
		if (ptr->rgt->ntyp == U_OPER
		&&  ptr->lft->ntyp == V_OPER
		&&  isequal(ptr->lft->rgt, ptr->rgt->rgt))
		{	ptr = ptr->rgt;
			break;
		}		
		
		/* NEW : G F p || G F q == G F (p || q) */
		if (ptr->lft->ntyp == V_OPER &&
		    ptr->lft->lft->ntyp == FALSE &&
		    ptr->lft->rgt->ntyp == U_OPER &&
		    ptr->lft->rgt->lft->ntyp == TRUE &&
		    ptr->rgt->ntyp == V_OPER &&
		    ptr->rgt->lft->ntyp == FALSE &&
		    ptr->rgt->rgt->ntyp == U_OPER &&
		    ptr->rgt->rgt->lft->ntyp == TRUE)
		  {
		    ptr = tl_nn(V_OPER, False,
				tl_nn(U_OPER, True,
				      tl_nn(OR, ptr->lft->rgt->rgt,
					    ptr->rgt->rgt->rgt)));
		    break;
		  }

		/* NEW */
		if (implies(push_negation(tl_nn(NOT, dupnode(ptr->rgt), ZN)),
			    ptr->lft)
		 || implies(push_negation(tl_nn(NOT, dupnode(ptr->lft), ZN)),
			    ptr->rgt))
		{       ptr = True;
		        break;
		}
		break;
	}
	return ptr;
}

static Node *bin_minimal(Node *ptr)
{       
	Node *a, *b;

	if (ptr)
	{
		switch (ptr->ntyp) 
		{
			case IMPLIES:
				return tl_nn(OR, Not(ptr->lft), ptr->rgt);

			case EQUIV:
				a = tl_nn(AND,dupnode(ptr->lft),dupnode(ptr->rgt));
				b = tl_nn(AND,Not(ptr->lft),Not(ptr->rgt));
				return tl_nn(OR, a, b); 
		}
	}
	return ptr;
}

static Node *
tl_formula(void)
{	tl_yychar = tl_yylex();
	return tl_level(1);	/* 2 precedence levels, 1 and 0 */	
}


static Node *tl_factor(void)
{	
	Node *ptr = ZN;
    int  tl_simp_log=0;
    
	switch (tl_yychar) 
	{
	case '(':
		ptr = tl_formula();
		if (tl_yychar != ')')
			tl_yyerror("expected ')'");
		tl_yychar = tl_yylex();
		goto simpl;

	case NOT:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		ptr = push_negation(ptr);
		goto simpl;

	case ALWAYS:
		ptr = tl_nn(ALWAYS, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		goto simpl;

	case NEXT:
		ptr = tl_nn(NEXT, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

	case WEAKNEXT:
		ptr = tl_nn(WEAKNEXT, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

        
    case EVENTUALLY:
		ptr = tl_nn(EVENTUALLY, ZN, ZN);
		ptr->time =TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		goto simpl;
    
case ALWAYS_PAST:
		ptr = tl_nn(ALWAYS_PAST, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		goto simpl;

	case PREV:
		ptr = tl_nn(PREV, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

	case WEAKPREV:
		ptr = tl_nn(WEAKPREV, ZN, ZN);
		ptr->time = TimeCon;
		tl_yychar = tl_yylex();
		ptr->lft = tl_factor();
		goto simpl;

        
    case EVENTUALLY_PAST:
		ptr = tl_nn(EVENTUALLY_PAST, ZN, ZN);
		ptr->time =TimeCon;
		tl_yychar = tl_yylex();
		ptr->rgt = tl_factor();
		goto simpl;

	simpl:
		if (tl_simp_log) 
		  ptr = bin_simpler(ptr);
		break;

	case PREDICATE:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		break;

	case TRUE:
	case FALSE:
		ptr = tl_yylval;
		tl_yychar = tl_yylex();
		break;
	}
	if (!ptr) tl_yyerror("expected predicate");
#if 0
	printf("factor:	");
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}

static Node *tl_level(int nr)
{	
	int i; Node *ptr = ZN;
	Interval LocInter;

	if (nr < 0)
		return tl_factor();

	ptr = tl_level(nr-1);
again:
	for (i = 0; i < 4; i++)
		if (tl_yychar == prec[nr][i])
		{	
			if (nr==0 && (i==0 || i==1|| i==2|| i==3))
				LocInter = TimeCon;
			tl_yychar = tl_yylex();
			ptr = tl_nn(prec[nr][i],ptr,tl_level(nr-1));
			if (nr==0 && (i==0 || i==1|| i==2|| i==3))
				ptr->time = LocInter;
			if(tl_simp_log) 
				ptr = bin_simpler(ptr);
			else 
				ptr = bin_minimal(ptr);
			goto again;
		}
	if (!ptr) tl_yyerror("syntax error");
#if 0
	printf("level %d:	", nr);
	tl_explain(ptr->ntyp);
	printf("\n");
#endif
	return ptr;
}


Node *tl_parse(void)
{  
   Node *n = tl_formula();
   if (tl_verbose)
	{	printf("formula: ");
		put_uform();
		printf("\n");
	}
	return(n);
}
/***** from lex.c *****/

int isalnum_(int c)
{       
	return (isalnum(c) || c == '_');
}

int hash(char *s)
{       
	int h=0;
	while (*s)
	{       
		h += *s++;
		h <<= 1;
		if (h&(Nhash+1))
			h |= 1;
	}
	return h&Nhash;
}

static void getword(int first, int (*tst)(int))
{	
	int i=0; char c;

	yytext[i++]= (char ) first;
	while (tst(c = tl_Getchar()))
		yytext[i++] = c;
	yytext[i] = '\0';/*yytext[i] = 0;*/
	tl_UnGetchar();
}

Number getnumber(char cc) /* get a number from input string */
{
	int sign = 1;
	int ii = 0; 
	char strnum[80];
	Number num;

	if (cc=='-')
	{	
		sign = -1;
		do {	
			cc = tl_Getchar();
		} while (cc == ' ');
	}
	else if (cc == '+')
	{	
		do {	
			cc = tl_Getchar(); 
		} while (cc == ' ');
	}
	
	if (cc=='i')
	{	cc = tl_Getchar();
		if (cc=='n')
		{	cc = tl_Getchar();
			if (cc=='f')
			{	if (fw_taliro_param.ConOnSamples)
				{	
					num.numi.inf = sign;
					num.numi.i_num = 0;
				}
				else
				{	
					num.numf.inf = sign;
					num.numf.f_num = 0.0;
				}
			}
			else
			{	tl_UnGetchar();
				tl_yyerror("expected a number or a (-)inf in timing constraints!");
				tl_exit(0);
			}
		}
		else
		{	tl_UnGetchar();
			tl_yyerror("expected a number or a (-)inf in timing constraints!");
			tl_exit(0);
		}
	}
	else if (('0'<=cc && cc<='9') || cc=='.')
	{
		strnum[ii++] = cc;
		for (cc = tl_Getchar(); cc!=' '&& cc!=',' && cc!=']' && cc!=')'; cc = tl_Getchar())
		{ 	
			if (ii>=80)
			{	
				tl_UnGetchar();
				tl_yyerror("numeric constants must have length less than 80 characters.");
				tl_exit(0);
			}
			strnum[ii++] = cc;
		}
		tl_UnGetchar();
		strnum[ii] = '\0';
		if (fw_taliro_param.ConOnSamples)
		{	num.numi.inf = 0;
			num.numi.i_num = sign*atoi(strnum);
		}
		else
		{	num.numf.inf = 0;
			num.numf.f_num = (double)sign*atof(strnum);
		}
	}
	else
	{
		tl_UnGetchar();
		tl_yyerror("expected a number or inf");
		tl_exit(0);
	}
	return(num);
}

Interval getbounds(void)
{	
	char cc;
	Interval time;

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');
	
	if (cc!='[' && cc!='(')
	{
		tl_UnGetchar();
		tl_yyerror("expected '(' or '[' after _");
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc=='[')
		time.l_closed = 1;
	else
		time.l_closed = 0;

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');
	
	/* get lower bound */
	time.lbd = getnumber(cc);
	if (e_le(time.lbd,zero,&fw_taliro_param))
	{
		tl_UnGetchar();
		tl_yyerror("past time operators are not allowed - only future time intervals.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	if (cc!=',')
	{	
		tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2>.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	/* get upper bound */
	time.ubd = getnumber(cc);

	if (e_ge(time.lbd,time.ubd,&fw_taliro_param))
	{	tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2> with num1 <= num2.");
		tl_exit(0);
	}

	/* remove spaces */
	do 
	{	cc = tl_Getchar();
	} while (cc == ' ');

	if (cc!=']' && cc!=')')
	{
		tl_UnGetchar();
		tl_yyerror("timing constraints must have the format <num1,num2>, where > is from the set {),]}");
		tl_exit(0);
	}

	/* is interval closed? */
	if (cc==']')
		time.u_closed = 1;
	else
		time.u_closed = 0;

	return time;

}

static int follow(int tok, int ifyes, int ifno)
{	
	int c;
	char buf[32];

	if ((c = tl_Getchar()) == tok)
		return ifyes;
	tl_UnGetchar();
	tl_yychar = c;
	sprintf(buf, "expected '%c'", tok);
	tl_yyerror(buf);	/* no return from here */
	return ifno;
}

static void mtl_con(void)
{
	char c;
	c = tl_Getchar();
	if (c == '_')
	{
		fw_taliro_param.LTL = 0;
		TimeCon = getbounds();
	}
	else
	{
		TimeCon = zero2inf;
		tl_UnGetchar();
	}
}


int
tl_yylex(void)
{	int c = tl_lex();
#if 0
	printf("c = %d\n", c);
#endif
	return c;
}

static int tl_lex(void)
{	
	int c;

	do {
		c = tl_Getchar();
		yytext[0] = (char ) c;
		yytext[1] = '\0';
		if (c <= 0)
		{	Token(';');
		}
	} while (c == ' ');	

	/* get the truth constants true and false and predicates */
	if (islower(c))
	{	getword(c, isalnum_);
		if (strcmp("true", yytext) == 0)/*(strncmp("true", yytext,4) == 0)*/
		{	Token(TRUE);
		}
		if (strcmp("false", yytext) == 0)/*(strncmp("false", yytext,5) == 0)*/
		{	Token(FALSE);
		}
		tl_yylval = tl_nn(PREDICATE,ZN,ZN);
		tl_yylval->sym = tl_lookup(yytext);
		return PREDICATE;
	}
	/* get temporal operators */
	if (c == '<')
	{	
		c = tl_Getchar();
		if (c == '>') 
		{
			tl_yylval = tl_nn(EVENTUALLY,ZN,ZN);
			mtl_con();
			return EVENTUALLY;
		}else if (c == '.') {
       		c = tl_Getchar();
    		if (c == '>') 
        	{
    			tl_yylval = tl_nn(EVENTUALLY_PAST,ZN,ZN);
        		mtl_con();
            	return EVENTUALLY_PAST;
            }else{
    			tl_UnGetchar();
        		tl_yyerror("expected '<.>'");
            }
        }
		if (c != '-')
		{	
			tl_UnGetchar();
			tl_yyerror("expected '<>' or '<->'");
		}
		c = tl_Getchar();
		if (c == '>')
		{	
			Token(EQUIV);
		}
		tl_UnGetchar();
		tl_yyerror("expected '<->'");
	}
    
    if (c == '[')
	{	
		c = tl_Getchar();
		if (c == ']') 
		{
			tl_yylval = tl_nn(ALWAYS,ZN,ZN);
			mtl_con();
			return ALWAYS;
		}else if (c == '.') {
       		c = tl_Getchar();
    		if (c == ']') 
        	{
    			tl_yylval = tl_nn(ALWAYS_PAST,ZN,ZN);
        		mtl_con();
            	return ALWAYS_PAST;
            }else{
    			tl_UnGetchar();
        		tl_yyerror("expected '[.]'");
            }
        }else{	
			tl_UnGetchar();
			tl_yyerror("expected '[]' or '[.]'");
		}
	}

	switch (c) 
	{
		case '/' : 
			c = follow('\\', AND, '/'); 
			break;
		case '\\': 
			c = follow('/', OR, '\\'); 
			break;
		case '&' : 
			c = follow('&', AND, '&'); 
			break;
		case '|' : 
			c = follow('|', OR, '|'); 
			break;
		case '-' : 
			c = follow('>', IMPLIES, '-'); 
			break;
		case '!' : 
			c = NOT; 
			break;
		case 'U' : 
			mtl_con();
			c = U_OPER;
			break;
		case 'R' : 
			mtl_con();
			c = V_OPER;
			break;
		case 'X' : 
			mtl_con();
			c = NEXT;
			break;
		case 'W' : 
			mtl_con();
			c = WEAKNEXT;
			break;
		case 'S' : 
			mtl_con();
			c = S_OPER;
			break;
		case 'T' : 
			mtl_con();
			c = T_OPER;
			break;
		case 'P' : 
			mtl_con();
			c = PREV;
			break;
		case 'Q' : 
			mtl_con();
			c = WEAKPREV;
			break;
		case 'E' : 
			mtl_con();
			c = EVENTUALLY_PAST;
			break;
		case 'A' : 
			mtl_con();
			c = ALWAYS_PAST;
			break;
		default  : break;
	}
	Token(c);
}

Symbol *tl_lookup(char *s)
{	
	Symbol *sp;
	int h = hash(s);

	for (sp = symtab[h]; sp; sp = sp->next)
		if (strcmp(sp->name, s) == 0)
			return sp;

	sp = (Symbol *) emalloc(sizeof(Symbol));
	sp->name = (char *) emalloc(strlen(s) + 1);
	strcpy(sp->name, s);
	sp->next = symtab[h];
	sp->set = NullSet;
	symtab[h] = sp;

	return sp;
}

void tl_clearlookup(char *s)
{
	int ii;
	Symbol *sp, *sp_old;
	
	int h = hash(s);

	for (sp = symtab[h], ii=0; sp; sp_old = sp, sp = sp->next, ii++)
		if (strcmp(sp->name, s) == 0)
		{
			if (ii==0)
				symtab[h] = sp->next;
			else
				sp_old->next = sp->next;
			efree(sp->name);
			efree(sp);
			return;
		}

}


Symbol *getsym(Symbol *s)
{	Symbol *n = (Symbol *) emalloc(sizeof(Symbol));

	n->name = s->name;
	return n;
}

/***** from cache.c *****/


void
cache_dump(void)
{	Cache *d; int nr=0;

	printf("\nCACHE DUMP:\n");
	for (d = stored; d; d = d->nxt, nr++)
	{	if (d->same) continue;
		printf("B%3d: ", nr); dump(d->before); printf("\n");
		printf("A%3d: ", nr); dump(d->after); printf("\n");
	}
	printf("============\n");
}

Node *in_cache(Node *n)
{	
	Cache *d; int nr=0;

	for (d = stored; d; d = d->nxt, nr++)
		if (isequal(d->before, n))
		{	CacheHits++;
			if (d->same && ismatch(n, d->before)) return n;
			return dupnode(d->after);
		}
	return ZN;
}

Node *
cached(Node *n)
{	Cache *d;
	Node *m;

	if (!n) return n;
	if (m = in_cache(n))
		return m;

	Caches++;
	d = (Cache *) emalloc(sizeof(Cache));
	d->before = dupnode(n);
	d->after  = Canonical(n); /* n is released */

	if (ismatch(d->before, d->after))
	{	d->same = 1;
		releasenode(1, d->after);
		d->after = d->before;
	}
	d->nxt = stored;
	stored = d;
	return dupnode(d->after);
}

void
cache_stats(void)
{
	printf("cache stores     : %9ld\n", Caches);
	printf("cache hits       : %9ld\n", CacheHits);
}

/* It frees the memory for the node if all_levels=0
   It frees the memory for the tree if all_levels=1 */
void releasenode(int all_levels, Node *n)
{
	if (!n) return;

	if (all_levels)
	{	releasenode(1, n->lft);
		n->lft = ZN;
		releasenode(1, n->rgt);
		n->rgt = ZN;
	}
	efree((void *) n); 
}

Node *tl_nn(int t, Node *ll, Node *rl)
{	
	Node *n = (Node *) emalloc(sizeof(Node));

	n->ntyp = (short) t;
	n->rob.ds = 0.0;
	n->rob.dl = 0;
	n->sym = ZS;
	n->time = emptyInter;
	n->lft  = ll;
	n->rgt  = rl;
    n->visited = 0;
	return n;
}

Node *getnode(Node *p)
{	
	Node *n;

	if (!p) return p;

	n =  (Node *) emalloc(sizeof(Node));
	n->ntyp = p->ntyp;
	n->rob = p->rob; 
	n->time = p->time; 
	n->sym  = p->sym; 
	n->lft  = p->lft;
	n->rgt  = p->rgt;
    n->visited = 0;
	
	return n;
}

Node *dupnode(Node *n)
{	
	Node *d;

	if (!n) return n;
	d = getnode(n);
	d->lft = dupnode(n->lft);
	d->rgt = dupnode(n->rgt);
	return d;
}

int
one_lft(int ntyp, Node *x, Node *in)
{
	if (!x)  return 1;
	if (!in) return 0;

	if (sameform(x, in))
		return 1;

	if (in->ntyp != ntyp)
		return 0;

	if (one_lft(ntyp, x, in->lft))
		return 1;

	return one_lft(ntyp, x, in->rgt);
}

int
all_lfts(int ntyp, Node *from, Node *in)
{
	if (!from) return 1;

	if (from->ntyp != ntyp)
		return one_lft(ntyp, from, in);

	if (!one_lft(ntyp, from->lft, in))
		return 0;

	return all_lfts(ntyp, from->rgt, in);
}

int
sametrees(int ntyp, Node *a, Node *b)
{	/* toplevel is an AND or OR */
	/* both trees are right-linked, but the leafs */
	/* can be in different places in the two trees */

	if (!all_lfts(ntyp, a, b))
		return 0;

	return all_lfts(ntyp, b, a);
}

int	/* a better isequal() */
sameform(Node *a, Node *b)
{
	if (!a && !b) return 1;
	if (!a || !b) return 0;
	if (a->ntyp != b->ntyp) return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	switch (a->ntyp) {
	case TRUE:
	case FALSE:
		return 1;
	case PREDICATE:
		if (!a->sym || !b->sym) fatal("sameform...", (char *) 0);
		return !strcmp(a->sym->name, b->sym->name);

	case NOT:
	case NEXT:
		return sameform(a->lft, b->lft);
	case U_OPER:
	case V_OPER:
		if (!sameform(a->lft, b->lft))
			return 0;
		if (!sameform(a->rgt, b->rgt))
			return 0;
		return 1;

	case AND:
	case OR:	/* the hard case */
		return sametrees(a->ntyp, a, b);

	default:
		printf("type: %d\n", a->ntyp);
		fatal("cannot happen, sameform", (char *) 0);
	}

	return 0;
}

int
isequal(Node *a, Node *b)
{
	if (!a && !b)
		return 1;

	if (!a || !b)
	{	if (!a)
		{	if (b->ntyp == TRUE)
				return 1;
		} else
		{	if (a->ntyp == TRUE)
				return 1;
		}
		return 0;
	}
	if (a->ntyp != b->ntyp)
		return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	if (isequal(a->lft, b->lft)
	&&  isequal(a->rgt, b->rgt))
		return 1;

	return sameform(a, b);
}

static int
ismatch(Node *a, Node *b)
{
	if (!a && !b) return 1;
	if (!a || !b) return 0;
	if (a->ntyp != b->ntyp) return 0;

	if (a->sym
	&&  b->sym
	&&  strcmp(a->sym->name, b->sym->name) != 0)
		return 0;

	if (ismatch(a->lft, b->lft)
	&&  ismatch(a->rgt, b->rgt))
		return 1;

	return 0;
}

int
any_term(Node *srch, Node *in)
{
	if (!in) return 0;

	if (in->ntyp == AND)
		return	any_term(srch, in->lft) ||
			any_term(srch, in->rgt);

	return isequal(in, srch);
}

int
any_and(Node *srch, Node *in)
{
	if (!in) return 0;

	if (srch->ntyp == AND)
		return	any_and(srch->lft, in) &&
			any_and(srch->rgt, in);

	return any_term(srch, in);
}

int
any_lor(Node *srch, Node *in)
{
	if (!in) return 0;

	if (in->ntyp == OR)
		return	any_lor(srch, in->lft) ||
			any_lor(srch, in->rgt);

	return isequal(in, srch);
}

int
anywhere(int tok, Node *srch, Node *in)
{
	if (!in) return 0;

	switch (tok) {
	case AND:	return any_and(srch, in);
	case  OR:	return any_lor(srch, in);
	case   0:	return any_term(srch, in);
	}
	fatal("cannot happen, anywhere", (char *) 0);
	return 0;
}

/***** ltl2ba : rewrt.c *****/
Node *right_linked(Node *n)
{
	if (!n) 
		return n;

	if (n->ntyp == AND || n->ntyp == OR)
		while (n->lft && n->lft->ntyp == n->ntyp)
		{	
			Node *tmp = n->lft;
			n->lft = tmp->rgt;
			tmp->rgt = n;
			n = tmp;
		}

	n->lft = right_linked(n->lft);
	n->rgt = right_linked(n->rgt);

	return n;
}

/* assumes input is right_linked */
Node *canonical(Node *n)
{	
	Node *m;	

	if (!n) 
		return n;

	if (m = in_cache(n))
		return m;

	n->rgt = canonical(n->rgt);
	n->lft = canonical(n->lft);

	return cached(n);
}

Node *push_negation(Node *n)
{	
	Node *m;

	Assert(n->ntyp == NOT, n->ntyp);

	switch (n->lft->ntyp) {
	case TRUE:
		releasenode(0, n->lft);
		n->lft = ZN;
		n->ntyp = FALSE;
		break;
	case FALSE:
		releasenode(0, n->lft);
		n->lft = ZN;
		n->ntyp = TRUE;
		break;
	case NOT:
		m = n->lft->lft;
		releasenode(0, n->lft);
		n->lft = ZN;
		releasenode(0, n);
		n = m;
		break;
	case V_OPER:
		n = switchNotTempOper(n,U_OPER);
		break;
	case U_OPER:
		n = switchNotTempOper(n,V_OPER);
		break;
	case NEXT:
		n = switchNotTempOper(n,WEAKNEXT);
		break;
	case WEAKNEXT:
		n = switchNotTempOper(n,NEXT);
		break;
	case T_OPER:
		n = switchNotTempOper(n,S_OPER);
		break;
	case S_OPER:
		n = switchNotTempOper(n,T_OPER);
		break;
	case PREV:
		n = switchNotTempOper(n,WEAKPREV);
		break;
	case WEAKPREV:
		n = switchNotTempOper(n,PREV);
		break;
	case  AND:
		n = switchNotTempOper(n,OR);
		break;
	case  OR:
		n = switchNotTempOper(n,AND);
		break;
	}

	return n;
}

Node *switchNotTempOper(Node *n, int ntyp)
{
	Node *m;

	m = n;
	n = n->lft;
	n->ntyp = ntyp;
	m->lft = n->lft;
	n->lft = push_negation(m);
	if (ntyp!=NEXT && ntyp!=WEAKNEXT && ntyp!=PREV && ntyp!=WEAKPREV)
	{
		n->rgt = Not(n->rgt);
	}
	return(n);
}

static void addcan(int tok, Node *n)
{	Node	*m, *prev = ZN;
	Node	**ptr;
	Node	*N;
	Symbol	*s, *t; int cmp;

	if (!n) return;

	if (n->ntyp == tok)
	{	addcan(tok, n->rgt);
		addcan(tok, n->lft);
		return;
	}
#if 0
	if ((tok == AND && n->ntyp == TRUE)
	||  (tok == OR  && n->ntyp == FALSE))
		return;
#endif
	N = dupnode(n);
	if (!can)	
	{	can = N;
		return;
	}

	s = DoDump(N);
	if (can->ntyp != tok)	/* only one element in list so far */
	{	ptr = &can;
		goto insert;
	}

	/* there are at least 2 elements in list */
	prev = ZN;
	for (m = can; m->ntyp == tok && m->rgt; prev = m, m = m->rgt)
	{	t = DoDump(m->lft);
		cmp = strcmp(s->name, t->name);
		if (cmp == 0)	/* duplicate */
			return;
		if (cmp < 0)
		{	if (!prev)
			{	can = tl_nn(tok, N, can);
				return;
			} else
			{	ptr = &(prev->rgt);
				goto insert;
	}	}	}

	/* new entry goes at the end of the list */
	ptr = &(prev->rgt);
insert:
	t = DoDump(*ptr);
	cmp = strcmp(s->name, t->name);
	if (cmp == 0)	/* duplicate */
		return;
	if (cmp < 0)
		*ptr = tl_nn(tok, N, *ptr);
	else
		*ptr = tl_nn(tok, *ptr, N);
}

static void
marknode(int tok, Node *m)
{
	if (m->ntyp != tok)
	{	releasenode(0, m->rgt);
		m->rgt = ZN;
	}
	m->ntyp = -1;
}

Node *Canonical(Node *n)
{	Node *m, *p, *k1, *k2, *prev, *dflt = ZN;
	int tok;

	if (!n) return n;

	tok = n->ntyp;
	if (tok != AND && tok != OR)
		return n;

	can = ZN;
	addcan(tok, n);
#if 1
	Debug("\nA0: "); Dump(can); 
	Debug("\nA1: "); Dump(n); Debug("\n");
#endif
	releasenode(1, n);

	/* mark redundant nodes */
	if (tok == AND)
	{	for (m = can; m; m = (m->ntyp == AND) ? m->rgt : ZN)
		{	k1 = (m->ntyp == AND) ? m->lft : m;
			if (k1->ntyp == TRUE)
			{	marknode(AND, m);
				dflt = True;
				continue;
			}
			if (k1->ntyp == FALSE)
			{	releasenode(1, can);
				can = False;
				goto out;
		}	}
		for (m = can; m; m = (m->ntyp == AND) ? m->rgt : ZN)
		for (p = can; p; p = (p->ntyp == AND) ? p->rgt : ZN)
		{	if (p == m
			||  p->ntyp == -1
			||  m->ntyp == -1)
				continue;
			k1 = (m->ntyp == AND) ? m->lft : m;
			k2 = (p->ntyp == AND) ? p->lft : p;

			if (isequal(k1, k2))
			{	marknode(AND, p);
				continue;
			}
			if (anywhere(OR, k1, k2))
			{	marknode(AND, p);
				continue;
			}
			if (k2->ntyp == U_OPER
			&&  anywhere(AND, k2->rgt, can))
			{	marknode(AND, p);
				continue;
			}	/* q && (p U q) = q */
	}	}
	if (tok == OR)
	{	for (m = can; m; m = (m->ntyp == OR) ? m->rgt : ZN)
		{	k1 = (m->ntyp == OR) ? m->lft : m;
			if (k1->ntyp == FALSE)
			{	marknode(OR, m);
				dflt = False;
				continue;
			}
			if (k1->ntyp == TRUE)
			{	releasenode(1, can);
				can = True;
				goto out;
		}	}
		for (m = can; m; m = (m->ntyp == OR) ? m->rgt : ZN)
		for (p = can; p; p = (p->ntyp == OR) ? p->rgt : ZN)
		{	if (p == m
			||  p->ntyp == -1
			||  m->ntyp == -1)
				continue;
			k1 = (m->ntyp == OR) ? m->lft : m;
			k2 = (p->ntyp == OR) ? p->lft : p;

			if (isequal(k1, k2))
			{	marknode(OR, p);
				continue;
			}
			if (anywhere(AND, k1, k2))
			{	marknode(OR, p);
				continue;
			}
			if (k2->ntyp == V_OPER
			&&  k2->lft->ntyp == FALSE
			&&  anywhere(AND, k2->rgt, can))
			{	marknode(OR, p);
				continue;
			}	/* p || (F V p) = p */
	}	}
	for (m = can, prev = ZN; m; )	/* remove marked nodes */
	{	if (m->ntyp == -1)
		{	k2 = m->rgt;
			releasenode(0, m);
			if (!prev)
			{	m = can = can->rgt;
			} else
			{	m = prev->rgt = k2;
				/* if deleted the last node in a chain */
				if (!prev->rgt && prev->lft
				&&  (prev->ntyp == AND || prev->ntyp == OR))
				{	k1 = prev->lft;
					prev->ntyp = prev->lft->ntyp;
					prev->sym = prev->lft->sym;
					prev->rgt = prev->lft->rgt;
					prev->lft = prev->lft->lft;
					releasenode(0, k1);
				}
			}
			continue;
		}
		prev = m;
		m = m->rgt;
	}
out:
#if 1
	Debug("A2: "); Dump(can); Debug("\n");
#endif
	if (!can)
	{	if (!dflt)
			fatal("cannot happen, Canonical", (char *) 0);
		return dflt;
	}

	return can;
}

/***** from  mtlmonitor.c *****/



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

/***** from : distances.c *****/

#define MIN_DIM 100

/* Hybrid distance computation without taking into account distance from guard sets */
HyDis SignedHDist0(double *xx, ConvSet *SS, int dim, double *LDist, mwSize tnLoc)
{
	int inLoc;
	mwIndex ii;
	HyDis dist;

	/* Are we in right control location? */
	inLoc = 0;
	for (ii=0; ii<SS->nloc; ii++)
		if (((int)xx[dim])==((int)SS->loc[ii]))
		{
			inLoc = 1;
			break;
		}
	/* Compute hybrid metric */
	if (inLoc)
	{
		dist.dl = 0;
		dist.ds = SignedDist(xx,SS,dim);
	}
	else
	{
		dist.dl = -(int)LDist[((int)xx[dim]-1)+((int)SS->idx)*tnLoc];
		dist.ds = -mxGetInf();
	}
	return(dist);
}

HyDis SignedHDistG(double *xx, ConvSet *SS, int dim, DistCompData *distData, mwSize tnLoc)
{
	bool inLoc; 
	int pathDist;
	mwIndex jj, im1, kk;
	HyDis dist;
	ConvSet GS;
	double tmp_dist, tmp_dist_min;
	mxArray *Aout, *bout, *xout;
	double *Atemp, *btemp, *xtemp; /* temporary pointers to set the values of the mxArrays */
	mxArray *lhs[1], *rhs[3];
	int i1,i2,i3;
	int cloc;

	cloc = (int)(xx[dim]);
	im1 = cloc-1;	
	inLoc = 0;
	/* Are we in right control location? */
	for (jj=0; jj<SS->nloc; jj++)
	{
		if (cloc==((int)SS->loc[jj]))
		{
			inLoc = 1;
			break;
		}
	}
		/* Compute hybrid metric */
		if (inLoc)
		{
			dist.dl = 0;
			dist.ds = SignedDist(xx,SS,dim);
		}
		else
		{
			pathDist = (int)distData->LDist[im1+((int)SS->idx)*tnLoc];
			dist.dl = -pathDist;
			dist.ds = -mxGetInf();
			if (distData->AdjLNell[im1]>0)
			{
				for (jj=0; jj<distData->AdjLNell[im1]; jj++)
				{
					kk = (int)distData->AdjL[im1][jj]-1;
					if ((int)distData->LDist[kk+((int)SS->idx)*tnLoc]<pathDist)
					{
						tmp_dist_min = -mxGetInf();
						for (i1=0; i1<distData->GuardMap[im1][jj].nset; i1++)
						{
							GS.ncon = distData->GuardMap[im1][jj].ncon[i1];
							GS.isSetRn = false;
							GS.A = distData->GuardMap[im1][jj].A[i1];
							GS.b = distData->GuardMap[im1][jj].b[i1];
							if (GS.ncon==1)
								tmp_dist = SignedDist(xx,&GS,dim);
							else
							{
								Aout = mxCreateDoubleMatrix(GS.ncon, dim, mxREAL);
								bout = mxCreateDoubleMatrix(GS.ncon, 1, mxREAL);
								xout = mxCreateDoubleMatrix(dim, 1, mxREAL);
								Atemp = mxGetPr(Aout);
								btemp = mxGetPr(bout);
								xtemp = mxGetPr(xout);
								for (i3=0; i3<dim; i3++)
									xtemp[i3] = xx[i3];
								for (i2=0; i2<GS.ncon; i2++)
								{
									btemp[i2] = GS.b[i2];
									for (i3=0; i3<dim; i3++)
										Atemp[i3*GS.ncon+i2] = GS.A[i2][i3];
								}
								rhs[0] = xout; rhs[1] = Aout; rhs[2] = bout;
								mexCallMATLAB(1,lhs,3,rhs,"SignedDist");
								tmp_dist = *(mxGetPr(lhs[0]));
								mxDestroyArray(lhs[0]);
								mxDestroyArray(xout);
								mxDestroyArray(bout);
								mxDestroyArray(Aout);
							}

							if (tmp_dist>0)
							{
								mexPrintf("%s%d%s%d%s \n", "Guard: (",cloc,",",kk+1,")");
								mexPrintf("%s%f \n", "Signed distance: ", &tmp_dist);
								mexErrMsgTxt("taliro: Above control location: The signed distance to the guard set is positive!"); 
							}
							/* Since the distances are always negative (the current point should never be within the current guard 
							   assuming ASAP transitions), then the required distance will be the maximum of the negative
							   distances returnde. */
							tmp_dist_min = max(tmp_dist_min,tmp_dist);
						}
						dist.ds = max(dist.ds,tmp_dist_min);
					}
				}
			}
		}
	
	return(dist);
}


/* Hybrid distance computation that takes into account distance from guard sets */
double SignedDist(double *xx, ConvSet *SS, int dim)
{
	double dist;
	int ii, jj;
	/* Temporary vectors */
	double x0[MIN_DIM];
	double *x0d; /* In case dim is larger than MIN_DIM */
	double *xtemp, *Atemp, *btemp; /* temporary pointers to set the values of the mxArrays */
	/* Temporary scalars */
	double aa, cc; 
	/* Temporary mxArrays to pass to Matlab */
	mxArray *Xout, *Aout, *bout;
	mxArray *lhs[1], *rhs[3];

	if (SS->isSetRn)
		return (mxGetInf());
	else
	{
		if (dim==1)
		{
			dist = fabs(SS->b[0]/SS->A[0][0]-*xx);
			if (SS->ncon==2)
				dist = dmin(dist,fabs(SS->b[1]/SS->A[1][0]-*xx));
			if (isPointInConvSet(xx, SS, dim))
				return(dist);
			else
				return(-dist);
		}
		else
		{
			/* if we have only one constraint in multi-Dimensional signals */
			if (SS->ncon==1)
			{
				if (dim<MIN_DIM)
				{
					/* Projection on the plane: x0 = x+(b-a*x)*a'/norm(a)^2; */
					aa = norm(SS->A[0],dim);
					aa *= aa;
					cc = ((SS->b[0]) - inner_prod(SS->A[0],xx,dim))/aa;
					vec_scl(x0,cc,SS->A[0],dim);
					dist = norm(x0,dim);
					if (isPointInConvSet(xx, SS, dim))
						return(dist);
					else
						return(-dist);
				}
				else
				{
					/* Projection on the plane: x0 = x+(b-a*x)*a'/norm(a)^2; */
					x0d = (double *)emalloc(sizeof(double)*dim);
					aa = norm(SS->A[0],dim);
					aa *= aa;
					cc = ((SS->b[0]) - inner_prod(SS->A[0],xx,dim))/aa;
					vec_scl(x0d,cc,SS->A[0],dim);
					dist = norm(x0d,dim);
					efree(x0d);
					if (isPointInConvSet(xx, SS, dim))
						return(dist);
					else
						return(-dist);
				}
			}
			/* if we have more than one constraints in multi-Dimensional signals */
			else
			{
				/* Prepare data and call SignedDist.m */
				/* From help: If unsuccessful in a MEX-file, the MEX-file terminates and control returns to the MATLAB prompt. */
				/* Alternatively use mexCallMATLABWithTrap */
				Xout = mxCreateDoubleMatrix(dim, 1, mxREAL);
				Aout = mxCreateDoubleMatrix(SS->ncon, dim, mxREAL);
				bout = mxCreateDoubleMatrix(SS->ncon, 1, mxREAL);
				xtemp = mxGetPr(Xout); 
				Atemp = mxGetPr(Aout);
				btemp = mxGetPr(bout);
				for(ii=0; ii<dim; ii++)
					xtemp[ii] = xx[ii];
				for(ii=0; ii<SS->ncon; ii++)
				{
					btemp[ii] = SS->b[ii];
					for (jj=0; jj<dim; jj++)
						Atemp[jj*SS->ncon+ii] = SS->A[ii][jj];
				}
				rhs[0] = Xout; rhs[1] = Aout; rhs[2] = bout;
				mexCallMATLAB(1,lhs,3,rhs,"SignedDist");
				dist = *(mxGetPr(lhs[0]));
				mxDestroyArray(lhs[0]);
				mxDestroyArray(bout);
				mxDestroyArray(Aout);
				mxDestroyArray(Xout);
				return(dist);
			}
		}
	}
}


int isPointInConvSet(double *xx, ConvSet *SS, int dim)
{
	int i;
	for (i=0; i<SS->ncon; i++)
		if (inner_prod(SS->A[i],xx,dim)>SS->b[i])
			return(0);
	return(1);
}

/* Inner product of vectors vec1 and vec2 */
double inner_prod(double *vec1, double *vec2, int dim)
{
	int i;
	double sum=0.0;
	for (i=0; i<dim; i++)
		sum += vec1[i]*vec2[i];
	return(sum);
}

/* Computation of the Euclidean norm of a vector */
double norm(double *vec, int dim)
{
	int i;
	double nr=0.0;
	for (i=0; i<dim; i++)
		nr += vec[i]*vec[i];
	return(sqrt(nr));
}

/* Addition of vectors vec1 and vec2
   The result is returned at vec0 */
void vec_add(double* vec0, double *vec1, double *vec2, int dim)
{
	int i;
	for (i=0; i<dim; i++)
		vec0[i] = vec1[i]+vec2[i];
}

/* Multiplication of vector (vec1) with a scalar (scl)
   The result is returned at vec0 */  
void vec_scl(double *vec0, double scl, double *vec1, int dim)
{
	int i;
	for (i=0; i<dim; i++)
		vec0[i] = scl*vec1[i];
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
			else { /* stuff the phi passed in the last of the queue if the queue is not empty*/
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
    if (q->first == q->last)	/* if the queue has only one element*/
        q->first = q->last = NULL;
    else                      /*  pop the first element out of the queue*/
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

int BreadthFirstTraversal(struct queue *q,Node *root,int *i)
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
			BreadthFirstTraversal( q,p->lft,i);
		if (p->rgt != NULL)
			BreadthFirstTraversal( q,p->rgt,i);

	}
	return (*i-1);
} 

/* cluster of functions for BFS ends */



#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

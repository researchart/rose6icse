/***** mx_debugging : mx_debugging.c *****/

/* Written by Adel Dokhanchi, ASU, U.S.A.                              */
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

/* Some of the code in this file was taken from LTL2BA software           */
/* Written by Denis Oddoux, LIAFA, France					              */
/* Some of the code in this file was taken from the Spin software         */
/* Written by Gerard J. Holzmann, Bell Laboratories, U.S.A.               */


#include <stdlib.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "vacuity.h"

FILE *tl_out;

/* Default parameters */
#define BUFF_LEN 4096
FWTaliroParam fw_taliro_param = {1, 0, 0, 0, 0, 0, 0}; 

/* Global variables */
Number zero, inf;
Interval zero2inf, emptyInter,zeroInter;

static char	dumpbuf[BUFF_LEN];
char mtl[BUFF_LEN];
char ltl[BUFF_LEN];
Node ** conjunctNodes;

int  litNum;
int  conjNum;
int  antecNum;

int tl_simp_log  = 0; /* logical simplification */
int	tl_errs      = 0;
int	tl_verbose   = 0;
int	tl_terse     = 0;

/* temporal logic formula */
static char	uform[BUFF_LEN];
static size_t hasuform=0;
static int cnt;

/* Definitions */

char * emalloc(size_t n)
{       
	char *tmp;
	
	if (!(tmp = (char *) mxMalloc(n)))
        mexErrMsgTxt("mx_debugging: not enough memory!");
	memset(tmp, 0, n);
	return tmp;
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

void run_MITL_sat()
{	
     /*  Vacuity Test */
     FILE * pFile;
     pFile = fopen ("input.tl","w");
     if (pFile!=NULL)
     { 
         fputs (":qtl-i\n:bound 20\n\n\n",pFile);
         fputs (":formula",pFile);
         
     }
     fclose (pFile);
    /*  Vacuity Test */

}

void emptymtl(){
    int i;
    for(i=0; i<BUFF_LEN ; i++){
        mtl[i]='\0';
        ltl[i]='\0';
    }
}

void file4GraphVis(int *c, Node *n, FILE * f){
	int i;
	if (!n) return;
	(*c)++;
	i=(*c);
	switch (n->ntyp)
	{
	case TRUE:
		fprintf(f, "  \"TRUE(%d)\"\n",i);
		break;
	case FALSE:
		fprintf(f, "  \"FALSE(%d)\"\n",i);
		break;
	case PREDICATE:
		fprintf(f, "  \"%s(%d)\"\n", n->sym->name,i);
		break;
	case NOT:
		fprintf(f, "  \"NOT(%d)\"\n",i);
		fprintf(f, "  \"NOT(%d)\" ->",i);
		file4GraphVis(c,n->lft,f);
		break;
	case AND:
		fprintf(f, "  \"AND(%d)\"\n",i);
		fprintf(f, "  \"AND(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		fprintf(f, "  \"AND(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case OR:
		fprintf(f, "  \"OR(%d)\"\n",i);
		fprintf(f, "  \"OR(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		fprintf(f, "  \"OR(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case IMPLIES:
		fprintf(f, "  \"IMPLIES(%d)\"\n",i);
		fprintf(f, "  \"IMPLIES(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		fprintf(f, "  \"IMPLIES(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case NEXT:
		fprintf(f, "  \"NEXT(%d)\"\n",i);
		fprintf(f, "  \"NEXT(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		break;
	case WEAKNEXT:
		fprintf(f, "  \"WEAKNEXT(%d)\"\n",i);
		fprintf(f, "  \"WEAKNEXT(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		break;
	case U_OPER:
		fprintf(f, "  \"U(%d)\"\n",i);
		fprintf(f, "  \"U(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		fprintf(f, "  \"U(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case V_OPER:
		fprintf(f, "  \"R(%d)\"\n",i);
		fprintf(f, "  \"R(%d)\" ->",i);
		file4GraphVis(c, n->lft, f);
		fprintf(f, "  \"R(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case EVENTUALLY:
		fprintf(f, "  \"<>(%d)\"\n",i);
		fprintf(f, "  \"<>(%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	case ALWAYS:
		fprintf(f, "  \"[](%d)\"\n",i);
		fprintf(f, "  \"[](%d)\" ->",i);
		file4GraphVis(c, n->rgt, f);
		break;
	default:
		break;
	}
}

void countConjunctionSubTrees(int *index, Node *n){
	if (!n) return;
    if( n->ntyp!=AND ){
        if(n->lft&&n->lft->ntyp==AND){
            (*index)++;
            n->lft->conjunction=(*index);
        }
        if(n->rgt&&n->rgt->ntyp==AND){
            (*index)++;
            n->rgt->conjunction=(*index);
        }
    }
    countConjunctionSubTrees(index,n->lft);
    countConjunctionSubTrees(index,n->rgt);
}

void countSubTreeConjunct(int *index, Node *phi){
    if (!phi) return;
    
    if( phi->ntyp==AND ){
        (*index)++;
        countSubTreeConjunct(index,phi->rgt);
        countSubTreeConjunct(index,phi->lft);
        return;
    }
    else{
        return;
    }
}

void findSubTrees(Node *phi,Node **conjNodes){
    if (!phi) return;
    
    if(phi->conjunction>0)
        conjNodes[phi->conjunction-1] = phi;
    
    findSubTrees(phi->lft,conjNodes);
    findSubTrees(phi->rgt,conjNodes);
}

void findSubTreeConjuncts(int *index, Node *phi, Node **conjNodes){
    if (!phi) return;
    
    if( phi->ntyp==AND ){
        if (phi->rgt->ntyp==AND){
			findSubTreeConjuncts(index,phi->rgt, conjNodes);
        }
        else{
            conjNodes[*index] = phi->rgt;
            (*index)++;
        }
        if (phi->lft->ntyp==AND){
			findSubTreeConjuncts(index,phi->lft, conjNodes);
        }
        else{
            conjNodes[*index] = phi->lft;
            (*index)++;
        }
        return;
    }
    else{
        return;
    }
}

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{	
	/* Variables needed to process the input */
	int status;
    mwSize buflen;
	size_t strsize;
	mwSize  ndim;
	const mwSize *dims;
	mwIndex   iii;
	int ii,jj,kk,ii1;
	mxArray *mitl;
    
    int ln,cn,cln,an,numSubTree,numST,*subTreeConjuncts;
    char **specifications;
    int debug_type,redund_type;
    char  debug_text[100]={'\0'};
    char  redund_text[100]={'\0'};
	/* Variables needed for monitor */
	Node *node,*node1,*node2,*node3,*bigAnd,*falseNode,*notNode,**conjunctNodes;
    Node **subTreeNodes,***subTreeConjunctNodes;


    char    message[BUFF_LEN];
  	static int *index,*subTree;
	int temp = 0;

	/* Reset cnt to 0:
		cnt is the counter that points to the next symbol in the formula
		to be processed. This is a static variable and it retains its 
		value between Matlab calls to mx_debugging. 
	cnt = 0;
	FILE * pFile;
	pFile = fopen("file4GraphViz.txt", "w");
	if (pFile != NULL)
	{
		fputs("Check with: http://www.webgraphviz.com/ :", pFile);
		fputs("\ndigraph G {\n", pFile);
	}*/

	/* Other initializations */
	fw_taliro_param.nInp = nrhs;
 
	/* Make sure the I/O are in the right form */
    if(nrhs < 3)
		mexErrMsgTxt("mx_debugging: Must have at least 3 inputs.");
/*     else if(nlhs > 1)
       mexErrMsgTxt("mx_debugging: Too many output arguments.");*/
    if(!mxIsChar(prhs[0]))
      mexErrMsgTxt("mx_debugging: 1st input must be a string with TL formula.");
    else if(!mxIsStruct(prhs[1]))
      mexErrMsgTxt("mx_debugging: 2nd input must be a structure (predicate map).");
    else if(!(mxIsChar(prhs[2])))
      mexErrMsgTxt("mx_debugging: 3rd input must be a string of debugging type.");
    else if(nrhs==4 && !(mxIsChar(prhs[3])))
      mexErrMsgTxt("mx_debugging: 4rd input must be a string of redundancy type.");
    /* Get the debugging type */
    dims = mxGetDimensions(prhs[2]);
	buflen = dims[1]*sizeof(mxChar)+1;
    if (buflen >= 100)
	{
      mexPrintf("%s%d%s\n", "The debugging type must be less than ", 100," characters.");
      mexErrMsgTxt("mx_debugging: debugging type too long.");
	}
    status = mxGetString(prhs[2], debug_text, buflen);  
    hasuform = strlen(debug_text);
    if(strncmp (debug_text,"validity",hasuform) == 0)
        debug_type=1;
    else if(strncmp (debug_text,"redundancy",hasuform) == 0)
        debug_type=2;
    else if(strncmp (debug_text,"vacuity",hasuform) == 0)
        debug_type=3;
    else if(strncmp (debug_text,"antecedent_failure",hasuform) == 0)
        debug_type=4;
    else 
        mexErrMsgTxt("mx_debugging: debug_type must contain one of these values:\n validity, redundancy, vacuity, antecedent_failure");
    /* Get the redundancy type */
	if (nrhs == 4){
		dims = mxGetDimensions(prhs[3]);
		buflen = dims[1]*sizeof(mxChar)+1;
		if (buflen >= 100)
		{
	      mexPrintf("%s%d%s\n", "The redundancy type must be less than ", 100," characters.");
		  mexErrMsgTxt("mx_debugging: redundancy type too long.");
		}
		status = mxGetString(prhs[3], redund_text, buflen);  
	    hasuform = strlen(redund_text);
		if(strncmp (redund_text,"root",hasuform) == 0)
			redund_type=1;
	    else if (strncmp (redund_text,"subTrees",hasuform) == 0)
		    redund_type=2;
        else if (strncmp (redund_text,"allNodes",hasuform) == 0)
		    redund_type=3;
        else
            mexErrMsgTxt("mx_debugging: redound_type must contain one of these values:\n root, subTrees, allNodes");
	}
	else{
		redund_type = 1;
	}
    /*debug_type=mxGetScalar(prhs[2]);*/
    if (debug_type<1||debug_type>4)
        mexErrMsgTxt("mx_debugging: debug_type input must be between 1~4.");

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);

	/* Process inputs */

	/* Get the formula */
	ndim = mxGetNumberOfDimensions(prhs[0]);
	dims = mxGetDimensions(prhs[0]);
	buflen = dims[1]*sizeof(mxChar)+1;
	if (buflen >= BUFF_LEN)
	{
      mexPrintf("%s%d%s\n", "The formula must be less than ", BUFF_LEN," characters.");
      mexErrMsgTxt("mx_debugging: Formula too long.");
	}
	status = mxGetString(prhs[0], uform, buflen);   
    hasuform = strlen(uform);
    for (iii=0; iii<hasuform; iii++)
	{
		if (uform[iii] == '\t' || uform[iii] == '\"' || uform[iii] == '\n')						
			uform[iii] = ' ';
	}
	zero2inf.l_closed = 1;
	zero2inf.u_closed = 0;
	emptyInter.l_closed = 0;
	emptyInter.u_closed = 0;
    zeroInter.l_closed = 1;
    zeroInter.u_closed = 1;
	if (fw_taliro_param.ConOnSamples)
	{	
		zero.numi.inf = 0;
		zero.numi.i_num = 0;
		inf.numi.inf = 1;
		inf.numi.i_num = 0;
		zero2inf.lbd = zero; 
		zero2inf.ubd = inf;
		emptyInter.lbd = zero;
		emptyInter.ubd = zero;
		zeroInter.lbd = zero;
		zeroInter.ubd = zero;
	}
	else
	{	
		zero.numf.inf = 0;
		zero.numf.f_num = 0.0;
		inf.numf.inf = 1;
		inf.numf.f_num = 0.0;
		zero2inf.lbd = zero;
		zero2inf.ubd = inf;
		emptyInter.lbd = zero;
		emptyInter.ubd = zero;
		zeroInter.lbd = zero;
		zeroInter.ubd = zero;
	}

	
	if(debug_type != 4)
        node = tl_parse(1);
    else{
        node = tl_parse(0);
        findIntervals(node,zeroInter);
    }
    /*  For GraphViz  *
	temp = 0;
	index = &temp;
	file4GraphVis(index,node, pFile);
	fputs("}\n", pFile);
	fclose(pFile);
    /*  Check the number of Time Variables  */

    
    litNum=0;
    conjNum=0;
    antecNum=0;
	if (debug_type == 2 || debug_type == 3){
		countConjunctions(node);
		countLiterals(node);
        temp = 0;
        subTree = &temp;
        countConjunctionSubTrees(subTree,node);
        /*mexPrintf("\n Number of conjunction subtrees are %d\n",(*subTree));*/
		numSubTree = (*subTree);
	}
	else if (debug_type == 4){
        /*mexPrintf("if(debug_type==4)\n");
        mtl_print(node);
        mexPrintf("\n");*/
    	countAntecedent(node);
        mexPrintf("\n-----------------------------\nNumber of antecedents are %d\n-----------------------------\n", antecNum);
        if(antecNum!=1)
            mexErrMsgTxt("Only one antecedent is accepted for the signal vacuity");
    }
    if(debug_type == 2 && numSubTree>0 ){/*&&( redund_type==2 || redund_type==3 )*/
        subTreeNodes=(Node **)emalloc(numSubTree*sizeof(Node *));
        subTreeConjuncts=(int*)emalloc(numSubTree*sizeof(int));
        subTreeConjunctNodes=(Node ***)emalloc(numSubTree*sizeof(Node **));
        findSubTrees(node,subTreeNodes);
        for(ii=1;ii<=numSubTree;ii++){
            if(subTreeNodes[ii-1]->ntyp==AND){
                temp = 0;
                index = &temp;
                countSubTreeConjunct(index,subTreeNodes[ii-1]);
                subTreeConjuncts[ii-1]=(*index)+1;
/*                mexPrintf("\n Conjunction Subtrees %d has %d conjuncts\n",ii,subTreeConjuncts[ii-1]);*/
            }
            else{
                mexErrMsgTxt("Error on the Conjunction Subtrees ");
            }
        }
    }
    ln=litNum;
    /*mexPrintf("\n Number of Literals %d\n",litNum);
    mexPrintf("\n Number of Conjunctions %d\n",conjNum);*/
    bigAnd=tl_nn(AND,  ZN, ZN);
    if(debug_type==1){/*   Validity Issue Detection     */
        specifications=(char **)emalloc(6*sizeof(char *));
        notNode = dupnode(node);
        notNode = tl_not(notNode);
        node1 = dupnode(node);
        /*mexPrintf("MTL is : ");
        mtl_print(node1);*/
        emptymtl();
        /*mexPrintf("\n");*/
        strcpy(mtl,"");
        mtl2qtl(node1);
        /*mexPrintf("\n %s\n",mtl);*/
        strsize=strlen(mtl);
        /*mexPrintf("\n MTL size is %d\n",strsize);*/
        if(strsize>0){
              specifications[1]=(char *)emalloc(strsize*sizeof(char));
              strcpy(specifications[1], mtl);
              /*mexPrintf("\n MITL string is %s\n",specifications[1]);*/
        }
        if (checkSingleTemporal()){
            /*mexPrintf("\n LTL \n");*/
            emptymtl();
            strcpy (ltl,"");
            mtl2ltl(node1);
            strsize=strlen(ltl);
            specifications[0]=(char *)emalloc(strsize*sizeof(char));
            strcpy(specifications[0], ltl);
        }
        else{
            /*mexPrintf("\n MITL \n");*/
            specifications[0]=(char *)emalloc(5*sizeof(char));
            strcpy(specifications[0], "MITL");
        }
        
        strcpy(message,"Specification is Unsatisfiable");
        strcat(message,".\n ERROR : Validity issue is detected in");
        strsize=strlen(message);
        specifications[2]=(char *)emalloc(strsize*sizeof(char));
        strcpy(specifications[2], message);
              
        /*mexPrintf("MTL is : ");
        mtl_print(notNode);*/
        emptymtl();
        /*mexPrintf("\n");*/
        strcpy (mtl,"");
        mtl2qtl(notNode);
        /*mexPrintf("\n %s\n",mtl);*/
        strsize=strlen(mtl);
        /*mexPrintf("\n MTL size is %d\n",strsize);*/
        if(strsize>0){
              specifications[4]=(char *)emalloc(strsize*sizeof(char));
              strcpy(specifications[4], mtl);
              /*mexPrintf("\n MITL string is %s\n",specifications[4]);*/
        }
  
        if (checkSingleTemporal()){
            /*mexPrintf("\n LTL \n");*/
            emptymtl();
            strcpy (ltl,"");
            mtl2ltl(notNode);
            strsize=strlen(ltl);
            specifications[3]=(char *)emalloc(strsize*sizeof(char));
            strcpy(specifications[3], ltl);
        }
        else{
            /*mexPrintf("\n MITL \n");*/
            specifications[3]=(char *)emalloc(5*sizeof(char));
            strcpy(specifications[3], "MITL");
        }
        
        strcpy(message,"Specification is a Tautology");
        strcat(message,".\n ERROR : Validity issue is detected in");
        strsize=strlen(message);
        specifications[5]=(char *)emalloc(strsize*sizeof(char));
        strcpy(specifications[5], message);
      
        
        
        mitl=mxCreateCharMatrixFromStrings(6,(const char **)specifications);

    }
    else if(conjNum==0&&debug_type==3){/*  Vacuity Issue Detection    */
		cn = 1;
        specifications=(char **)emalloc((ln*3)*sizeof(char *));
        for(ii=1;ii<=ln;ii++){
            bigAnd=tl_nn(AND,  ZN, ZN);
            node1 = dupnode(node);
            litNum=0;
            falseNode=tl_nn(AND,  ZN, ZN);
            falseNode->ntyp=FALSE;
            node2 = dupnode(node);
            ii1=changeLiteral(node2,ii,falseNode);
            if(ii1==0){
                /*mexPrintf("No predicate is found"); */
            }
            node3 = dupnode(node2);
            /*mexPrintf("\n Node 3 ----------\n");
            mtl_print(node3);
            mexPrintf("------------\n");*/
            notNode=tl_not(node2);
            /*mexPrintf("\n Not Node ----------\n");
            mtl_print(node2);
            mexPrintf("------------\n");*/
            bigAnd->lft=node1;
            /*mexPrintf("\n notNode is            : ");
            mtl_print(notNode);*/
            bigAnd->rgt=notNode;
            bigAnd=SimplifyNodeValue(bigAnd);/* FOR MITL VS LTL
            mexPrintf("\n\n MTL is : ");
            mtl_print(bigAnd);*/
            emptymtl();
            /*mexPrintf("\n");*/
            strcpy (mtl,"");
            mtl2qtl(bigAnd);
            /*mexPrintf("\n %s\n",mtl);*/
            strsize=strlen(mtl);
            /*mexPrintf("\n MTL size is %d\n",strsize);*/
            if(strsize>0){
                specifications[(ii-1)*3+1]=(char *)emalloc(strsize*sizeof(char));
                strcpy(specifications[(ii-1)*3+1], mtl);
                /*mexPrintf("\n MITL string is %s\n",specifications[(ii-1)*3+1]);*/
            }
            bigAnd=SimplifyNodeValue(bigAnd);
            emptymtl();
            strcpy (mtl,"");
            mtl2qtl(bigAnd);
            if (checkSingleTemporal()){
                /*mexPrintf("\n LTL \n");*/
                emptymtl();
                strcpy (ltl,"");
                mtl2ltl(bigAnd);
                strsize=strlen(ltl);
                specifications[(ii-1)*3]=(char *)emalloc(strsize*sizeof(char));
                strcpy(specifications[(ii-1)*3], ltl);
            }
            else{
                /*mexPrintf("\n MITL \n");*/
                specifications[(ii-1)*3]=(char *)emalloc(5*sizeof(char));
                strcpy(specifications[(ii-1)*3], "MITL");
            }
            emptymtl();
            strcpy (mtl,"");
            mtl2strI(node3);
            /*mexPrintf("\n Node 3 ----------\n");
            mtl_print(node3);
            mexPrintf("------------\n");*/
            strcpy(message,"Specification satisfies ");
            strcat(message,mtl);
            strcat(message,".\n ERROR : Vacuity issue is detected in");
            strsize=strlen(message);
            specifications[(ii-1)*3+2]=(char *)emalloc(strsize*sizeof(char));
            strcpy(specifications[(ii-1)*3+2], message);          
        }
		mitl=mxCreateCharMatrixFromStrings((ln*3),(const char **)specifications);
    }
    else if(conjNum>0&&debug_type==2&&redund_type==1){/*  Redundancy Issue Detection    */
        cn=conjNum+1;
        specifications=(char **)emalloc(cn*3*sizeof(char *));
        conjunctNodes=(Node **)emalloc(cn*sizeof(Node *));
        conjNum=0;
        findConjuncts(node,conjunctNodes);
        if(conjNum!=cn){
            mexErrMsgTxt("Error on the number of conjuncts");      
        }
        for(jj=0;jj<conjNum;jj++){
			/* Specification is in NNF */
			 if(conjunctNodes[jj]->ntyp==PREDICATE){
				 node1=dupnode(conjunctNodes[jj]);
			     conjunctNodes[jj]->ntyp=NOT;
			     conjunctNodes[jj]->lft=node1;
             }
			 else if(conjunctNodes[jj]->ntyp==NOT){
				 conjunctNodes[jj]->ntyp=PREDICATE;
				 conjunctNodes[jj]->sym=conjunctNodes[jj]->lft->sym;
			 }
			 else
				conjunctNodes[jj] = tl_not(conjunctNodes[jj]);
             /*mexPrintf("\nconjunct is\n");
             mtl_print(conjunctNodes[jj]);
             mexPrintf("\n\n");
             emptymtl();
             mexPrintf("\n");*/
             strcpy (mtl,"");
             mtl2qtl(node);
             /*mexPrintf("\n %s\n",mtl);*/
             strsize=strlen(mtl);
             /*mexPrintf("\n MTL size is %d\n",strsize);*/
             if(strsize>0){
                   specifications[jj*3+1]=(char *)emalloc(strsize*sizeof(char));
                   strcpy(specifications[jj*3+1], mtl);
                   /*mexPrintf("\n MITL string is %s\n",specifications[jj*2+1]);*/
             }
             
             if (checkSingleTemporal()){
                 /*mexPrintf("\n LTL \n");*/
                 emptymtl();
                 strcpy (ltl,"");
                 mtl2ltl(node);
                 strsize=strlen(ltl);
				 specifications[3*jj] = (char *)emalloc(strsize*sizeof(char));
                 strcpy(specifications[3*jj], ltl);
             }
             else{
                 /*mexPrintf("\n MITL \n");*/
                 specifications[3*jj]=(char *)emalloc(5*sizeof(char));
                 strcpy(specifications[3*jj], "MITL");
             }
             
			 /*if(conjunctNodes[jj]->ntyp==PREDICATE)
				conjunctNodes[jj]->ntyp=NOT;
			 else if(conjunctNodes[jj]->ntyp==NOT){
				conjunctNodes[jj]=PREDICATE;
			 }
			 else*/
				conjunctNodes[jj] = tl_not(conjunctNodes[jj]);
             
			 mexPrintf("\nconjunct is\n");
			 mtl_print(conjunctNodes[jj]);
			 mexPrintf("\n\n");
			 emptymtl();
			 strcpy(mtl, "");
			 mtl2strI(conjunctNodes[jj]);
             strcpy(message,mtl);
             strcat(message," is Redundant");
             strcat(message,".\n ERROR : Redundancy issue is detected in");
             strsize=strlen(message);
             specifications[jj*3+2]=(char *)emalloc(strsize*sizeof(char));
             strcpy(specifications[jj*3+2], message);
        }
	    mitl=mxCreateCharMatrixFromStrings(cn*3,(const char **)specifications);
    }
    else if(numSubTree>0&&debug_type==2&&(redund_type==2||redund_type==3)){/*  Redundancy Issue Detection */   
        if(conjNum>0&&redund_type==3)
            cn=conjNum+1;
        else
            cn=0;
		numST = 0;
        for(ii=1;ii<=numSubTree;ii++){
            cn = cn + subTreeConjuncts[ii - 1];
			numST = numST + subTreeConjuncts[ii - 1];
        }
        specifications=(char **)emalloc(cn*3*sizeof(char *));
        conjunctNodes=(Node **)emalloc(cn*sizeof(Node *));
		jj = 0;
        for(ii=1;ii<=numSubTree;ii++){
            subTreeConjunctNodes[ii-1]=(Node **)emalloc(subTreeConjuncts[ii-1]*sizeof(Node *));
            temp = 0;
            index = &temp;
			mexPrintf("\n");
            findSubTreeConjuncts(index,subTreeNodes[ii-1],subTreeConjunctNodes[ii-1]);
            mexPrintf("\nConjunctionSubtrees\n");
   			mtl_print(subTreeNodes[ii - 1]);
            for(kk=0;kk<subTreeConjuncts[ii-1];kk++){
                emptymtl();
				strcpy(mtl, "");
    			mtl2strI(subTreeNodes[ii - 1]);
                strcpy(message,"In subformula ");
                strcat(message,mtl);
                strcat(message," conjunct ");
				if (subTreeConjunctNodes[ii - 1][kk]->ntyp == PREDICATE){
					node1 = dupnode(subTreeConjunctNodes[ii - 1][kk]);
					subTreeConjunctNodes[ii - 1][kk]->ntyp = NOT;
					subTreeConjunctNodes[ii - 1][kk]->lft = node1;
				}
				else if (subTreeConjunctNodes[ii - 1][kk]->ntyp == NOT){
					subTreeConjunctNodes[ii - 1][kk]->ntyp = PREDICATE;
					subTreeConjunctNodes[ii - 1][kk]->sym = subTreeConjunctNodes[ii - 1][kk]->lft->sym;
				}
				else
                    subTreeConjunctNodes[ii - 1][kk] = tl_not(subTreeConjunctNodes[ii - 1][kk]);
                strcpy (mtl,"");
                mexPrintf("\nMITL Subtrees\n");
				mtl2qtl(subTreeNodes[ii-1]);
				strsize=strlen(mtl);
				if(strsize>0){
					specifications[jj*3+1]=(char *)emalloc(strsize*sizeof(char));
					strcpy(specifications[jj*3+1], mtl);
				}
    			mtl_print(subTreeNodes[ii - 1]);
				if (checkSingleTemporal()){
					emptymtl();
					strcpy (ltl,"");
					mtl2ltl(subTreeNodes[ii-1]);
					strsize=strlen(ltl);
					specifications[3*jj] = (char *)emalloc(strsize*sizeof(char));
					strcpy(specifications[3*jj], ltl);
				}
				else{
                    specifications[3*jj]=(char *)emalloc(5*sizeof(char));
                    strcpy(specifications[3*jj], "MITL");
				}
                if (subTreeConjunctNodes[ii - 1][kk]->ntyp == PREDICATE){
					node1 = dupnode(subTreeConjunctNodes[ii - 1][kk]);
					subTreeConjunctNodes[ii - 1][kk]->ntyp = NOT;
					subTreeConjunctNodes[ii - 1][kk]->lft = node1;
				}
				else if (subTreeConjunctNodes[ii - 1][kk]->ntyp == NOT){
					subTreeConjunctNodes[ii - 1][kk]->ntyp = PREDICATE;
					subTreeConjunctNodes[ii - 1][kk]->sym = subTreeConjunctNodes[ii - 1][kk]->lft->sym;
				}
				else
                    subTreeConjunctNodes[ii - 1][kk] = tl_not(subTreeConjunctNodes[ii - 1][kk]);
                
				mexPrintf("\nconjunct is\n");
				mtl_print(subTreeConjunctNodes[ii - 1][kk]);
				mexPrintf("\n\n");
				emptymtl();
				strcpy(mtl, "");
				mtl2strI(subTreeConjunctNodes[ii - 1][kk]);
				strcat(message,mtl);
				strcat(message," is Redundant");
				strcat(message,".\n ERROR : Redundancy issue is detected in");
				strsize=strlen(message);
				specifications[jj*3+2]=(char *)emalloc(strsize*sizeof(char));
				strcpy(specifications[jj*3+2], message);

                jj++;
            }
        }
		if (conjNum>0 && redund_type == 3){
			conjNum = 0;
			findConjuncts(node, conjunctNodes);
			for(kk=0;kk<conjNum;kk++){
			/* Specification is in NNF */
				if(conjunctNodes[kk]->ntyp==PREDICATE){
					node1=dupnode(conjunctNodes[kk]);
					conjunctNodes[kk]->ntyp=NOT;
					conjunctNodes[kk]->lft=node1;
				}
				else if(conjunctNodes[kk]->ntyp==NOT){
					conjunctNodes[kk]->ntyp=PREDICATE;
					conjunctNodes[kk]->sym=conjunctNodes[kk]->lft->sym;
				}
				else
					conjunctNodes[kk] = tl_not(conjunctNodes[kk]);
				strcpy (mtl,"");
				mtl2qtl(node);
				strsize=strlen(mtl);
				if(strsize>0){
					specifications[jj*3+1]=(char *)emalloc(strsize*sizeof(char));
					strcpy(specifications[jj*3+1], mtl);
				}

				if (checkSingleTemporal()){
					emptymtl();
					strcpy (ltl,"");
					mtl2ltl(node);
					strsize=strlen(ltl);
					specifications[3*jj] = (char *)emalloc(strsize*sizeof(char));
					strcpy(specifications[3*jj], ltl);
				}
				else{
				specifications[3*jj]=(char *)emalloc(5*sizeof(char));
				strcpy(specifications[3*jj], "MITL");
				}

				conjunctNodes[kk] = tl_not(conjunctNodes[kk]);

				mexPrintf("\nconjunct is\n");
				mtl_print(conjunctNodes[kk]);
				mexPrintf("\n\n");
				emptymtl();
				strcpy(mtl, "");
				mtl2strI(conjunctNodes[kk]);
				strcpy(message,mtl);
				strcat(message," is Redundant");
				strcat(message,".\n ERROR : Redundancy issue is detected in");
				strsize=strlen(message);
				specifications[jj*3+2]=(char *)emalloc(strsize*sizeof(char));
				strcpy(specifications[jj*3+2], message);
				jj++;
			}
		}
        
	    mitl=mxCreateCharMatrixFromStrings(cn*3,(const char **)specifications);
    }
    else if(conjNum>0&&debug_type==3){/*  Vacuity Issue Detection    */
        cn=conjNum+1;
        specifications=(char **)emalloc(ln*3*sizeof(char *));
        conjunctNodes=(Node **)emalloc(cn*sizeof(Node *));
        conjNum=0;
        kk=0;
        
        findConjuncts(node,conjunctNodes);
        if(conjNum!=cn){
            /*mexPrintf("Error on the number of conjuncts");  */    
        }
        for(jj=0;jj<conjNum;jj++){
            litNum=0;
            countLiterals(conjunctNodes[jj]);
            cln=litNum;
            /*mexPrintf("\n Conjunct %d has %d Number of Literals\n",jj,cln);*/
            for(ii=1;ii<=cln;ii++){
                bigAnd=tl_nn(AND,  ZN, ZN);
                node1 = dupnode(node);
                litNum=0;
                falseNode=tl_nn(AND,  ZN, ZN);
                falseNode->ntyp=FALSE;
                node2 = dupnode(conjunctNodes[jj]);
				if(node2->ntyp==PREDICATE||node2->ntyp==NOT)
					node2=falseNode;
				else{
					ii1=changeLiteral(node2,ii,falseNode);
					if(ii1==0){
						/*mexPrintf("\nNo predicate is found\n"); */
					}
					else{
						/*mexPrintf("\nPredicate is found\n");*/
                    }
				}
                node3 = dupnode(node2);
                notNode=tl_not(node2);
                bigAnd->lft=node1;
                /*mexPrintf("\n notNode is            : ");
                mtl_print(notNode);*/
                bigAnd->rgt=notNode;
                bigAnd=SimplifyNodeValue(bigAnd);/* FOR MITL VS LTL */
                /*mexPrintf("\n MTL is : ");
                mtl_print(bigAnd);
                mexPrintf("\n");*/
                emptymtl();
                strcpy (mtl,"");
                mtl2qtl(bigAnd);
                /*mexPrintf("\n %s\n",mtl);*/
                strsize=strlen(mtl);
                /*mexPrintf("\n MTL size is %d\n",strsize);*/
                if(strsize>0){
                    specifications[kk*3+1]=(char *)emalloc(strsize*sizeof(char));
                    strcpy(specifications[kk*3+1], mtl);
                    /*mexPrintf("\n MITL string is %s\n",specifications[kk*3+1]);*/
                    bigAnd=SimplifyNodeValue(bigAnd);
                    emptymtl();
                    strcpy (mtl,"");
                    mtl2qtl(bigAnd);
                    if (checkSingleTemporal()){
                        /*mexPrintf("\n LTL \n");*/
                        emptymtl();
                        strcpy (ltl,"");
                        mtl2ltl(bigAnd);
                        strsize=strlen(ltl);
                        specifications[3*kk]=(char *)emalloc(strsize*sizeof(char));
                        strcpy(specifications[3*kk], ltl);
                    }
                    else{
                        /*mexPrintf("\n MITL \n");*/
                        specifications[3*kk]=(char *)emalloc(5*sizeof(char));
                        strcpy(specifications[3*kk], "MITL");
                    }
                    emptymtl();
                    strcpy (mtl,"");
                    mtl2strI(node3);
                    /*mexPrintf("\n Node 3 ----------\n");
                    mtl_print(node3);
                    mexPrintf("------------\n");*/
                    strcpy(message,"Specification satisfies ");
                    strcat(message,mtl);
                    strcat(message,".\n ERROR : Vacuity issue is detected in");
                    strsize=strlen(message);
                    specifications[kk*3+2]=(char *)emalloc(strsize*sizeof(char));
                    strcpy(specifications[kk*3+2], message);
                    kk++;
                }
            }
        }
        if(ln!=kk)
    		mexErrMsgTxt("mx_debugging: ln!=kk"); 
	    mitl=mxCreateCharMatrixFromStrings(kk*3,(const char **)specifications);
    }
    else if(debug_type==4){
        if(antecNum==0){
            mitl = mxCreateDoubleMatrix( 0, 0, mxREAL );
		}
		else{
            an=antecNum;
    		specifications = (char **)emalloc(an*sizeof(char *));
            for(ii=1;ii<=an;ii++){
                antecNum=0;
                emptymtl();
                extractAntecedent(node,ii);
                strcat(mtl,")");
                strsize=strlen(mtl);
                specifications[ii-1]=(char *)emalloc(strsize*sizeof(char));
                strcpy(specifications[ii-1], mtl);
                /*mexPrintf("\n MITL string is %s\n",specifications[ii-1]);*/
            }
            mitl = mxCreateCharMatrixFromStrings(an, (const char **)specifications);
		}
    }
	else {/*  Otherwise return empty    */
		mitl = mxCreateDoubleMatrix(0, 0, mxREAL);
	}
    /*run_MITL_sat();*/
	if (fw_taliro_param.LTL==0 && nrhs<1)
		mexErrMsgTxt("mx_debugging: The formula is in MTL, but there are no timestamps!"); 
    plhs[0]=mitl;
	/* Clean-up data for consecutive executions of vacuity */
/*	for (iii=0; iii<fw_taliro_param.nPred; iii++)
	{
		tl_clearlookup(predMap[iii].str);
		mxFree(predMap[iii].str);
		for (jjj=0;jjj<predMap[iii].set.ncon;jjj++)
			mxFree(predMap[iii].set.A[jjj]);
		mxFree(predMap[iii].set.A);
	}*/
	if (debug_type == 1){
	    for(ii=0;ii<4;ii++){
		    mxFree(specifications[ii]);
		}
        mxFree(specifications);
	}
	else if (debug_type == 2 && cn>1 && conjNum>0 && redund_type==1 ){
	    for(ii=0;ii<(cn*2);ii++){
		    mxFree(specifications[ii]);
		}
        mxFree(specifications);
	}
	else if (debug_type == 3) {
		for (ii = 1; ii <= (ln*2); ii++){
			mxFree(specifications[ii - 1]);
		}
		mxFree(specifications);
	}

} 




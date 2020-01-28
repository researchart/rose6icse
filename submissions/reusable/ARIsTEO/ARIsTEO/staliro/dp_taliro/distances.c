/***** mx_dp_taliro : distances.c *****/
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

#include <math.h>
#include "mex.h"
#include "matrix.h"
#include "distances.h"
#include "ltl2tree.h"
#include "param.h"

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
		dist.HAindex = 1;
		dist.headLocation = 0;
		dist.tailLocation = 0;
	}
	else
	{
		dist.dl = -(int)LDist[((int)xx[dim]-1)+((int)SS->idx)*tnLoc];
		dist.ds = -mxGetInf();
		dist.HAindex = 1;
		dist.headLocation = 0;
		dist.tailLocation = 0;
	}
	return(dist);
}

HyDis SignedHDist0NCLG(double *xx, ConvSet *SS, int dim, double **LDist, mwSize tnLoc,int clgIndex)
{
	int inLoc;
	mwIndex ii;
	HyDis dist;

	/* Are we in right control location? */
	inLoc = 0;
	for (ii=0; ii<SS->nlocNCLG[clgIndex]; ii++)
		if (((int)xx[dim+clgIndex])==((int)SS->locNCLG[clgIndex][ii]))
		{
			inLoc = 1;
			break;
		}
	/* Compute hybrid metric */
	if (inLoc)
	{
		dist.dl = 0;
		dist.ds = SignedDist(xx,SS,dim);
		dist.HAindex = 1;
		dist.headLocation = 0;
		dist.tailLocation = 0;
	}
	else
	{
		dist.dl = -(int)LDist[clgIndex][((int)xx[dim + clgIndex] - 1) + ((int)SS->idx)*tnLoc];
		dist.ds = -mxGetInf();
		dist.HAindex = 1;
		dist.headLocation = 0;
		dist.tailLocation = 0;
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
	int i1,i2,i3,ii;
	int cloc;

	/* projection of xx to smaller yy */
	double *yy;

	cloc = (int)(xx[dim]);
	im1 = cloc-1;	
	if (im1<0)
	{
		mexErrMsgTxt("taliro: All location indices must be positive integers!"); 
	}
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
            dist.HAindex = 1;
            dist.headLocation = 0;
            dist.tailLocation = 0;
		}
		else
		{
			pathDist = (int)distData->LDist[im1+((int)SS->idx)*tnLoc];
			dist.dl = -pathDist;
			dist.ds = -mxGetInf();
            dist.HAindex = 1;
            dist.headLocation = 0;
            dist.tailLocation = 0;
			if (distData->AdjLNell[im1]>0)
			{
				for (jj=0; jj<distData->AdjLNell[im1]; jj++)
				{
					
					if(distData->GuardMap[im1][jj].nproj>0){
						yy = (double *)emalloc(sizeof(double)*distData->GuardMap[im1][jj].nproj);
						for(ii=0;ii<distData->GuardMap[im1][jj].nproj;ii++){
							yy[ii]=xx[distData->GuardMap[im1][jj].proj[ii]-1];
						}
					}

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
                            /* For projection is Added*/
                            GS.proj= distData->GuardMap[im1][jj].proj;
							GS.nproj= distData->GuardMap[im1][jj].nproj;
                            /* For projection*/
							if (GS.ncon==1)
								tmp_dist = SignedDist(xx,&GS,dim);
							else
							{
		                            /* For projection is Updated*/
                                    if(GS.nproj==0){
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
								}else{
									Aout = mxCreateDoubleMatrix(GS.ncon, GS.nproj, mxREAL);
									bout = mxCreateDoubleMatrix(GS.ncon, 1, mxREAL);
									xout = mxCreateDoubleMatrix(GS.nproj, 1, mxREAL);
									Atemp = mxGetPr(Aout);
									btemp = mxGetPr(bout);
									xtemp = mxGetPr(xout);
									for (i3=0; i3<GS.nproj; i3++)
										xtemp[i3] = yy[i3];
									for (i2=0; i2<GS.ncon; i2++)
									{
										btemp[i2] = GS.b[i2];
										for (i3=0; i3<GS.nproj; i3++)
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
                                /* For projection */
							}

							if (tmp_dist>0)
							{
								tmp_dist = 0.0;
								/*
								mexPrintf("%s%d%s%d%s \n", "Guard: (",cloc,",",kk+1,")");
								mexPrintf("%s%f \n", "Signed distance: ", &tmp_dist);
                                mexPrintf("%s%f \n", "Point on wrong side of guard: ", &xout);
								mexErrMsgTxt("taliro: Above control location: The signed distance to the guard set is positive!"); 
								*/
							}
							/* Since the distances are always negative (the current point should never be within the current guard 
							   assuming ASAP transitions), then the required distance will be the maximum of the negative
							   distances returnde. */
							tmp_dist_min = max(tmp_dist_min,tmp_dist);
						}
						/*dist.ds = max(dist.ds,tmp_dist_min);*/
                        if( tmp_dist_min > dist.ds){
                            dist.ds = tmp_dist_min;
                            dist.HAindex = 1;
                            dist.headLocation = im1+1;
                            dist.tailLocation = kk+1;
                        }
					}
				}
			}
		}
	
	return(dist);
}

/* SignedHDistGNCLG for distance compuitation of multiple HAs*/
HyDis SignedHDistGNCLG(double *xx, ConvSet *SS, int dim, DistCompData *distData, mwSize tnLoc,int clgIndex)
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
	int i1,i2,i3,ii;
	int cloc;
	/* projection of xx to smaller yy */
	double *yy;


	cloc = (int)(xx[dim+clgIndex]);
	im1 = cloc-1;	
	/*printf("CLG(%d) loc=%d ",clgIndex,cloc);*/
	if (im1<0)
	{
		printf("CLG(%d) loc=%d ",clgIndex,cloc);
        mexErrMsgTxt("taliro(SignedHDistGNCLG): All location indices must be positive integers!"); 
	}
	inLoc = 0;
	/* Are we in right control location? */
	for (jj=0; jj<SS->nlocNCLG[clgIndex]; jj++)
	{
		if (cloc==((int)SS->locNCLG[clgIndex][jj]))
		{
			inLoc = 1;
/*             printf("\n in location ");*/
			break;
		}
	}

		/* Compute hybrid metric */
		if (inLoc)
		{
			dist.dl = 0;
			dist.ds = SignedDist(xx,SS,dim);
            dist.headLocation = 0;
            dist.tailLocation = 0;
		}
		else
		{
			pathDist = (int)distData->LDistNCLG[clgIndex][im1+((int)SS->idx)*tnLoc];
			dist.dl = -pathDist;
			dist.ds = -mxGetInf();
            dist.headLocation = 0;
            dist.tailLocation = 0;
			if (distData->AdjLNellNCLG[clgIndex][im1]>0)
			{
				for (jj=0; jj<distData->AdjLNellNCLG[clgIndex][im1]; jj++)
				{
					if(distData->GuardMapNCLG[clgIndex][im1][jj].nproj>0){
						yy = (double *)emalloc(sizeof(double)*distData->GuardMapNCLG[clgIndex][im1][jj].nproj);
						for(ii=0;ii<distData->GuardMapNCLG[clgIndex][im1][jj].nproj;ii++){
							yy[ii]=xx[distData->GuardMapNCLG[clgIndex][im1][jj].proj[ii]-1];
						}
					}

					kk = (int)distData->AdjLnCLG[clgIndex][im1][jj]-1;
					if ((int)distData->LDistNCLG[clgIndex][kk+((int)SS->idx)*tnLoc]<pathDist)
					{
						tmp_dist_min = -mxGetInf();
						for (i1=0; i1<distData->GuardMapNCLG[clgIndex][im1][jj].nset; i1++)
						{
							GS.ncon = distData->GuardMapNCLG[clgIndex][im1][jj].ncon[i1];
							GS.isSetRn = false;
							GS.A = distData->GuardMapNCLG[clgIndex][im1][jj].A[i1];
							GS.b = distData->GuardMapNCLG[clgIndex][im1][jj].b[i1];
							GS.proj=distData->GuardMapNCLG[clgIndex][im1][jj].proj;
							GS.nproj=distData->GuardMapNCLG[clgIndex][im1][jj].nproj;
							if (GS.ncon==1)
								tmp_dist = SignedDist(xx,&GS,dim);
							else
							{
								if(GS.nproj==0){
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
								else
								{
									Aout = mxCreateDoubleMatrix(GS.ncon, GS.nproj, mxREAL);
									bout = mxCreateDoubleMatrix(GS.ncon, 1, mxREAL);
									xout = mxCreateDoubleMatrix(GS.nproj, 1, mxREAL);
									Atemp = mxGetPr(Aout);
									btemp = mxGetPr(bout);
									xtemp = mxGetPr(xout);
									for (i3=0; i3<GS.nproj; i3++)
										xtemp[i3] = yy[i3];
									for (i2=0; i2<GS.ncon; i2++)
									{
										btemp[i2] = GS.b[i2];
										for (i3=0; i3<GS.nproj; i3++)
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
							}

							if (tmp_dist>0)
							{
								tmp_dist = 0.0;
								/*
								mexPrintf("%s%d%s%d%s \n", "Guard: (",cloc,",",kk+1,")");
								mexPrintf("%s%f \n", "Signed distance: ", &tmp_dist);
                                mexPrintf("%s%f \n", "Point on wrong side of guard: ", &xout);
								mexErrMsgTxt("taliro: Above control location: The signed distance to the guard set is positive!"); 
								*/
							}
							/* Since the distances are always negative (the current point should never be within the current guard 
							   assuming ASAP transitions), then the required distance will be the maximum of the negative
							   distances returnde. */
							tmp_dist_min = max(tmp_dist_min,tmp_dist);
						}
						/*dist.ds = max(dist.ds,tmp_dist_min);*/
                        if( tmp_dist_min > dist.ds){
                            dist.ds = tmp_dist_min;
                            dist.headLocation = im1+1;
                            dist.tailLocation = kk+1;
                        }

					}
				}
			}
		}
/*	rob->dss[clgIndex]=dist.ds;
	rob->dll[clgIndex]=dist.dl;*/
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

	/* projection of xx to smaller yy */
	double *yy;
	if(SS->nproj>0){
		yy = (double *)emalloc(sizeof(double)*SS->nproj);
		for(ii=0;ii<SS->nproj;ii++){
			yy[ii]=xx[SS->proj[ii]-1];
		}
	}
    
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
                    /* For projection is Updated*/
                    if(SS->nproj==0){
                        aa = norm(SS->A[0],dim);
                        aa *= aa;
                        cc = ((SS->b[0]) - inner_prod(SS->A[0],xx,dim))/aa;
                        vec_scl(x0,cc,SS->A[0],dim);
                        dist = norm(x0,dim);
                        if (isPointInConvSet(xx, SS, dim))
                            return(dist);
                        else
                            return(-dist);
                    }else{
                        aa = norm(SS->A[0],SS->nproj);
                        aa *= aa;
                        cc = ((SS->b[0]) - inner_prod(SS->A[0],yy,SS->nproj))/aa;
                        vec_scl(x0,cc,SS->A[0],SS->nproj);
                        dist = norm(x0,SS->nproj);
                        if (isPointInConvSet(yy, SS, SS->nproj))
                            return(dist);
                        else
                            return(-dist);
                   }

                    /* For projection */
				}
				else
				{
                    /* Projection on the plane: x0 = x+(b-a*x)*a'/norm(a)^2; */
                    x0d = (double *)emalloc(sizeof(double)*dim);
					if(SS->nproj==0)
                    {
                        aa = norm(SS->A[0],dim);
                        aa *= aa;
                        cc = ((SS->b[0]) - inner_prod(SS->A[0],xx,dim))/aa;
                        vec_scl(x0d,cc,SS->A[0],dim);
                        dist = norm(x0d,dim);
                        mxFree(x0d);
                        if (isPointInConvSet(xx, SS, dim))
                            return(dist);
                        else
                            return(-dist);
                    }
                    else{
                        aa = norm(SS->A[0],SS->nproj);
                        aa *= aa;
                        cc = ((SS->b[0]) - inner_prod(SS->A[0],yy,SS->nproj))/aa;
                        vec_scl(x0d,cc,SS->A[0],SS->nproj);
                        dist = norm(x0d,dim);
                        mxFree(x0d);
                        if (isPointInConvSet(yy, SS, SS->nproj))
                            return(dist);
                        else
                            return(-dist);
                    }
				}
			}
			/* if we have more than one constraints in multi-Dimensional signals */
			else
			{
				/* Prepare data and call SignedDist.m */
				/* From help: If unsuccessful in a MEX-file, the MEX-file terminates and control returns to the MATLAB prompt. */
				/* Alternatively use mexCallMATLABWithTrap */
                /* For projection is Updated*/
                if(SS->nproj==0)
				{
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
				}else
				{
					Xout = mxCreateDoubleMatrix(SS->nproj, 1, mxREAL);
					Aout = mxCreateDoubleMatrix(SS->ncon, SS->nproj, mxREAL);
					bout = mxCreateDoubleMatrix(SS->ncon, 1, mxREAL);
					xtemp = mxGetPr(Xout); 
					Atemp = mxGetPr(Aout);
					btemp = mxGetPr(bout);
					for(ii=0; ii<SS->nproj; ii++)
						xtemp[ii] = yy[ii];
					for(ii=0; ii<SS->ncon; ii++)
					{
						btemp[ii] = SS->b[ii];
						for (jj=0; jj<SS->nproj; jj++)
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

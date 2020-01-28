% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef aristeo_options < staliro_options
% Class definition for the ARISTEO options
%
% opt = aristeo_options;
%
% The above function call sets the default values for the class properties. 
% For a detailed description of each property open the <a href="matlab: doc aristeo_options">staliro_options help file</a>.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g.: to change the abstraction_algorithm to type
% opt.abstraction_algorithm = 'ss';
%
% NOTE: For more information on properties, click on them. 
%
% See also: staliro, staliro_blackbox

% (C) 2019, Claudio Menghi, University of Luxembourg
% (C) 2019, Gaaloul Khouloud, University of Luxembourg
% (C) 2019, Shiva Nejati Hoxha, University of Luxembourg
% (C) 2019, Lionel Briand, University of Luxembourg
    
    properties
        % Choose an identification algorithm to be used in the ARISTEO
        % abstraction
        %
        % The possible values for the abstraction algorithm are:
        %   *   'arx' it is used to learn a model of the type arx(na,nb,nk) defined as  
        %           y(t)+a_1·y(t−1)+...+a_n·a·y(t−na)=b_1·u(t−nk)+...+b_nb·u(t−nb−nk+1)+e(t)
        %       Intuitively, the output y depend on a finite number of previous input u values and values 
        %       assumed by the output y itself. 
        %       The values na and nb are the number of past output and 
        %       input values to be used in predicting the next output. 
        %       The value nk indicates the delay from the input to the output, specified as number of samples.
        %   *   'armax' it is used to learn a model of the type armax(na,nb,nk) defined as  
        %           y(t)+a1 ·y(t −1)+. . .+ana ·y(t −na) = b1 ·u(t −nk)+. . .+bnb ·u(t −nb −nk +1)+c1 ·e(t −1)+. . .+cnc ·e(t −nc)+e(t)  
        %       Extends the arx model by considering how the value of the noise
        %       e at time t, t − 1, . . ., t − nc influences the next value of the output y.
        %   *   'bj' it is used to learn a model of the type bj(nb,nc,nf,nd,nk) defined as
        %           y(t)= B(z)/F(z)·u(t)+ C(z)/D(z)·e(t)
        %       Box-Jenkins models allow a more general noise description than armax models. 
        %       The output y depends on a finite number of previous input u and output y values. 
        %       The values nb , nc , nd , nf , nk indicate the orders of the matrix B, C, D, F and the value of the input delay.
        %   *   'tf' it is used to learn a model of the type tf(np,nz) defined as
        %           y(t)= (b0+b1·s+b2·s2+...+bn·snz)/(1+f1·s+f2·s2+...+fm·snp)·u(t)+e(t)
        %       Represents a transfer function model. The values np , nz indicate the number of poles and zeros of the transfer function.
        %   *   'ss' it is used to learn a model of the type ss(n) defined as
        %           x(0) = x0
        %           dot(x)(t)=F·x(t)+G·u(t)+K·w(t) 
        %           y(t)=H·x(t)+D·u(t)+w(t)
        %       Uses state variables to describe a system by a set of first-order differential or difference equations. The value n is an integer indicating the order of the dynamical system.
        %   *   'nlarx' it is used to learn a model of the type nlarx(f,na,nb,nk) defined as
        %           y(t)=f(y(t−1),...,y(t−na),u(t−nk),...,u(t−nk−nb+1))
        %       Non linear arx models allow considering a non linear function f to describe the input/output relation. Examples of non linear estimators that can be used to compute 
        %       the function f are wavelet or sigmoid networks, but also neural network included in the Deep Learning Matlab Toolbox can be used. 
        %       The values of na and nb indicate the number of past output and input values used in the prediction of the next output value. The value nk is the delay from the input to the output.
        %   *   'hw' it is used to learn a model of the type hw(f,B,F,h,na,nb,nk) defined as
        %           y(t)=f(y(t−1),...,y(t−na),u(t−nk),...,u(t−nk−nb+1))
        %       Non linear arx models allow considering a non linear function f to describe the input/output relation. 
        %       Examples of non linear estimators that can be used to compute  the function f are wavelet or sigmoid networks, but also neural network included in the Deep Learning Matlab Toolbox can be used. 
        %       The values of na and nb indicate the number of past output and input values used in the prediction of the next output value. The value nk is the delay from the input to the output.
        %   *   'hw' it is used to learn a model of the type hw(f,B,F,h,na,nb,nk) defined as
        %           w(t)= f(u(t))
        %           x(t) = (B(z)/F(z))·w(t) 
        %           y(t) = h(x(t))
        %       Hammerstein-Wiener models describe dynamic systems two nonlinear blocks in series with a linear block. Specifically, f and h are non linear functions, B(z), F (z), na,nb,nk are defined as for bj models. 
        %       Different nonlinearity estimators can be used to learn f and h similarly to the nlarx case.
        abstraction_algorithm = 'ss';
        
        % the value of the variable nx
        % see details in relation with the selected model
        nx=-1;
        
        % the value of the variable na
        % see details in relation with the selected model
        na=-1;
        
        % the value of the variable nb
        % see details in relation with the selected model
        nb=-1;
        
        % the value of the variable nc
        % see details in relation with the selected model
        nc=-1;
        
        nf=-1;
        
        nk=-1;
        
        nz=-1;
        
        np=-1;
        
        nd=-1;
        
        % the maximum number of refinement rounds performed by ARISTEO
        n_refinement_rounds=-1;
        
    end
   methods

               function obj = set.nd(obj,nd)
            obj.nd=nd;
               end
        
        function obj = set.nx(obj,nx)
            obj.nx=nx;
        end
          function obj = set.nz(obj,nz)
            obj.nz=nz;
        end
        function obj = set.na(obj,na)
            obj.na=na;
        end
        function obj = set.nb(obj,nb)
            obj.nb=nb;
        end
        function obj = set.nc(obj,nc)
            obj.nc=nc;
        end
        function obj = set.nf(obj,nf)
            obj.nf=nf;
        end
        function obj = set.nk(obj,nk)
            obj.nk=nk;
        end
          function obj = set.np(obj,np)
            obj.np=np;
        end
   end
end


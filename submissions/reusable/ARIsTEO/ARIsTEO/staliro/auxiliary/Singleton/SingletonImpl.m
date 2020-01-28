% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef SingletonImpl < Singleton
   %SINGLETONIMPL Concrete Implementation of Singleton OOP Design Pattern
   %   Refer to the description in the abstract superclass Singleton for
   %   full detail.
   %   This class serves as a template for constructing your own custom
   %   classes.
   %
   %   Written by Bobby Nedelkovski
   %   The MathWorks Australia Pty Ltd
   %   Copyright 2009, The MathWorks, Inc.
   
   %*** Define your own properties for SingletonImpl.
   properties % Public Access
      myData;
   end
   
   methods(Access=private)
      % Guard the constructor against external invocation.  We only want
      % to allow a single instance of this class.  See description in
      % Singleton superclass.
      function newObj = SingletonImpl()
         % Initialise your custom properties.
         newObj.myData = [];
      end
   end
   
   methods(Static)
      % Concrete implementation.  See Singleton superclass.
      function obj = instance()
         persistent uniqueInstance
         if isempty(uniqueInstance)
            obj = SingletonImpl();
            uniqueInstance = obj;
         else
            obj = uniqueInstance;
         end
      end
   end
   
   %*** Define your own methods for SingletonImpl.
   methods % Public Access
      function myOperation(obj, val)
         % Just assign the input value to singletonData.  See Singleton
         % superclass.
         obj.setSingletonData(val);
      end
   end
   
end

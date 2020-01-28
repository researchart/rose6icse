% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ new_Model_Name ] = save_model_info( modelName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% added for matlab function instrumentation
   load_system(modelName);
% added for matlab function instrumentation
   fprintf('\n Modification Done. Outports added.\n');
   new_model_name=strcat(modelName,'_ouports_added');
   save_system(modelName,new_model_name);%save_system(name,'toy_model_ouports_added');  
   fprintf('\n Modified model saved.\n');
   close_system(modelName,0);%close_system(name,0);
   %close_system(new_model_name);
   new_Model_Name = new_model_name;

end


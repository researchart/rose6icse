% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% tp_taliro_casting class: Instantiates tp_taliro_casting objects
% for hybrid distance robustness and best iteration and best predicate
% computations.
% 
% USAGE:
%
%   [obj,aux] = tp_taliro_casting(A)
%   where: 
%       A is struct: generate hybrid disatnces robustness and 
%       auxiliary information when the struct consists 
%       of hybrid distance robustness,most_related_iteration and
%       most_related_predicate_index.
%       
% (C) 2017 by Georgios Fainekos (fainekos@asu.edu)
% (C) 2017 by Adel Dokhanchi - ASU							  


function [obj,aux] = tp_taliro_casting(varargin)


if nargin==1 && isa(varargin{1},'struct')
     if min(isfield(varargin{1}, {'dl'; 'ds'; 'most_related_iteration'; 'most_related_predicate_index'}))
         if min(size(varargin{1}.dl)==size(varargin{1}.ds))
             obj = struct('dl',varargin{1}.dl,'ds',varargin{1}.ds);
             aux = struct('i',varargin{1}.most_related_iteration,'pred',varargin{1}.most_related_predicate_index);
         else
          error('hydis: This is not a valid input structure: fields "dl" and "ds" do not have the same size!')
         end
    else
        error('hydis: This is not a valid input structure: field "dl" or "ds" is missing!')
     end
else
    error('Wrapup: Invalid input arguments')
end

end
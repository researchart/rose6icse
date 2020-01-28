% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function out = saveobj(obj)
%SAVEOBJ (overloaded)

% Author Johan Löfberg 
% $Id: saveobj.m,v 1.4 2005-02-14 16:46:38 johanl Exp $   

% We have to save the persistent variables in the SDPVAR class
obj.savedata.internalsdpvarstate = yalmip('getinternalsdpvarstate');
obj.savedata.version = yalmip('version');
out = obj;

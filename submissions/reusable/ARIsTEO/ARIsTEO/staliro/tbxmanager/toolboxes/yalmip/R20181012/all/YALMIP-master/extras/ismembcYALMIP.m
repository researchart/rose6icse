% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function members=ismembcYALMIP(a,b)

% ismembc is fast, but does not exist in octave
% however, try-catch is very slow in Octave,
% Octave user: Just replace the whole code here
% with "members = ismember(a,b);"
try
    members = ismembc(a,b);
catch
    members = ismember(a,b);
end

  
  

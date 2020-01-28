% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function display(ipa)
% INPLACE/DISPLAY Display an inplace array from the command line.
%
% Example:
%    ipa = inplace(ones(5));
%    ipa

disp([inputname(1), ' = ']);
disp(ipa.get_a());
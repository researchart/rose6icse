% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function display(X)
%display           Overloaded

% Author Johan L�fberg 
% $Id: display.m,v 1.3 2007-07-31 13:30:39 joloef Exp $  

disp(['Optimization object with ' num2str(prod(X.dimin)) ' inputs and ' num2str(prod(X.dimout)) ' outputs.'])

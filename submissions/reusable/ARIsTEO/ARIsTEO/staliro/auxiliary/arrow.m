% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% arrow - plot a simple arrow from x0 to x1
%       srrow(x0,x1,dum)
% where dum is a dummy value for backward compatibility.

function arrow(x0,x1,dum) %#ok<INUSD>
dl = 0.3; % scaling length 
da = 0.25; % scaling arrow head
a1 = atan2(x1(2)-x0(2),x1(1)-x0(1));
len = norm(x1-x0);
x2 = x1+len*dl*[cos(pi+a1-da) sin(pi+a1-da)];
x3 = x1+len*dl*[cos(pi+a1+da) sin(pi+a1+da)];
pt = [x0; x1; x2; x1; x3; x1];
plot(pt(:,1),pt(:,2))
end


% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function massive
ops{1} = sdpsettings('sos.cong',0,'sos.model',1,'verbose',0);
ops{2} = sdpsettings('sos.cong',1,'sos.model',2,'verbose',0);
ops{3} = sdpsettings('sos.cong',0,'sos.newton',0,'verbose',0,'sos.extlp',0);

x = sdpvar(1,1);
y = sdpvar(1,1);
t = sdpvar(1,1);
s = sdpvar(1,1);
F = set(sos(1+y^2-t-s))+set(sos(1+x^2-s))+set(t>0)+set(s>-0.5);
obj = -s-t;
for i = 1:length(ops)
    i
    fail = regresstest(F,obj,ops{i});
    mbg_asserttolequal(fail,0);
end



function fail  = regresstest(F,obj,ops,pv);

if nargin==3
    pv = [];
end

ops.sos.model = 1;
solvesos(F,obj,ops,pv);
obj1 = double(obj);
p1s = checkset(F(find(is(F,'sos'))));
p1e = checkset(F(find(~is(F,'sos'))));

ops.sos.model = 2;
solvesos(F,obj,ops,pv);
obj2 = double(obj);
p2s = checkset(F(find(is(F,'sos'))));
p2e = checkset(F(find(~is(F,'sos'))));

fail = 0;

if abs(obj1-obj2) > 1e-4
    fail = 1;
end

if any(p1s>1e-4)
   fail = 2;
   p1s
end
if any(p2s>1e-4)
   fail = 2;
   p2s
end
if any(p1e<-1e-4)
   fail = 2;
   p1e
end
if any(p2e<-1e-4)
   fail = 2;
   p2e
end
if fail==0
    disp('Correct solution');
end
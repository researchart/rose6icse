% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
tt=linspace(0,4*pi,1500);
X=[tt.*sin(tt);tt.*cos(tt)];
pars.slack=1;
yalmip('clear')
Dis=distance(X); 
pars.solver=0;
[Y,D]=sde(Dis,3,pars); % CSDP 

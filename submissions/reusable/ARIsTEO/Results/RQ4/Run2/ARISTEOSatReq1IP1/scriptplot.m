% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  

f1=figure();
res=[];
in=1;
load('results.mat');

res=input(in:100:size(input,1),1);
tm=T(in:100:size(T,1),1);

subplot(1,2,1);
plot(tm,res);
grid on
legend('1','2','3','4','5','6','7')

subplot(1,2,2);
res=[];

    
res=YT(in:100:size(YT,1),1);
tm=T(in:100:size(T,1),1);
plot(tm,res);
grid on
legend('1','2','3','4','5','6','7')
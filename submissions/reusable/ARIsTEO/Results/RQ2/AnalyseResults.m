% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  


aristeoIndex=[5 7 9 11 13 15];
staliroIndex=[7 9 12 14 16 19];

%aristeoIndex=[5 7 9];
%staliroIndex=[5 7 9];


numexp=5;
result=zeros(numexp,size(aristeoIndex,2)*2);
for i=1:1:size(aristeoIndex,2)
    iterations  = readtable(strcat('rq2resultsaristeo_',num2str(aristeoIndex(i)),'.csv'));
    for j=1:1:numexp
       result(j,(i-1)*2+1)=iterations{j,3};
    end
    iterationsStaliro  = readtable(strcat('rq2resultsstaliro_',num2str(staliroIndex(i)),'.csv'));
    
    for j=1:1:numexp
        result(j,i*2)=iterationsStaliro{j,3};
    end
end

 T=table(result(:,1),result(:,2),result(:,3),result(:,4),result(:,5),result(:,6),result(:,7),result(:,8),result(:,9),result(:,10),result(:,11),result(:,12),'RowNames',{'RHB(1)','RHB(2)','AT','AFC','IGC'});
 disp(T);
 
 faultrevealingaristeoRHB1RHB2=mean2(result([1,2],[1:2:size(result,2)-1]));
 faultrevealingstaliroRHB1RHB2=mean2(result([1,2],[2:2:size(result,2)]));

 faultrevealingaristeoOthers=mean2(result([3,4,5],[1:2:size(result,2)-1]));
 faultrevealingstaliroOthers=mean2(result([3,4,5],[2:2:size(result,2)]));

 
 faultrevealingaristeo=mean2(result(:,[1:2:size(result,2)-1]));
 faultrevealingstaliro=mean2(result(:,[2:2:size(result,2)]));
 


difference=result(:,[1:2:size(result,2)-1])-result(:,[2:2:size(result,2)]);
 

disp(strcat('Fault revealing RHB1 and RHB2 Aristeo: ',num2str(faultrevealingaristeoRHB1RHB2),' S-Taliro: ',num2str(faultrevealingstaliroRHB1RHB2)));
disp(strcat('Fault revealing AT, AFC, IGC2 Aristeo: ',num2str(faultrevealingaristeoOthers),' S-Taliro: ',num2str(faultrevealingstaliroOthers)));

disp(strcat('Average effectivensss ARISTEO:',num2str(mean2(result(:,[1:2:size(result,2)-1]))))); 
disp(strcat('Average effectivensss S-Taliro:',num2str(mean2(result(:,[2:2:size(result,2)]))))); 
disp(strcat('Boost in Effectiveness:',num2str(mean2(difference(:,:))))); 
disp(strcat('Max Effectiveness:',num2str(max(max(difference))))); 
disp(strcat('Min Effectiveness:',num2str(min(min(difference))))); 


a=(result(1,1:2:size(result,2)-1)-result(1,2:2:size(result,2)))';

disp(strcat('Z-Test RHB1 alpha=0.05 rejected=',num2str(ztest(a,0,std(a)))));


a=(result(2,1:2:size(result,2)-1)-result(2,2:2:size(result,2)))';
disp(strcat('Z-Test RHB2 alpha=0.05 rejected=',num2str(ztest(a,0,std(a)))));


a=(result(3,1:2:size(result,2)-1)-result(3,2:2:size(result,2)))';
disp(strcat('Z-Test AT alpha=0.05 rejected=',num2str(ztest(a,0,std(a)))));


a=(result(4,1:2:size(result,2)-1)-result(4,2:2:size(result,2)))';
disp(strcat('Z-Test AFC alpha=0.05 rejected=',num2str(ztest(a,0,std(a)))));


a=(result(5,1:2:size(result,2)-1)-result(5,2:2:size(result,2)))';
disp(strcat('Z-Test IGC alpha=0.05 rejected=',num2str(ztest(a,0,std(a)))));



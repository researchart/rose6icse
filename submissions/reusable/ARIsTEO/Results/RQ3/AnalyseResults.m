% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Performs the analysis described in the paper and generates the boxplot
% related with RQ3
staliroIndex=[7 9 12 14 16 19];
aristeoIndex=[5 7 9 11 13 15];


h=figure();

set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
axes('FontSize', 20,'FontName','arial');
set(h, 'DefaultTextFontSize', 30);

titles={'\langle IA_1,IB_1 \rangle','\langle IA_2,IB_2 \rangle','\langle IA_3,IB_3 \rangle','\langle IA_4,IB_4 \rangle','\langle IA_5,IB_5 \rangle','\langle IA_6,IB_6 \rangle'};
x=rand(50,1);
j=1;

conversiontime=1/(60*60);
labels={'IA_1', 'IB_1', 'IA_2', 'IB_2', 'IA_3', 'IB_3', 'IA_4', 'IB_4', 'IA_5', 'IB_5', 'IA_6', 'IB_6'};

aristeonum=0;
aristeosum=0;

stalironum=0;
stalirosum=0;

rhb1aristeodata=[];
rhb2aristeodata=[];
ataristeodata=[];
afcaristeodata=[];
igcaristeodata=[];


rhb1stalirodata=[];
rhb2stalirodata=[];
atstalirodata=[];
afcstalirodata=[];
igcstalirodata=[];

minval=100;

avgmatrix=zeros(5,size(staliroIndex,2));
avgtime=zeros(5,size(staliroIndex,2));
for k=1:1:size(staliroIndex,2)

    set(groot, 'defaultAxesTickLabelInterpreter','latex'); 

    i=aristeoIndex(k);
    
    
    
    
    fid=fopen(strcat('rq3resultsIterationsaristeo',num2str(i),'.csv'));
    a=str2num(fgetl(fid))';
    a1=[a; ones(100-size(a,1),1)*i];
    a=str2num(fgetl(fid))';
    a2=[a; ones(100-size(a,1),1)*i];
    a=str2num(fgetl(fid))';
    a3=[a; ones(100-size(a,1),1)*i];
    a=str2num(fgetl(fid))';
    a4=[a; ones(100-size(a,1),1)*i];
    a=str2num(fgetl(fid))';
    a5=[a; ones(100-size(a,1),1)*i];
    
    a1=(9865*(a1-1)+16902)*conversiontime;
    a2=(9865*(a2-1)+16902)*conversiontime;
    a3=(9865*(a3-1)+16902)*conversiontime;
    a4=(9865*(a4-1)+16902)*conversiontime;
    a5=(9865*(a5-1)+16902)*conversiontime;
    
    mina1=min(a1);
    mina2=min(a2);
    mina3=min(a3);
    mina4=min(a4);
    mina5=min(a5);
    
    rhb1aristeodata=[rhb1aristeodata; a1];
    rhb2aristeodata=[rhb2aristeodata; a2];
    ataristeodata=[ataristeodata; a3];
    afcaristeodata=[afcaristeodata; a4];
    igcaristeodata=[igcaristeodata; a5];
    
    aristeosum=aristeosum+sum(a1)+sum(a2)+sum(a3)+sum(a4)+sum(a5);
    aristeonum=aristeonum+numel(a1)+numel(a2)+numel(a3)+numel(a4)+numel(a5);
    
    fclose(fid);

    h=staliroIndex(k);
      fid=fopen(strcat('rq3resultsIterationsstaliro',num2str(h),'.csv'));
    b=str2num(fgetl(fid))';
    b1=[b; ones(100-size(b,1),1)*h];
    
    b=str2num(fgetl(fid))';
    b2=[b; ones(100-size(b,1),1)*h];

     b=str2num(fgetl(fid))';
    b3=[b; ones(100-size(b,1),1)*h];
    
     b=str2num(fgetl(fid))';
    b4=[b; ones(100-size(b,1),1)*h];
    
     b=str2num(fgetl(fid))';
    b5=[b; ones(100-size(b,1),1)*h];
    
    b1=(b1*8336)*conversiontime;
    b2=(b2*8336)*conversiontime;
    b3=(b3*8336)*conversiontime;
    b4=(b4*8336)*conversiontime;
    b5=(b5*8336)*conversiontime;
    
    minb1=min(b1);
    minb2=min(b2);
    minb3=min(b3);
    minb4=min(b4);
    minb5=min(b5);

    
    rhb1stalirodata=[rhb1stalirodata; b1];
    rhb2stalirodata=[rhb2stalirodata; b2];
    atstalirodata=[atstalirodata; b3];
    afcstalirodata=[afcstalirodata; b4];
    igcstalirodata=[igcstalirodata; b5];
    
    stalirosum=stalirosum+sum(b1)+sum(b2)+sum(b3)+sum(b4)+sum(b5);
    stalironum=stalironum+numel(b1)+numel(b2)+numel(b3)+numel(b4)+numel(b5);
    
    
    avgtimearisteo=[sum(a1)/100; sum(a2)/100; sum(a3)/100; sum(a4)/100; sum(a5)/100];
    avgtimestaliro=[sum(b1)/100; sum(b1)/100; sum(b1)/100; sum(b1)/100; sum(b1)/100];
    
    %% average percentage speed up for a given iteration pair and benchmark
    avgmatrix(:,k)=(avgtimestaliro-avgtimearisteo)*100./avgtimestaliro;
    avgtime(:,k)=avgtimestaliro-avgtimearisteo;
    
    fclose(fid);
    
    %%
    subplot(5,6,j);
    X=[a1, b1];
    boxplot(X,'Labels',{'ARIsTEO','S-Taliro'},'DataLim',[0,20+j*5]);
        ylim([0,20+(j-1)*5]);
    title(titles{j},'Interpreter','tex','FontSize',15);
    
    hold on; plot([mean(a1(:,1)),mean(b1(:,1))], 'dg');
    if(j==1)
        ylabel({'RHB(1)','Time (h)'},'FontSize',15);
    end
    

     %%
    subplot(5,6,j+6);
    
    X=[a2, b2];
    boxplot(X,{'ARIsTEO','S-Taliro'},'DataLim',[0,20+j*5]);
    ylim([0,20+(j-1)*5]);
    
   hold on; plot([mean(a2(:,1)),mean(b2(:,1))], 'dg');
    if(j==1)
        ylabel({'RHB(2)','Time (h)'},'FontSize',15);
    end
    
     %%
    subplot(5,6,j+12);
    X=[a3, b3];
    g = [zeros(length(a3), 1); ones(length(b3), 1)];
    boxplot(X,{'ARIsTEO','S-Taliro'},'DataLim',[0,20+j*5]);
    ylim([0,20+(j-1)*5]);
    hold on; plot([mean(a3(:,1)),mean(b3(:,1))], 'dg')
    if(j==1)
        ylabel({'AT','Time (h)'},'FontSize',15);
    end
    
    
    %% 
    subplot(5,6,j+18);
    X=[a4, b4];
    boxplot(X,{'ARIsTEO','S-Taliro'},'DataLim',[0,20+j*5]);
    ylim([0,20+(j-1)*5]);
    hold on; plot([mean(a4(:,1)),mean(b4(:,1))], 'dg')

    if(j==1)
        ylabel({'AFC','Time (h)'},'FontSize',15);
    end
    
    %%
    subplot(5,6,j+24);
    X=[a5, b5];
    boxplot(X,{'ARIsTEO','S-Taliro'},'DataLim',[0,20+j*5]);
    ylim([0,20+(j-1)*5]);
    hold on; plot([mean(a5(:,1)),mean(b5(:,1))], 'dg')
    if(j==1)
        ylabel({'IGC','Time (h)'},'FontSize',15);
    end
     
    j=j+1;
end




alpha=0.05;
[p,h]=ranksum(rhb1aristeodata,rhb1stalirodata,'alpha',alpha);
disp(strcat('RHB1 Wilcoxon test alpha= ',num2str(alpha),' p-value=',num2str(p),' rejected=',num2str(h)));

[p,h]=ranksum(rhb2aristeodata,rhb2stalirodata,'alpha',alpha);
disp(strcat('RHB2 Wilcoxon test alpha= ',num2str(alpha),', p-value=',num2str(p),' rejected=',num2str(h)));

alpha=0.01;
[p,h]=ranksum(ataristeodata,atstalirodata,'alpha',alpha);
disp(strcat('AT Wilcoxon test alpha= ',num2str(alpha),', p-value=',num2str(p),' rejected=',num2str(h)));

alpha=0.06;
[p,h]=ranksum(afcaristeodata,afcstalirodata,'alpha',alpha);
disp(strcat('AFC Wilcoxon test alpha= ',num2str(alpha),', p-value=',num2str(p),' rejected=',num2str(h)));

alpha=0.01;
[p,h]=ranksum(igcaristeodata,igcstalirodata,'alpha',alpha);
disp(strcat('IGC Wilcoxon test alpha= ',num2str(alpha),', p-value=',num2str(p),' rejected=',num2str(h)));



disp(strcat('Average execution time S-Taliro: ',num2str(stalirosum/stalironum)));
disp(strcat('Average execution time ARIsTEO: ', num2str(aristeosum/aristeonum)));

disp(strcat('Minimum boost on efficiency across the iteration pairs and benchmarks: ',num2str(min(min(avgmatrix)))));
disp(strcat('Maximum boost on efficiency across the iteration pairs and benchmarks: ',num2str(max(max(avgmatrix)))));

disp(strcat('Average boost execution time',num2str(mean2(avgmatrix(:,:)))));



disp(strcat('Minimum boost on efficiency AT: ',num2str(min(min(avgmatrix([3,5],:))))));
disp(strcat('Maximum boost on efficiency IGC: ',num2str(max(max(avgmatrix([3,5],:))))));

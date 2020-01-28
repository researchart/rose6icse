% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
close all
clear
maxn=10; % maximum order of the model
incrementn=2; % increment in the order of the model
minn=2; % minimum order of the model
orders = minn:incrementn:maxn;
   
models={'arx','armax','bj','tf','ss','nlarx','hw'};
c=getcolors(size(models,2));

f=figure();
h1 = axes;
set(h1, 'Ydir', 'reverse');

experiments={'AT','RHB1','RHB2','AFC','IGC'}; 
s=printfig(experiments,models, orders,c);




function [s]=printfig(experiments,models, orders,c)
    figure();
    hold on;
    Q=zeros(length(models),length(orders),length(experiments));
    K=zeros(length(models),length(orders),length(experiments));
   
    totaltime=0;
    
    for h=1:length(experiments)
        experiment=experiments{h};
        for k=1:length(models)
            curmodel=models{k};
            

            fileID = fopen(strcat(experiment,'/',curmodel,'Statistics.txt'),'r');
            A = fscanf(fileID,'%f');
            totaltime=totaltime+A;
            fclose(fileID);
            M1=readtable(strcat(experiment,'/',curmodel,'results.csv'));
            for j=1:length(orders)
                order=orders(j);
                M2=M1(M1.Order==order,:);
                if(isempty(M2.AvgIterations) || size(M2.AvgIterations,1)==0)
                   Q(k,j,h)=10;
                   K(k,j,h)=0;
                else
                   if(isnan(M2.AvgIterations))
                       Q(k,j,h)=10;
                       K(k,j,h)=0;
                       disp(strcat('Error in ',curmodel,' order ',num2str(order)));
                   else 
                       Q(k,j,h)=M2.AvgIterations;
                       K(k,j,h)=M2.Percentage;
                   end
                   
                end
            end
             
            
        end
    end
   s={};
   i=1;
   atmp={};
   P=zeros(length(models)*length(orders),2);
   for k=1:length(models)
            for j=1:length(orders)
                order=orders(j);
                switch order
                     case 2
                         Marker='o';
                     case 4
                         Marker='^';
                     case 6
                         Marker='v';
                     case 8
                         Marker='s';
                     case 10
                         Marker='p';
                     otherwise
                         disp('other value')
                 end
                P(i,:)=[mean(Q(k,j,:)) 100-mean(K(k,j,:))];
                
                s{i}=strcat(models{k},'_',num2str(order/2));
                i=i+1;
            end
   end
   
    set(gca, 'Ydir','reverse');

    
    i=1;
    maxx=0;
        miny=100;
   for k=1:length(models)
            for j=1:length(orders)
                order=orders(j);
                switch order
                     case 2
                         Marker='o';
                     case 4
                         Marker='^';
                     case 6
                         Marker='v';
                     case 8
                         Marker='s';
                     case 10
                         Marker='p';
                     otherwise
                         disp('other value')
                end
               a=scatter(mean(Q(k,j,:)), mean(K(k,j,:)),'filled',Marker,'MarkerFaceColor',c(k,:));
                atmp{i}=a;
               plot(mean(Q(k,j,:)),mean(K(k,j,:)),atmp{i}.Marker,'Color',atmp{i}.CData,'MarkerSize',15,'MarkerFaceColor',c(k,:),'MarkerEdgeColor',atmp{i}.MarkerEdgeColor,'Marker',atmp{i}.Marker,'HandleVisibility','off')
               
               maxx=max(maxx,mean(Q(k,j,:)));
               miny=min(miny,mean(K(k,j,:)));
               if(strcmp(models{k},'bj')==1 && order==2)
                text(mean(Q(k,j,:))-0.35,mean(K(k,j,:)),strcat(models{k},'_',num2str(order/2)),'FontSize',16);
                bj1effectiveness=mean(K(k,j,:));
               end
               if(strcmp(models{k},'ss')==1 && order==4)
                text(mean(Q(k,j,:))-0.35,mean(K(k,j,:)),strcat(models{k},'_',num2str(order/2)),'FontSize',16);
                ss2effectiveness=mean(K(k,j,:));
               end
                i=i+1;
            end
   end
   grid on
   AX=legend(s,'Location', 'southoutside','Orientation','horizontal');
    xlim([1  maxx]);
    ylim([miny  100]);
    AX.FontSize = 15;
    AX.NumColumns = 5;
   set(gca,'FontSize',13)
  xlabel({'Number of Iterations','(Efficiency)'},'FontSize',15,'HorizontalAlignment', 'center');
      ylabel({'(Effectiveness)','Percentage of Successful Runs'},'FontSize',15,'HorizontalAlignment', 'center');
  
end

function c=getcolors(num)
c=colormap(lines(num));

end
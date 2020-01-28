% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,x0,str,ts,simStateCompliance]=pndanim3(t,x,u,flag, ts)%#ok
%PNDANIM3 S-function for animating the motion of a double pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2015 The MathWorks, Inc.

global PendAnim3

if flag==2,
    
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    if any(get(0,'Children')==PendAnim3),
        if strcmp(get(PendAnim3,'Name'),'dblpend2 Animation'),
            set(0,'currentfigure',PendAnim3);
            hndlList=get(gca,'UserData');
            b=.4; c=3;
            xSFP=0; ySFP=0;
            xBFP=xSFP+b*cos(u(1));
            yBFP=ySFP+b*sin(u(1));
            xMB1=-xBFP;
            yMB1=-yBFP;
            xMB2=xMB1+b*sin(u(1));
            yMB2=yMB1-b*cos(u(1));
            xMC=xBFP+c*sin(u(2));
            yMC=yBFP-c*cos(u(2));
            x=[xMB2 xMB1 xBFP NaN xBFP xMC];
            y=[yMB2 yMB1 yBFP NaN yBFP yMC];
            set(hndlList(1),'XData',x,'YData',y);
            drawnow;
            % slow down simulation for better visualization
            pause(0.01); 
        end
    end
    
    set(0,'ShowHiddenHandles',shh);
    
    sys=[];

elseif flag==0,
  % Initialize the figure for use with this simulation
  [PendAnim3 PendAnim3Axes] = animinit('dblpend2 Animation');
  if ishghandle(PendAnim3)
      % bring figure to foreground
      figure(PendAnim3);
  end
  axis(PendAnim3Axes,[-2.5 2.5 -4 2]);
  hold(PendAnim3Axes,'on');

  % Set up the geometry for the problem
  % SFP=Space Fixed Pivot
  % BFP=Body Fixed Pivot
  b=.4; c=3;
  xSFP=0; ySFP=0;
  xMB1=xSFP-b; yMB1=ySFP;
  xMB2=xMB1; yMB2=yMB1-b;
  xBFP=xSFP+b; yBFP=ySFP;
  xMC=xBFP; yMC=yBFP-c;
  % Use NaNs to make the link distinct
  x=[xMB2 xMB1 xBFP NaN xBFP xMC];
  y=[yMB2 yMB1 yBFP NaN yBFP yMC];
  hndlList(1)=plot(PendAnim3Axes,x,y,...
                  'LineWidth',5, ...
                  'Marker','.', ...
                  'MarkerSize',20);

  set(PendAnim3Axes,'DataAspectRatio',[1 1 1]);
  set(PendAnim3Axes,'UserData',hndlList);

  sys = [0 0 0 2 0 0 1];
  x0  = [];
  str = [];
  ts  = [-1, 0];
  % specify that the simState for this s-function is same as the default
  simStateCompliance = 'DefaultSimState';

end


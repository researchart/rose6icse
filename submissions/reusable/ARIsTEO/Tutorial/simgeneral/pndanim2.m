% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,x0,str,ts,simStateCompliance]=pndanim2(t,x,u,flag,ts)%#ok
%PNDANIM2 S-function for animating the motion of a double pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2015 The MathWorks, Inc.

global PendAnim2

if flag==2,
    
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    if any(get(0,'Children')==PendAnim2),
        if strcmp(get(PendAnim2,'Name'),'dblpend1 Animation'),
            set(0,'currentfigure',PendAnim2);
            hndl=get(gca,'UserData');
            b=1; c=2;
            xSFP=0; ySFP=0;
            xBFP=xSFP+b*sin(u(1)); yBFP=ySFP-b*cos(u(1));
            xMC=xBFP+c*sin(u(2)); yMC=yBFP-c*cos(u(2));
            x=[xSFP xBFP NaN xBFP xMC];
            y=[ySFP yBFP NaN yBFP yMC];
            set(hndl,'XData',x,'YData',y);
            drawnow;
            % slow down simulation for better visualization
            pause(0.01); 
        end
    end
    
    set(0,'ShowHiddenHandles',shh);
    
    sys=[];

elseif flag==0,
  % Initialize the figure for use with this simulation
  [PendAnim2 PendAnim2Axes] = animinit('dblpend1 Animation');
  if ishghandle(PendAnim2)
      % bring figure to foreground
      figure(PendAnim2);
  end
  axis(PendAnim2Axes,[-3 3 -5 2]);
  hold(PendAnim2Axes, 'on');

  % Set up the geometry for the problem
  % SFP=Space Fixed Pivot
  % BFP=Body Fixed Pivot
  b=1; c=2;
  xSFP=0; ySFP=0;
  xBFP=xSFP; yBFP=ySFP-b;
  xMC=xBFP; yMC=yBFP-c;
  x=[xSFP xBFP NaN xBFP xMC];
  y=[ySFP yBFP NaN yBFP yMC];
  hndl=plot(PendAnim2Axes,x,y, ...
           'LineWidth',5, ...
           'Marker','.', ...
           'MarkerSize',20);
  set(PendAnim2Axes,'DataAspectRatio',[1 1 1]);
  set(PendAnim2Axes,'UserData',hndl);

  sys = [0 0 0 2 0 0 1];
  x0  = [];
  str = [];
  ts  = [-1, 0];
  % specify that the simState for this s-function is same as the default
  simStateCompliance = 'DefaultSimState';

end


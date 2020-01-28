% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,x0,str,ts,simStateCompliance]=pndanim1(t,xunused,u,flag,ts) %#ok
%PNDANIM3 S-function for animating the motion of a pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2015 The MathWorks, Inc.

global PendAnim1

if flag==2,
    
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    if any(get(0,'Children')==PendAnim1),
        if strcmp(get(PendAnim1,'Name'),'simppend Animation'),
            set(0,'currentfigure',PendAnim1);
            hndlList=get(gca,'UserData');
            x=[u(1) u(1)+2*sin(u(2))];
            y=[0 -2*cos(u(2))];
            set(hndlList(1),'XData',x,'YData',y);
            set(hndlList(2),'XData',u(1),'YData',0);
            if(-2*cos(u(2))>=0 || -2*cos(u(2))<=-3)
                 hndlList(1).Color='red';
            %else
                
            end
            drawnow;
            % slow down simulation for better visualization
            pause(0.01); 
        end
    end
    
    set(0,'ShowHiddenHandles',shh);
    
    sys=[];

elseif flag == 4 % Return next sample hit
  
  % ns stores the number of samples
  ns = t/ts;

  % This is the time of the next sample hit.
  sys = (1 + floor(ns + 1e-13*(1+ns)))*ts;

elseif flag==0,

  % Initialize the figure for use with this simulation
  [PendAnim1 PendAnim1Axes] = animinit('simppend Animation');
  if ishghandle(PendAnim1)
      % bring figure to foreground
      figure(PendAnim1);
  end
  axis(PendAnim1Axes,[-3 3 -2 2]);
  hold(PendAnim1Axes, 'on');

  x=[0 0];
  y=[0 -2];
  if(y(2)>0)
      
      hndlList(1)=plot(PendAnim1Axes,x,y,'LineWidth',5,'Color','green');
  else
    hndlList(1)=plot(PendAnim1Axes,x,y,'LineWidth',5,'Color','green');
  end
  hndlList(2)=plot(PendAnim1Axes,0,0,'.','MarkerSize',25);
  set(PendAnim1Axes,'DataAspectRatio',[1 1 1]);
  set(PendAnim1Axes,'UserData',hndlList);

  sys = [0 0 0 2 0 0 1];
  x0  = [];
  str = [];
  ts  = [-1, 0];
  % specify that the simState for this s-function is same as the default
  simStateCompliance = 'DefaultSimState';

end


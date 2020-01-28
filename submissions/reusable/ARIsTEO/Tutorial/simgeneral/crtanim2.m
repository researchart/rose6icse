% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,x0,str,ts,simStateCompliance]=crtanim2(t,x,u,flag,ts)%#ok
%CRTANIM2 S-function for animating the motion of a mass-spring system.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2010 The MathWorks, Inc.

global xSpr2 xBx12 xBx22 dblcart1

offset=4;

if flag==2,
    
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    if any(get(0,'Children')==dblcart1),
        if strcmp(get(dblcart1,'Name'),'dblcart1 Animation'),
            set(0,'currentfigure',dblcart1)
            u(2)=u(2)+offset;
            distance=u(2)-u(1);
            hndl=get(gca,'UserData');
            x=[xBx12+u(1); xSpr2/4*distance+u(1); xBx22+distance+u(1)];
            set(hndl,'XData',x);
            drawnow;
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
  [dblcart1 dblcartAxes] = animinit('dblcart1 Animation');
  axis(dblcartAxes,[-10 20 -7 7]);
  hold(dblcartAxes,'on');

  xySpr2=[ ...
        0.0       0.0
        0.4       0.0
        0.8       0.65
        1.6      -0.65
        2.4       0.65
        3.2      -0.65
        3.6       0.0
        4.0       0.0];
  xyBx12=[ ...
        0.0       1.1
        0.0      -1.1
       -2.0      -1.1
       -2.0       1.1
        0.0       1.1];
  xyBx22=[ ...
        0.0       1.1
        2.0       1.1
        2.0      -1.1
        0.0      -1.1
        0.0       1.1];
  xBx12=xyBx12(:,1);
  yBx12=xyBx12(:,2);
  xBx22=xyBx22(:,1);
  yBx22=xyBx22(:,2);
  xSpr2=xySpr2(:,1);
  ySpr2=xySpr2(:,2);

  x=[xBx12; xSpr2; xBx22(:,1)+offset];
  y=[yBx12; ySpr2; yBx22];

  % Draw the floor under the sliding masses
  plot(dblcartAxes,[-10 20],[-1.3 -1.3],'yellow', ...
       [-10:19;-9:20],[-2 -1.3],'yellow','LineWidth',2);
  hndl=plot(dblcartAxes,x,y,'y','LineWidth',3);
  set(dblcartAxes,'UserData',hndl);

  sys = [0 0 0 2 0 0 1];
  x0  = [];
  str = [];
  ts  = [-1, 0];
  % specify that the simState for this s-function is same as the default
  simStateCompliance = 'DefaultSimState';

end;



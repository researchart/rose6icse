% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,x0,str,ts] = msfun_metronomean(t,x,u,flag, sampleTime)
%METRONOMANIMATION S-function for making metronome animation.
%
%   Copyright 2010-2014 The MathWorks, Inc.
% Plots every major integration step, but has no states of its own
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts, simStateCompliance] = mdlInitializeSizes(sampleTime); %#ok<*NASGU>

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 1, 3, 4, 9 },
    sys = [];
    
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(message('simdemos:general:UnhandledFlag', num2str( flag )));
end

% end metronomean

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts, simStateCompliance]=mdlInitializeSizes(sampleTime)
%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times, for the pendulum example,
% the animation is updated every 0.1 seconds
%
ts  = [sampleTime 0];

%
% create the figure, if necessary
%
LocalMetronomeInit;

% specify that the simState for this s-function is same as the default
simStateCompliance = 'DefaultSimState';

% end mdlInitializeSizes 

%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
function sys=mdlUpdate(t,x,u) %#ok<*INUSL>

fig = get_param(gcbh, 'UserData');
if ishandle(fig),
  if strcmp(get(fig,'Visible'),'on'),
    LocalMetronomeSets(t,fig,u);
  end
end;

sys = [];
% end mdlUpdate

%=============================================================================
% LocalMetronomeSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
% The geometric length of the pendulum is 10. 
%=============================================================================
function LocalMetronomeSets(time,fig, u)
ud = get(fig,'UserData');
N = numel(u) - 1;
XCart = u(1)*10;               % scaling the x 

PDelta = 7;                 % Horizontal distance among pendulum  
XDelta = (N-1)*PDelta+1;
XPendsBot = XCart + PDelta*2*(-0.5*(N-1):1:0.5*(N-1));
XPendsTop = 10*sin(u(2:end)') + XPendsBot;
YPendsTop = -10*cos(u(2:end)');
HeadColors='kymcgr'; %Pendulum head colors

set(ud.Cart,...
  'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
if ud.N ~= N,
  %rescale the axes and line for the new number of pendulums
  set(ud.AxesH,...
      'Xlim',[-XDelta-7,XDelta+7]);
  set(ud.BaseLine,...
      'XData',[-XDelta-5,XDelta+5]);
  %delete old pendulum lines and heads
  arrayfun(@delete,ud.Pends);
  arrayfun(@delete,ud.Heads);
  ud.Pends = zeros(1,N);
  ud.Heads = zeros(1,N);
  %draw new pendulum lines
  for ii = 1:N,
    ud.Pends(ii) = line([XPendsBot(ii),XPendsTop(ii)],...
        [1,YPendsTop(ii)],'Color','b','LineStyle','-',...
        'LineWidth',2);
    ud.Heads(ii) = line(XPendsTop(ii),YPendsTop(ii),'Color',...
        HeadColors(mod(ii,length(HeadColors))+1),'Marker','.',...
        'MarkerSize',40);
  end
  ud.N = N;
  set(fig,'UserData',ud);
else
  %the number of pendulums hasn't changed, just update the positions
  for ii=1:N,
    set(ud.Pends(ii),...
        'XData',[XPendsBot(ii),XPendsTop(ii)],...
        'YData',[1,YPendsTop(ii)]);
    set(ud.Heads(ii),...
        'XData',XPendsTop(ii),...
        'YData',YPendsTop(ii));
  end
end
set(ud.TimeField,...
  'String',num2str(time));
% Force plot to be drawn
%pause(0.1);
drawnow('expose');
% end LocalPendSets

%
%=============================================================================
% LocalMetronomeInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
function LocalMetronomeInit
close all;
TimeClock = 0;
XCart = 0;
XDelta = 15;
%
% The animation figure handle is stored in the pendulum block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');

if ishandle(Fig),
  ud = get(Fig,'UserData');
  set(ud.TimeField,...
      'String',num2str(TimeClock));
  set(ud.Cart,...
      'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
  set(ud.AxesH,...
      'XLim',[-XDelta-7,XDelta+7]);
  set(ud.BaseLine,...
      'XData',[-XDelta-5,XDelta+5]);
  %delete old pendulum lines and heads
  arrayfun(@delete,ud.Pends);
  arrayfun(@delete,ud.Heads);
  ud.Pends = [];
  ud.Heads = [];
  ud.N = 0;
  set(Fig,'UserData',ud);
  % bring it to the front
  figure(Fig);
  return
end
%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = 'Metronomes Visualization';

Fig = figure(...
  'Units',           'pixel',...
  'Position',        [100 100 500 300],...
  'Name',            FigureName,...
  'NumberTitle',     'off',...
  'IntegerHandle',   'off',...
  'Resize',          'on');
set(Fig, 'MenuBar', 'none');
AxesH = axes(...
  'Parent',  Fig,...
  'Units',   'pixel',...
  'Position',[50 50 400 200],...
  'CLim',    [1 64], ...
  'XLim',    [-22 22],...
  'YLim',    [-10 2],...
  'Visible', 'off');

Cart = surface(...
  'Parent',   AxesH,...
  'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
  'YData',    [0 0; 2 2],...
  'ZData',    zeros(2),...
  'CData',    ones(2));

BaseLine = line([-XDelta-5,XDelta+5],[0,0],'linewidth',3);

uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [150 0 100 25], ...
  'HorizontalAlignment','right',...
  'String',             'Time: ');

TimeField = uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [250 0 100 25],...
  'HorizontalAlignment','left',...
  'String',             num2str(TimeClock));
 
FigUD.Cart         = Cart;
FigUD.Pends        = [];
FigUD.TimeField    = TimeField;
FigUD.Heads        = [];
FigUD.N            = 0;
FigUD.BaseLine     = BaseLine;
axis equal
FigUD.Block        = get_param(gcbh,'Handle');
FigUD.AxesH        = AxesH;
set(Fig,'UserData',FigUD);
drawnow
% store the figure handle in the animation block's UserData
set_param(gcbh,'UserData',Fig);
% end LocalPendInit

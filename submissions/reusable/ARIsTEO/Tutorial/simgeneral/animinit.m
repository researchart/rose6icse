% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [figNumber, cA]=animinit(namestr)
%ANIMINIT Initializes a figure for Simulink animations.
  
%   Ned Gulley, 6-21-93
%   Copyright 1990-2014 The MathWorks, Inc.
  
if (nargin == 0)
  namestr = 'Simulink Animation';
end

shh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

figNumber = findobj('Type','figure','Name',namestr)';
if ~isempty(figNumber) 
    cA = findobj(figNumber,'Type', 'Axes');
end

set(0,'ShowHiddenHandles',shh);

if isempty(figNumber) 
  % Now initialize the whole figure...
  position=get(0,'DefaultFigurePosition');
  position(3:4)=[400 300];
  figNumber=figure( ...
      'Name',namestr, ...
      'NumberTitle','off', ...
      'BackingStore','off', ...
      'Position',position, ...
      'HandleVisibility','callback', ...
      'MenuBar', 'none');
  cA=axes( ...
      'Parent', figNumber, ...
      'Units','normalized', ...
      'Position',[0.05 0.1 0.70 0.9], ...
      'Visible','off');

    set(cA,'SortMethod','childorder');

  %====================================
  % Information for all buttons
  %   labelColor=[0.8 0.8 0.8];
  %   yInitPos=0.90;
  %   top=0.95;
  bottom=0.05;
  left=0.80;
  btnWid=0.15;
  btnHt=0.10;
  % Spacing between the button and the next command's label
  %   spacing=0.04;
    
  %====================================
  % The CONSOLE frame
  frmBorder=0.02;
  yPos=0.05-frmBorder;
  frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
  h=uicontrol( ...
      'Parent', figNumber, ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.5 0.5 0.5]); %#ok<NASGU>
  
  %====================================
  % The CLOSE button
  labelStr='Close';
  callbackStr='close(gcf)';
  closeHndl=uicontrol( ...
      'Parent', figNumber, ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[left bottom btnWid btnHt], ...
      'String',labelStr, ...
      'Callback',callbackStr); %#ok<NASGU>
else
    % bring figure to foreground
    figure(figNumber)
end

cla(cA,'reset');
set(cA,'SortMethod','childorder');
axis(cA,'off');

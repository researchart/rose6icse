% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function setup_monitor(varargin)

path_var = pwd;
addpath(path_var);

skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

if ~skip_mex
    mex on_line.c;
    matlabVersion = version;
    matlabVersionSplit = strfind(matlabVersion, '.');
    matlabVersionMain = matlabVersion(1:(matlabVersionSplit(2)-1));
    matlabVersion = str2double(matlabVersionMain);
    if matlabVersion < 8.45 %Earlier than 2015a (8.5)
        lb = LibraryBrowser.StandaloneBrowser;
        lb.refreshLibraryBrowser;
    else
        libBrow = LibraryBrowser.LibraryBrowser2;
        libBrow.refresh;
    end

    disp('***************************************************************************');
    disp('See the new Simulink blocks in the             ');
    disp('Simulink Library Browser under S-TaLiRo        ');
    disp('***************************************************************************');
    disp('For a demo see demo_autotrans_monitoring.mdl   ');
    disp('under the demos folder                         ');
    disp('***************************************************************************');
end

disp('***************************************************************************');
disp('You are all set to use S-TaLiRo On-Line Monitor');
disp('***************************************************************************');

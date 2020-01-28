% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function deploytemplateconf(confName)
%DEPLOYTEMPLAECONF rewrites a local confName configuration with a template
%with a similar name
%
%Input:
%   regular:
%       confName:char[1,] - name of configuration to edit
%
%$Author: Petr Gagarinov <pgagarinov@gmail.com> $    $Date: 09-Apr-2013 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.deployConfTemplate(confName);
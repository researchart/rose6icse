% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = blkvar
% BLKVAR Constructor for block variables

X.blocks = {};
X = class(X,'blkvar',sdpvar(1));
	
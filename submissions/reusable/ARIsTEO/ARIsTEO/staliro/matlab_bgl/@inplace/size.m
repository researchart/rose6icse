% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [varargout] = size(ipa)
% INPLACE/SIZE Size of array
%
% [m,n] = size(ipa) Juse like SIZE for matrices and vectors.
%
% Example:
%    ipa = inplace(ones(10,3));
%    size(ipa)

varargout{:} = size(ipd.get_a());
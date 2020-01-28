% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Z = mtimes(A,B)
%plus           Overloaded

% Standard case A.cx + A.logdetP + (B.cx + B.logdetP)

if ~(isa(A,'double') | isa(B,'double'))
    error('LOGDET objects can only be multiplied with constants')
end

if isa(A,'logdet')
    temp = A;
    A = B;
    B = temp;
end

% OK, constant*logdet
% end
B.gain = B.gain*A;
B.cx = B.cx*A;
Z = B;
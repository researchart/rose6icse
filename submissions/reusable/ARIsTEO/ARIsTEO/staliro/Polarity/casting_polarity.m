% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  

function obj = casting_polarity(varargin)


if nargin==1 && isa(varargin{1},'struct')
    if min(isfield(varargin{1}, {'polarity'; 'index'}))
        obj = struct('polarity',varargin{1}.polarity,'index',varargin{1}.index);
    else
        error('casting_polarity: This is not a valid input structure: field "polarity" or "index" is missing!')
    end
else
    error('casting_polarity: Invalid input arguments')
end

end


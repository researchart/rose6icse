% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function s=cell2str(cstr,indent)
% define linebreak
NewLine=char([10]);

if iscellstr(cstr)
    % add indent and linebreak to each cell element
    h=strcat({indent}, cstr,{NewLine});
    % convert to char array
    s=[h{:}];
    % remove last NewLine
    s=s(1:(end-length(NewLine)));
else
    s=cstr;
end 
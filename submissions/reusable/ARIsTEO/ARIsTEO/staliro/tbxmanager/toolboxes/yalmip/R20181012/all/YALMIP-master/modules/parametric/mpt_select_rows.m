% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [Fi,Gi] = mpt_select_rows(Fi,Gi,requested_variables);
if length(Fi) > 0
    for i = 1:length(Fi)
        Fi{i} = Fi{i}(requested_variables,:);
        Gi{i} = Gi{i}(requested_variables,:);
    end
end

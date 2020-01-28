% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function UPoint = generateUPoint(cp_array,input_range)
%GENERATEUPOINT Summary of this function goes here
%   Detailed explanation goes here

     UPoint=zeros(1,sum(cp_array));

    index=1;
    tmp_CP=zeros(size(cp_array,2));
    for n=1:1:size(cp_array,2)
        if n==1 
         tmp_CP(n)=cp_array(n);
        else
         tmp_CP(n)=tmp_CP(n-1)+cp_array(n);
        end
        maxvalue=input_range(n,2);
        minvalue=input_range(n,1);
        diff=maxvalue-minvalue;

        for current_cp=1:1:cp_array(n)

            UPoint(index)=minvalue+rand(1)*diff;
            index=index+1;
        end
    end
end


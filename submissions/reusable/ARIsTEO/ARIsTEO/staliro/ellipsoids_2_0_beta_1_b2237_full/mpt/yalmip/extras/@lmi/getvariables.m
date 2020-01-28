% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function used = getvariables(F)

used = recursivegetvariables(F,1,length(F.clauses));
return

m = length(F.clauses);
if m == 1
    used = getvariables(F.clauses{1}.data);
else
    if m>50
        for i = 1:m
            Fivars = getvariables(F.clauses{i}.data);
            used = [used Fivars(:)'];
        end
        used = uniquestripped(used);
    else
        for i = 1:m
            Fivars = getvariables(F.clauses{i}.data);
            used = uniquestripped([used Fivars(:)']);
        end
    end
end


function used = recursivegetvariables(F,startindex,endindex)

if endindex-startindex>50
    newstart = startindex;
    mid = ceil((startindex + endindex)/2);
    newend = endindex;
    used1 = recursivegetvariables(F,newstart,mid);
    used2 = recursivegetvariables(F,mid+1,newend);
    used = uniquestripped([used1 used2]);
else
    used = [];
    for i = startindex:endindex
        Fivars = getvariables(F.clauses{i}.data);
        used = [used Fivars(:)'];
    end
    used = uniquestripped(used); 
end

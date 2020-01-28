% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function prettyPrintMatrix(fileID, A)
[m ~] = size(A);
fprintf(fileID,'[ ');
for i = 1:m 
    fprintf(fileID,' %f ', A(i,:));
    fprintf(fileID,';\n');
end

fprintf(fileID,'];\n');

end
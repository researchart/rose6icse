% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function schurtmp = schurgateway(X,Z,userdata)

% Send slack, dual and user-data to the Hessian compiler
schurtmp1 = feval(userdata{1}.fun,full(X),full(Z),userdata{1}.extra,userdata{1}.data{:});

% Place these values in the correct location in the global Hessian
if  (1+userdata{1}.index(end)-userdata{1}.index(1)) == length(userdata{1}.index)
    n1 = userdata{1}.index(1)-1;
    % n2 = userdata{1}.nvars-length(userdata{1}.index)-n1;

    n3 = size(schurtmp1,1); schurtmp = zeros(userdata{1}.nvars); schurtmp(n1+1:n1+n3,n1+1:n1+n3) = schurtmp1;
    % schurtmp = blkdiag(blkdiag(zeros(n1,n1),schurtmp),zeros(n2,n2));

else
    [i,j,k] = find(schurtmp1);
    schurtmp = sparse(userdata{1}.index(i),userdata{1}.index(j),k,userdata{1}.nvars,userdata{1}.nvars);
end

% function schurtmp = schurgateway(X,Z,userdata)
% 
% %Send slack, dual and user-data to the Hessian compiler
% schurtmp = feval(userdata{1}.fun,(X),(Z),userdata{1}.data{:});
% 
% %Place these values in the correct location in the global Hessian
% if  (1+userdata{1}.index(end)-userdata{1}.index(1)) == length(userdata{1}.index)
%     n1 = userdata{1}.index(1)-1;
%     n2 = userdata{1}.nvars-length(userdata{1}.index)-n1;
%      if n2 == 0
%          schurtmp = blkdiag(zeros(n1,n1),schurtmp);
%      else
%         schurtmp = blkdiag(blkdiag(zeros(n1,n1),schurtmp),zeros(n2,n2));
%     end
% else
%     [i,j,k] = find(schurtmp);
%     schurtmp = sparse(userdata{1}.index(i),userdata{1}.index(j),k,userdata{1}.nvars,userdata{1}.nvars);
% end
% 
% % 
% % 
% % % % Send slack, dual and user-data to the Hessian compiler
% % schurtmp1 = feval(userdata{1}.fun,full(X),full(Z),userdata{1}.data{:});
% % 
% % % Place these values in the correct location in the global Hessian
% % %[i,j,k] = find(schurtmp);
% % if  (1+userdata{1}.index(end)-userdata{1}.index(1)) == length(userdata{1}.index)
% %     n1 = userdata{1}.index(1)-1;
% %     % n2 = userdata{1}.nvars-length(userdata{1}.index)-n1;
% % 
% %     n3 = size(schurtmp1,1); schurtmp = zeros(userdata{1}.nvars); schurtmp(n1+1:n1+n3,n1+1:n1+n3) = schurtmp1;
% %     % schurtmp = blkdiag(blkdiag(zeros(n1,n1),schurtmp),zeros(n2,n2));
% %     
% % else
% %     [i,j,k] = find(schurtmp1);
% %     schurtmp = sparse(userdata{1}.index(i),userdata{1}.index(j),k,userdata{1}.nvars,userdata{1}.nvars);
% % end

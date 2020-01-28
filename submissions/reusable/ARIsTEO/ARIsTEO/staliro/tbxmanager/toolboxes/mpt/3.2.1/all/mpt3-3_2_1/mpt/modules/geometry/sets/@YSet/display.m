% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function display(obj)
%
% overloads display for YSet objects
%


if numel(obj)==0
    fprintf('Empty YSet array.\n');
    return;
elseif numel(obj) > 1
    fprintf('Array of %i YSets.\n', numel(obj));
    return;
end

fprintf('YALMIP set in dimension %d.\n',obj.Dim);
       
% display attached functions (implemented in ConvexSet/displayFunctions)
obj.displayFunctions;

end

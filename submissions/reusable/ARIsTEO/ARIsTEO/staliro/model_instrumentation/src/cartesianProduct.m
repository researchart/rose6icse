% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function result = cartesianProduct(sets)
    c = cell(1, numel(sets));
    [c{:}] = ndgrid( sets{:} );
    result = cell2mat( cellfun(@(v)v(:), c, 'UniformOutput',false) );
end
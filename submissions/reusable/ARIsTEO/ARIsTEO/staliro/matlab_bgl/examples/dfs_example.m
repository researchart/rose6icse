% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
load ../graphs/dfs_example.mat
[d dt ft pred] = dfs(A,2);
[ignore order] = sort(dt);
labels(order)



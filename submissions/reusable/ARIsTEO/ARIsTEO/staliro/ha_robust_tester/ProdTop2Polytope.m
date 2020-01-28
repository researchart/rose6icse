% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% This is a supporting function for hsbenchmark1.
% input must be m x 2
% G. Fainekos

function pp = ProdTop2Polytope(Sin)

mm = size(Sin,1);

pp = Sin(1,:)';
for ii = 2:mm
    kk = 1;
    np = [];
    for jj = 1:size(pp,1)
        np(kk,:) = [pp(jj,:) Sin(ii,1)];        
        kk = kk+1;
        np(kk,:) = [pp(jj,:) Sin(ii,2)];
        kk = kk+1;
    end
    pp = np;
end

        
        
        
        
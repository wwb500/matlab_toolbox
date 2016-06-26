function [ cost ] = getDtw2(f1,f2,dist)

switch dist
    case 'cosine'
        SM=simmx(f1,f2);
        DM=1-SM;
    case 'euc'
        DM=pdist2(f1',f2');    
end

[~,~,C] = dpfast(DM);

cost=C(size(C,1),size(C,2));
end


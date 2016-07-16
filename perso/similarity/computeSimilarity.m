function [ A ] = computeSimilarity(X,param)

X=full(X');

switch param.similarity
    
    case {'euclidean'}
        A = dist2(X, X); % need to be dist
    case {'sqeuclidean'}
        A = sqrt(dist2(X, X)); % need to be dist
    case {'cosine'}
        D=squareform(pdist(X,param.similarity));
        A=1-D/(max(D(:)));  
    case 'inner_sparse'
        D = dist2(X, X);
        Xnorm = X';
        d = 1./sqrt(sum(Xnorm.^2));
        Xnorm = bsxfun(@times, Xnorm, d);
        kk=round(param.sparse_nn*size(D,2));
        A = inner_product_knn(D, Xnorm, kk, true);
        
    case 'inner_full'
        A = X * X';
        
    case 'gaussian_sparse'
        D = dist2(X, X);
        nn=round(param.nn*size(D,2));
        kk=round(param.sparse_nn*size(D,2));
        A = scale_dist3_knn(D,nn , kk, true);
        
    case 'gaussian_full'
        D = dist2(X, X);
        nn=max([1 round(param.nn*size(D,2))]);
        % A = scale_dist3(D, nn);
        [ A ] = rbfKernel(D,'st-1nn',nn);
        
    otherwise
        error('invalid similarity setting.')
end

clearvars Xnorm d D;

if param.normalizedCut==1
    dd = 1 ./ sum(A);
    dd = sqrt(dd);
    A = bsxfun(@times, A, dd);
    A = A';
    A = bsxfun(@times, A, dd);
    clearvars dd;
end

A = (A + A') / 2;

end


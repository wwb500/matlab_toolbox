function [prediction,A,params] = similarityBasedClustering(X,params )

[ A ] = computeSimilarity(X,params);

%% rescale
A=A/max(A(:));
A(logical(eye(size(A)))) = 1;

%% smoothing

if params.smoothing~=0
    [ A ] = manualSmoothing(full(A),params.smoothing,params.smoothing,params.hoptime);
end

%% clustering

switch params.clustering
    
    case 'simNMF'
        
        A(logical(eye(size(A)))) = 0;
        [prediction, params] = symnmf(A,params);
        
    case 'knkmeans'
        
        [ clustering ] = getKnKmeans(full(A),params.nbc);
        
        prediction=clustering.prediction;
        
        params.iterMax=clustering.iterMax;
        params.nbRuns=clustering.nbRuns;
        params.iterMax=clustering.nbClustersClus;
        params.iterMax=clustering.iterMax;
        params.globalCrit=clustering.globalCrit;
        params.SS=clustering.SS;
        params.t=clustering.t;
        params.log=clustering.log;
%         params.centerDist=clustering.centerDist;
end


end


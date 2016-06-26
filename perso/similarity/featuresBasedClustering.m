function [ prediction,clusterLocations,params] = featuresBasedClustering(X,params )

%% clustering

switch params.clustering
    
    case 'kmeans'
        
        if params.nbc==0
            clusterLocations=full(X)';
            prediction=ones(1,size(X,2));
        else
            [prediction,clusterLocations] = kmeans(full(X)',params.nbc,'maxiter',1000,'replicates',5,'start','plus','Distance',params.similarity,'EmptyAction',params.emptyAction);
        end
        
        clusterLocations=clusterLocations';
        
    case 'ahc'
        
        switch params.ahc_method
            case 'centroid'
                warning off
                Z = linkage(full(X)','centroid','euclidean');
                warning on
            case 'ward'
                Z = linkage(full(X)','ward','euclidean');
        end
        
        Y=inconsistent(Z);
        prediction = cluster(Z,'cutoff',max(Y(:,4))*0.75);
        
        labels=unique(prediction);
        clusterLocations=cell2mat(arrayfun(@(x) mean(X(:,prediction==x),2),labels,'UniformOutput',false)');

end



end


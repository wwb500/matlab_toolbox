function [simClus,clusterOrder] = clusterSimilarity(features,prediction,params)

%% mode for computing simClus

switch params.mode
    
    case 'centroid'
        [ simClus ] = computeSimilarity(features,params);
        simClus=simClus/max(simClus(:));
        simClus(logical(eye(size(simClus)))) = 1;
        if params.similarity_thresh~=1 && params.similarity_thresh~=0
            simClus=simClus.*getRP(simClus,params.similarity_thresh,'sim');
        end
    case 'vlad'
        D=squareform(pdist(features','euclidean'));
        [ simClus ] = computeSimilarity(D,params);
        simClus=simClus/max(simClus(:));
        simClus(logical(eye(size(simClus)))) = 1;
        if params.similarity_thresh~=1 && params.similarity_thresh~=0
            simClus=simClus.*getRP(simClus,params.similarity_thresh,'sim');
        end
    case 'average'
        
        labels=unique(prediction);
        simClus=zeros(params.nbc,params.nbc);
        
        for ii=labels
            for jj=labels
                featurestmp=features(prediction==ii,prediction==jj);
                simClus(ii,jj)=mean(featurestmp(:));
            end
        end
        
end


%% order cluster

if params.order==1
    
    labels=unique(prediction);
    emptyLabels=find(arrayfun(@(x) ~any(x==labels),1:params.nbc));
    
    if any(params.firstClus==emptyLabels)
        emptyLabels(params.firstClus==emptyLabels)=labels(1);
        prediction(prediction==labels(1))=params.firstClus;
        labels(1)=params.firstClus;
    end
    
    flag=1;
    ind2rm=[params.firstClus emptyLabels];
    currentClus=params.firstClus;
    clusterOrder=params.firstClus;
    
    while flag
        
        [~,indClus]=sort(simClus(currentClus,:),'descend');
        indClus=indClus(arrayfun(@(x) ~any(x==ind2rm),indClus));
        
        currentClus=indClus(1);
        clusterOrder=[clusterOrder currentClus];
        ind2rm=[ind2rm currentClus];
        
        if (length(clusterOrder)+length(emptyLabels))==params.nbc
            flag=0;
        end
        
    end
    
    clusterOrder=[clusterOrder emptyLabels];
    
    % order simClus
    simClus=simClus(clusterOrder,clusterOrder);
    simClus=simClus/max(simClus(:));
    simClus(logical(eye(size(simClus)))) = 1;
    
else
    
    clusterOrder=[];
    
end

end


function [ sf_output ] = sf_segmentation(features,oldPred,sel,xp_settings,param,nbc)

oldPred=oldPred(:)';
sf_output.prediction=double(oldPred);

%% similarity

paramSim.kernelSig_nei=param.nei_1;
paramSim.type = param.dist_1;
simMat1=getSim(features(:,oldPred==sel),paramSim);
simMat1=simMat1+triu(simMat1,1)';
simMat1=full(simMat1/max(simMat1(:)));

%% SF

sf=simMat1;

for jj=1:size(sf,2)
    sf(:,jj)=circshift( sf(:,jj),-jj+1);
end


%% Similarity 2

paramSim.kernelSig_nei=param.nei_2;
paramSim.type = param.dist_2;
simMat2=getSim(sf,paramSim);
simMat2=simMat2+triu(simMat2,1)';
simMat2=full(simMat2/max(simMat2(:)));

%% clustering

[ clustering ] = clusteringSmoothRank(simMat2,param.smooth,xp_settings.hoptime,nbc);

%% output

sf_output.predictionMin=clustering.prediction;
sf_output.simMatMin=simMat2;
sf_output.simMatOr=simMat1;
sf_output.featuresMin=features(:,oldPred==sel);
sf_output.val=clustering.val;
sf_output.var=clustering.val2;
sf_output.prediction(oldPred==sel)=clustering.prediction+max(sf_output.prediction);
end
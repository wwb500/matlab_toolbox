function [ clusteringOutput ] = clusteringSmoothRank(simMat,smoothingTime,hoptime,nbc)

clusteringOutput.prediction=zeros(1,size(simMat,2));
clusteringOutput.val=zeros(1,nbc);
val=zeros(1,nbc);
val2=zeros(1,nbc);

if smoothingTime~=0
    [ simMat ] = manualSmoothing(full(simMat),smoothingTime,smoothingTime,hoptime);
    simMat=simMat/max(simMat(:));
end

rng(0)
[ clustering] = getKnKmeans(simMat ,nbc);

sTmp=simMat;
sTmp(logical(eye(size(sTmp)))) = 0;

for hh=1:nbc
    if numel(sTmp(clustering.prediction==hh,clustering.prediction==hh))==1
        val(hh)=sTmp(clustering.prediction==hh,clustering.prediction==hh);
        val2(hh)=0;
    else
        val(hh)= mean(squareform(sTmp(clustering.prediction==hh,clustering.prediction==hh)));
        val2(hh)=var(squareform(sTmp(clustering.prediction==hh,clustering.prediction==hh)));
    end
end

[val,ind]=sort(val,'ascend');

for hh=1:length(ind)
    clusteringOutput.prediction(clustering.prediction==ind(hh))=hh;
    clusteringOutput.val(hh)=val(hh);
    clusteringOutput.val2(hh)=val2(hh);
end

end


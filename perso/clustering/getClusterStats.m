function [ stats ] = getClusterStats(prediction,features)

labels=unique(prediction);
stats=zeros(size(features,1)*3,length(labels));

for jj=1:length(labels)
    y = quantile(features(:,prediction==labels(jj)),[0.25 0.5 0.75],2);
    stats(:,jj)=y(:);
end


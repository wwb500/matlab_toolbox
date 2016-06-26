function [ probij ] = getTransitionMatrix( labels,varargin)

if isempty(varargin)
    symbol=1:max(labels);
end

probij= zeros(length(symbol));
probSynbol = zeros(1,length(symbol));

for ii=1:length(symbol)
    probSynbol(ii)=sum(labels==symbol(ii));
    for jj=1:length(symbol)
        trans=diff((labels==symbol(ii)) + (labels==symbol(jj))*3);
        probij(ii,jj)=sum(trans==2)+sum(diff(find(labels==symbol(ii)))==1);
    end
end
% probij=probij./repmat(sum(probij,2),1,size(probij,2));
% probij(isnan(probij))=0;
% probSynbol=probSynbol/sum(probSynbol);
% T = probij.*repmat(probSynbol(:),1,size(probij,2)); %+ probij'.*repmat(probSynbol(:)',size(probij,1),1);

end


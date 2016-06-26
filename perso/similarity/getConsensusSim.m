function [  K ] = getConsensusSim( patternClustering,t,tresh)

%% get K

K=zeros(1,size(patternClustering,2)*(size(patternClustering,2)-1)/2);

for jj=1:size(patternClustering,1)
    K=K+abs(pdist(patternClustering(jj,:)','hamming')-1);
end
K(K<=tresh)=0;

K=K/max(K(:));
K=squareform(K);
K=K/max(K(:));
K=K+eye(size(K,1));

if t
    param.t=t;
    param.hoptime=0.1;
    K=gaussianSmoothing(K,param);
    K=K/max(K(:));
end

end


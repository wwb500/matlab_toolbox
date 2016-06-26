function [ T ] = getProbPatterns(T,shortPredictionNum,sens)

if sens ==1
    transMat=getTransitionMatrix(shortPredictionNum);
    transMat=transMat./repmat(sum(transMat,2),1,size(transMat,2));
    transMat(isnan(transMat))=0;
else
    transMat=getTransitionMatrix(shortPredictionNum);
    transMat=transMat./repmat(sum(transMat,2),1,size(transMat,2)).*transMat./repmat(sum(transMat,1),size(transMat,1),1);
    transMat(isnan(transMat))=0;
end

for jj=1:size(T,1)
    prob=1;
    for ll=1:length(T{jj,1})-1
        prob=prob*transMat(alpha2num(T{jj,1}(ll)),alpha2num((T{jj,1}(ll+1))));
    end
    T{jj,3}=prob;
end

end


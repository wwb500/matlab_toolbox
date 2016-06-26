function [ simMat2 ] = distanceWiseStructFeat( simMat )


simMat2=zeros(size(simMat));
nn=zeros(1,size(simMat,2));
rotCoef=zeros(1,size(simMat,2));

nn(1)=1;
rotCoef(1)=0;


for jj=2:size(simMat,2)-1
    
    [valPast,indPast]=max(simMat(1:jj-1,jj));
    [valFut,~]=max(simMat(jj+1:end,jj));
    
    if valFut==valPast
        nn(jj)=jj;
        rotCoef(jj)=-jj+1;
    else
        nn(jj)=indPast;
        rotCoef(jj)=-indPast+1;
    end
end

[~,indPast]=max(simMat(1:end-1,end));
nn(end)=indPast;
rotCoef(end)=-indPast+1;


for jj=1:length(rotCoef)
    simMat2(:,jj)=circshift(simMat(:,jj),rotCoef(jj)); 
end

end


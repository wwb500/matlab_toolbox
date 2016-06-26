function [ simMat ] = getDTWpreSeg(feature,onsets,offsets,distType,nei,minDistTime)

simMat=zeros(length(onsets),length(onsets));

switch distType
    case 'cosine'
        globalDistMat=simmx(feature,feature);
        globalDistMat=1-globalDistMat/max(globalDistMat(:));
    case 'euc'
        globalDistMat=squareform(pdist(feature'));
        globalDistMat=globalDistMat/max(globalDistMat(:));
    case 'kernel-rbf'
        globalDistMat=conKnl(conDist(feature,feature), 'nei', nei,'knl','g');
        globalDistMat=1-globalDistMat/max(globalDistMat(:));
end

%% DTW
for ii=1:length(onsets)
    
    for jj=1:length(onsets)
        
        beg1=onsets(ii);
        term1=offsets(ii);
        beg2=onsets(jj);
        term2=offsets(jj);
        
        if abs((term1-beg1)-(term2-beg2))>minDistTime
            
            simMat(ii,jj)=nan;
            
        else
            
            SM=globalDistMat(beg1:term1,beg2:term2);
            [p,q,C] = dpfast(SM);
            
%             figure(5)
%             subplot 321
%             imagesc(f1)
%             title(['onset: ' num2str(ii)])
%             subplot 322
%             imagesc(f2)
%             title(['onset: ' num2str(jj)])
%             subplot(3,2,[3 4])
%             imagesc(SM)
%             subplot(3,2,[5 6])
%             imagesc(C)
%             hold on; plot(q,p,'r'); hold off
%             title(['d=' num2str(C(size(C,1),size(C,2))) ', d_n=' num2str(C(size(C,1),size(C,2))/max(size(C,1),size(C,2)))])
%             disp('')
            
%             simMat(ii,jj)=C(size(C,1),size(C,2))/max(size(C,1),size(C,2));
            simMat(ii,jj)=C(size(C,1),size(C,2));
            
        end
    end
end

simMat(isnan(simMat))=max(max(simMat(~isnan(simMat))));

end


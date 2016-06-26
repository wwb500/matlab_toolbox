function [ newPred ] = resizedPrediction(oldPred,onsets,offsets,mode,lengthMax)

if isempty(lengthMax)
    newPred=zeros(size(oldPred,1),offsets(end));
else
    newPred=zeros(size(oldPred,1),lengthMax);
end

switch mode
    
    case 'point2seg'
        
        if size(oldPred,1)>1
            
            for ii=1:length(onsets)
                newPred(:,onsets(ii):offsets(ii))=repmat(oldPred(:,ii),1,length(onsets(ii):offsets(ii)));
            end
            
        else
            
            for ii=1:length(onsets)
                newPred(onsets(ii):offsets(ii))=oldPred(ii);
            end
            
        end
        
    case 'seg2seg'
        
        if size(oldPred,1)>1
            
            for ii=1:length(onsets{1})
                newPred(:,onsets{2}(ii):onsets{2}(ii)+length(onsets{1}(ii):offsets(ii))-1)=oldPred(:,onsets{1}(ii):offsets(ii));
            end
            
        else

            for ii=1:length(onsets{1})
                newPred(onsets{2}(ii):onsets{2}(ii)+length(onsets{1}(ii):offsets(ii))-1)=oldPred(onsets{1}(ii):offsets(ii));           
            end
            
        end
        
        
end
end


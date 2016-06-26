function [onsets,offsets,prediction] = cleanOnset(onsets,offsets,prediction,tresh)
 
if ~isempty(onsets)
    
    lengthSeg = offsets-onsets;
    ind2merge = find(lengthSeg < tresh );
    
    while ~isempty(ind2merge)
        if ind2merge(1)==1
            prediction(onsets(ind2merge(1)):offsets(ind2merge(1)))=prediction(onsets(ind2merge(1)+1));
        elseif ind2merge(1)==length(lengthSeg)
            prediction(onsets(ind2merge(1)):offsets(ind2merge(1)))=prediction(onsets(ind2merge(1)-1));
        elseif lengthSeg(ind2merge(1)-1) > lengthSeg(ind2merge(1)+1) 
            prediction(onsets(ind2merge(1)):offsets(ind2merge(1)))=prediction(onsets(ind2merge(1)-1));
        else
            prediction(onsets(ind2merge(1)):offsets(ind2merge(1)))=prediction(onsets(ind2merge(1)+1));
        end
        
        onsets=find(diff(prediction) ~= 0)+1;
        offsets=[onsets-1 length(prediction)];
        onsets=[1 onsets];
        
        lengthSeg = offsets-onsets;
        ind2merge = find(lengthSeg < tresh );
    end
    
end

end



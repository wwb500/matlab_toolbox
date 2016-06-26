function [prediction] = getOracleDetection(event,hoptime,gt_clustering,labels)

prediction.onsets=[];
prediction.offsets=[];
prediction.classNames={};

indObject=1;

[onsets,offsets]=getOnsetsOffsets(event);
onsets=onsets(event(onsets)==1);
offsets=offsets(event(offsets)==1);

for jj=1:length(onsets)
    
    gt_id=unique(gt_clustering(onsets(jj):offsets(jj)));
    
    for rr=1:length(gt_id)
        
        currentLabel=labels{gt_id(rr)};
        
        if strcmp(currentLabel,'bg')
            if length(gt_id)==1
                prediction.classNames{indObject}='alert';
                prediction.onsets(indObject)=onsets(jj)*hoptime;
                prediction.offsets(indObject)=offsets(jj)*hoptime;
                indObject=indObject+1;
            end
        else
            prediction.classNames{indObject}=currentLabel(1:strfind(currentLabel,' bg')-2);
            prediction.onsets(indObject)=onsets(jj)*hoptime;
            prediction.offsets(indObject)=offsets(jj)*hoptime;
            indObject=indObject+1;
        end
 
    end
    
end

end


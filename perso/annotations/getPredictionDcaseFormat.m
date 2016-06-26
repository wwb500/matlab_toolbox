function [ prediction ] = getPredictionDcaseFormat(predictionClus,labels,hoptime)

[onsets,offsets]=getOnsetsOffsets(predictionClus,[]);
prediction.frame.onsets=onsets(predictionClus(onsets)~=0)';
prediction.frame.offsets=offsets(predictionClus(offsets)~=0)';

prediction.time.onsets=prediction.frame.onsets*hoptime;
prediction.time.offsets=prediction.frame.offsets*hoptime;

prediction.frame.classes=cell(length(prediction.frame.onsets),1);

for jj=1:length(prediction.frame.onsets)
    
    prediction.frame.classes{jj}=labels{predictionClus(prediction.frame.onsets(jj))};
    
end

prediction.time.classes=prediction.frame.classes;
prediction.step=hoptime;
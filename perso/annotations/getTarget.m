function [target,onsets,offsets] = getTarget(time,labels,endTime,hoptime)

maxLength=floor(endTime/hoptime);

target = zeros(1,maxLength);

onsets=round(time/hoptime);onsets(onsets==0)=1;
onsets=onsets(:)';
offsets=[onsets(2:end)-1 maxLength];

for jj = 1:length(onsets)
    target(onsets(jj):offsets(jj)) = labels(jj);
end

end


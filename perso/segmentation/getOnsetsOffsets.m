function [onsets,offsets] = getOnsetsOffsets(prediction,selector)

onsets=find(diff(prediction) ~= 0)+1;
offsets=[onsets-1 length(prediction)];
onsets=[1 onsets];

if ~isempty(selector)
    onsets=onsets(prediction(onsets)==selector);
    offsets=offsets(prediction(offsets)==selector);
end

end


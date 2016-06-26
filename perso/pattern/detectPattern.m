function [ patterns] = detectPattern( clustering,treshDur)

%% get Patterns
shortPredictionNum=clustering.prediction(clustering.onsets);
shortPredictionAlpha=num2alpha(shortPredictionNum);

patterns = find_patterns(shortPredictionAlpha);

if ~isempty(patterns)
    patterns = getProbPatterns(patterns,shortPredictionNum,1);
    patterns = getDurationPatterns(patterns,clustering.onsets,clustering.offsets,shortPredictionAlpha);
    patterns = getNumPatterns(patterns);
end
if ~isempty(patterns)
    patterns = rmIdenticalPatterns(patterns);
end

if ~isempty(patterns)
    dur=cellfun(@sum,patterns(:,4));
    patterns=patterns(dur<=treshDur,:);
end

if ~isempty(patterns)
    patterns = rmMissMatchPatterns(patterns);
end

if ~isempty(patterns)
     patterns = rmPatternsInc( patterns,shortPredictionNum );
end


end


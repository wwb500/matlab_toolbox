function [intCQT,absCQT,Xcqt] = computeCQT(y,minFreq,maxFreq,bins,fs,q,atomHopFactor,hopTime)
% Settings for computing CQT for music signals (by E. Benetos)

% Compute CQT

Xcqt = cqt(y,minFreq,maxFreq,bins,fs,'q',q,'atomHopFactor',atomHopFactor,'thresh',0.0005,'win','hann');
absCQT = getCQT(Xcqt,'all','all');

% Crop CQT to useful time regions
emptyHops = Xcqt.intParams.firstcenter/Xcqt.intParams.atomHOP;
maxDrop = emptyHops*2^(Xcqt.octaveNr-1)-emptyHops;
droppedSamples = (maxDrop-1)*Xcqt.intParams.atomHOP + Xcqt.intParams.firstcenter;
outputTimeVec = (1:size(absCQT,2))*Xcqt.intParams.atomHOP-Xcqt.intParams.preZeros+droppedSamples;

lowerLim = find(outputTimeVec>0,1);
upperLim = find(outputTimeVec>length(y),1)-1;

intCQT_tmp = absCQT(:,lowerLim:upperLim);

dec=fs*hopTime/Xcqt.intParams.atomHOP;
onsets=round(1:dec:(size(intCQT_tmp,2))-dec);
offsets=[onsets(2:end)-1 size(intCQT_tmp,2)];

intCQT=cell2mat(arrayfun(@(x) mean(intCQT_tmp(:,onsets(x):offsets(x)),2),1:length(onsets),'UniformOutput',false));



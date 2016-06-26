function [onsets_min,offsets_min] = getOnsetsOffsets_min(onsets,offsets)

onsets_min=zeros(1,length(onsets));
offsets_min=zeros(1,length(offsets));

if onsets(1)==1
   onsets_min(1)=onsets(1);
   offsets_min(1)=offsets(1);
else
    onsets_min(1)=1;
    offsets_min(1)=offsets(1)-onsets(1)+1;
end

for tt=2:length(onsets)
    onsets_min(tt)=offsets_min(tt-1)+1;
    offsets_min(tt)=onsets_min(tt)+(offsets(tt)-onsets(tt));
end


end


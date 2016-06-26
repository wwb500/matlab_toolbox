function [ segmentId ] = status2id(segmentStatus,segmentOffsets)

segmentId=zeros(1,length(segmentStatus));

[onsets,offsets]=getOnsetsOffsets(segmentStatus);

for jj=1:length(onsets)
    segmentId(onsets(jj):offsets(jj))=jj;
end

segmentId=segmentId+segmentOffsets;

end


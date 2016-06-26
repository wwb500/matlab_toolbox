function [onsets,offsets] = getBlocks(featuresSize,blockSize,hoptime)

blockLength = round(blockSize/hoptime);
nbBlock=floor(featuresSize/blockLength);

for jj = 1:nbBlock
    onsets(jj)=(jj-1)*blockLength +1;
    offsets(jj) = onsets(jj)+blockLength-1;
end

if mod(featuresSize,blockLength) ~= 0
    onsets(end+1)=onsets(end)+1;
    offsets(end+1)=featuresSize;
end

end


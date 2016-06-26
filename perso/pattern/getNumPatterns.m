function [ patterns ] = getNumPatterns(patterns)

for jj=1:size(patterns,1)
    patterns{jj,5}=arrayfun(@(k) alpha2num(k),patterns{jj,1});
end

end


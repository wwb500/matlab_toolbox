function [ output_args ] = getFeatures(inputPath, outputPath)
%GETFEATURES Summary of this function goes here
%   Detailed explanation goes here

if ~exist('inputPath', 'var'), inputPath = '~/Dropbox/soundthings/papers/drumsEusipco2015/data/drumScenes/sound/'; end
if ~exist('outputPath', 'var'), outputPath = '~/Dropbox/soundthings/papers/drumsEusipco2015/data/drumScenes/features/'; end

addpath('../../thirdParty/rastamat');

files = dir([inputPath '*wav']);

for k=1:length(files)
    [s, fs] = audioread([inputPath files(k).name]);
    [mfcc, mel] = melfcc(s, fs);
    mel = log(mel);
    fid=fopen([outputPath files(k).name(1:end-4) '.mfcc'], 'w');
    fwrite(fid, [size(mfcc, 2) size(mfcc, 1) mfcc(:)'],'double');
    fclose(fid);
    fid=fopen([outputPath files(k).name(1:end-4) '.mel'], 'w');
    fwrite(fid, [size(mel, 2) size(mel, 1) mel(:)'],'double');
    fclose(fid);   
end

end


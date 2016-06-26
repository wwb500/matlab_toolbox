clear all


dataType={'environment/dcase/scenes_train/','environment/dcase/scenes_test/','music/beatles/'};

for rr=1:length(dataType)

inputPath=['~/Dropbox/databases/' dataType{rr} 'sound/'];
outputPath=['~/Dropbox/databases/' dataType{rr} ];

files=dir([inputPath '*wav']);

fid=fopen([outputPath 'sampleList.txt'],'w');

for ii=1:length(files)
    fprintf(fid,'%s\n',files(ii).name(1:end-4));
end

fclose(fid);


end
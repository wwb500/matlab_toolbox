function [prediction, log] = simpleClustering(clusteringType, matrixFileName, numClasses, outputFilePrefix, init, raw)

if ~exist('raw', 'var'), raw = 0; end
if ~exist('init', 'var'), init = 0; end

if length(init)>1
    fid = fopen([outputFilePrefix '.init'], 'w');
    fprintf(fid, '%d %d\n', length(init), numClasses);
    fprintf(fid, '%d ', init-min(init));
     fprintf(fid, '\n ');
    fclose(fid);
    initString =  [' -l ' outputFilePrefix '.init'];
else
    initString = [' -c ' num2str(numClasses) ];
end

appendRaw = ' 2> /dev/null';
% appendRaw = ' ';
if raw
    appendRaw = [' -r ' appendRaw];
end

command = [fileparts(mfilename('fullpath'))  '/' clusteringType '  -m ' matrixFileName initString  ' -o ' outputFilePrefix appendRaw ];

system(command);

fid = fopen([outputFilePrefix '.labels']);
prediction = textscan(fid, '%f',  'HeaderLines',1);
fclose(fid);
prediction = prediction{1};

fid = fopen([outputFilePrefix '.csv']);
runLog = textscan(fid, '%f,%f, %f,%f',  'HeaderLines',2);
fclose(fid);

log.iterations = runLog{1}(end);
log.moved = runLog{2}(end);
log.time =  runLog{3}(end);
log.iterationMoved = runLog{2}(1:end-1);
log.iterationCriterion = runLog{3}(1:end-1);
log.iterationTime = runLog{4}(1:end-1);


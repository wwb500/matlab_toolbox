function [signal,eventLoc,bgLoc] = getSamplesInfos(annotator,classes,trainSetPath,sr_test)

% Collating all recordings of a specific Class from Training Set

% Path to Data
datapath = [trainSetPath 'singlesounds_stereo/'];
annotpath = [trainSetPath 'annotation_' annotator '/'];

% List of all the Audio files:
AudioList = dir([datapath '/*wav']);

indSamples=find(cellfun(@(x) ~isempty(x),strfind({AudioList.name},classes)));

if length(indSamples)~=20
    error('not enough samples in train set')
end

% Initialise Audio stream
signal = cell(length(indSamples),1);
eventLoc = cell(length(indSamples),1);
bgLoc = cell(length(indSamples),1);

% Take al instances
for k = 1 : length(indSamples)
    
    % Find path to annotation
    AnnotFileName = [AudioList(indSamples(k)).name(1:end-4) '_' annotator '.txt'];
    AudioFileName = [AudioList(indSamples(k)).name];
    
    % Read The annotation from the text file:
    % beg: beggining sample / fin: ending sample
    if ~strcmp(annotator,'null')
        fid=fopen([annotpath  AnnotFileName]);
        res = textscan(fid,'%f %f');
        fclose(fid);
        
        beg=res{1};
        fin=res{2};
    end
    
    % Read the audio for the Event, making sure no overflow occurs
    [x,sr] = audioread([datapath AudioFileName]);
    
    if sr ~= sr_test
        error('The sampling frequency is not the sam for all recordings!');
    end
    
    xnow = (sum(x,2)/2)';
    eventnow=zeros(1,length(xnow));
    bgnow=zeros(1,length(xnow));
    
    % Cut sample according to annotator
    if ~strcmp(annotator,'null')
        eventnow(max(round(beg*sr),1):min(round(fin*sr),length(xnow)))=1;
        bgnow([(1:max(round(beg*sr),1)) (min(round(fin*sr),length(xnow)):end)])=1;
    else
        eventnow(:)=1;
    end
    
    signal{k} = xnow;
    eventLoc{k} = logical(eventnow);
    bgLoc{k} = logical(bgnow);
end





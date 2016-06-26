function [] = training_variant(ANOT_FLAG, save_flag)
% Training Algorithm (Variant) for the Event Detection Task
% Learn one basis per recording for each a Class from Training Set
% Instead of Collating all recordings of a specific Class from Training Set
%


% PARAMETERS:
%
% numBases 
%       (fixed) to 20individual: 1 basis per recorded training sample
%
% ANOT_FLAG 
%       Choose Annotation: 1 or 2
% save_flag
%       Flag for saving the output Dictionary
%       1: ON, 0: OFF

% PARAMETER DEFAULTS:
%
if ~exist('save_flag','var') || isempty(save_flag), save_flag = 1; end
if ~exist('ANOT_FLAG','var') || isempty(ANOT_FLAG), ANOT_FLAG = 1; end

% INITIALISATIONS

if isempty(find([1, 2] == ANOT_FLAG))
error('ANNOT_FLAG can be either 1 or 2 (depending on chosen annotation')
end

%Annotations
Annotators = {'_bdm', '_sid'};

% addpath('Training_Set\');
% datapath = './singlesounds_stereo';
datapath = 'Training_Set/singlesounds_stereo';
anotpath = ['Training_Set/Annotation' num2str(ANOT_FLAG) '/'];

% List of all the Audio files:
AudioList = dir([datapath '/*wav']);

% Get the sampling frequency from the 1st recorded sample
[~,Fs] = wavread([datapath '/' AudioList(1).name]);

Classes = {'alert','clearthroat','cough','doorslam','drawer','keyboard','keyes',...
           'knock','laughter','mouse','pageturn','pendrop','phone','printer',...
           'speech','switch'};
       
% LEARNING
% Learn Bases for every Class

% Initialise Dictionary
Dict = [];


% Loading signals for each of the 16 classes
for i = 1 : 16
    
    % Take all 20 train instances for each class
    for k = 1 : 20
% Find path to annotation
    AnotPath = [AudioList((i-1)*20+k).name(1:end-4) Annotators{ANOT_FLAG} '.txt'];
    AudioPath = [AudioList((i-1)*20+k).name];
    % Read The annotation from the text file:    
    % beg: beggining sample
    % fin: ending sample
    [beg,fin] = textread(['./Training_Set/Annotation' num2str(ANOT_FLAG) '/' AnotPath],'%f%f');
    % Read the audio for the Event, making sure no overflow occurs
    [x] = wavread([datapath '/' AudioPath]);
    Max_sample = length(x);
    [xnow,fs] = wavread([datapath '/' AudioPath] ,[max(round(beg*Fs),1) min(round(fin*Fs),Max_sample)]);
    xnow = sum(xnow,2)/2;
    if fs ~= Fs
        error('The sampling frequrncy is not the sam for all recordings!');
    end
    % Normalize individual segments to avoid over-energetic transients
    % in the audio streams per class.
    xnow = xnow./std(xnow);
    [i k]
    [intCQT] = computeCQT(xnow);
    cqt_rep = intCQT(:,round(1:7.1128:size(intCQT,2)));
    
    [W,H,errs,vout] = nmf_beta(cqt_rep,1,'beta',1);
    Dict = [Dict W];
    end
end
% CLear Uneeded variables
clear x xnow;


%eval(sprintf('Dict_%d=Dict;',numBases));
if save_flag == 1
    savefile = ['Dictionaries' Annotators{ANOT_FLAG} '/Dict20individual.mat'];
    save(savefile,'Dict');
end

% Clear Unneeded variables
clear xin intCQT cqt_rep;


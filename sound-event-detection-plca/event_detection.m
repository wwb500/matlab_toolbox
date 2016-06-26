function [onset,offset,classNames] = event_detection(filename,iter,S,sz,su)
% e.g. [onset,offset,classNames] = event_detection('office_snr0_high.wav',30,20,0.95,1.05);
%
% Detection of overlapping acoustic events using a temporally-constrained probabilistic model
%
% Inputs:
%  filename filename for .wav file
%  iter     number of iterations (e.g. 30)
%  S        number of exemplars per event class (set to 20 from the training dataset)
%  sz       sparsity parameter for event activation (e.g. 0.9-1.3)
%  su       sparsity parameter for exemplar contribution (e.g. 0.9-1.3)
%
% Outputs:
%  onset:      vector of onset times for each detected event
%  offset:     vector of offset times for each detected event
%  classNames: cell vector of event classes for each detected event 
%
% Emmanouil Benetos 2015

% Load spectral templates and initialize
load('shiftedW_highfreqs');
W = permute(shiftedW,[4 5 2 1 3]);
W = permute(W,[1 3 2 4 5]);
W = W(:,1:S,:,:,:);


% Compute ERB spectrogram
X = computeERB(filename)'; % 23.22ms step


% Emphasize high freqs and remove low frequency bins
f = X(:,21:end)';
f = f .* repmat( linspace( 1, 15, size( f, 1))', 1, size( f, 2));
X =f';


% Remove background noise from input
p1 = prctile(sum(X'),10);
p2 = prctile(sum(X'),30);
silentFrames = find(sum(X')>p1 & sum(X')<p2);
silentTemplate = mean(X(silentFrames,:));
noiseLevel = repmat(silentTemplate,[size(X,1) 1]);
Y = X - noiseLevel;


% Perform efficient 5-D HMM-constrained PLCA
[w,h,z,u,g,xa] = plca_5d_fast_hmm( Y', 16, S, 1, 3, iter, 1.0, sz, su, W, [], [], [], [], 0);


% Postprocessing
eventRoll = z';

[B,IX] =sort(eventRoll,2,'descend');  % Max polyphony
tempEventRoll = zeros(size(eventRoll,1),16);
for j=1:size(eventRoll,1) for k=1:5 tempEventRoll(j,IX(j,k)) = B(j,k); end; end;
eventRoll = tempEventRoll;

eventRoll = medfilt1(eventRoll,9); % median filtering

expandedEventRoll = zeros(round(2.322*size(eventRoll,1)),16); % interpolate to 10ms step
for j=1:round(2.322*size(eventRoll,1))
    expandedEventRoll(j,:) = eventRoll(floor((j-1)/2.322)+1,:);
end;


% Thresholding (settings from OS dev)
th = [3.79 0.43 0.27 3.91 3.41 0.23 0.01 3.99 2.85 0.39 3.89 3.53 0.17 0.11 1.35 3.99];
path = [];
for k=1:16
    path(:,k) = (expandedEventRoll(:,k) > th(k));
end


% Minimum duration pruning (60ms) & convert to list of detected events
[onset,offset,classNames] = convertEventRolltoEventList(path,0.06,0.06);
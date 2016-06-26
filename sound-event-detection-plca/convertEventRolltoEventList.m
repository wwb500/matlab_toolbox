function [onset,offset,classNames] = convertEventRolltoEventList(eventRoll,minDur,shift)


% Initialize
onset = []; offset = []; classNames = [];
eventID = {'alert','clearthroat','cough','doorslam','drawer','keyboard','keys',...
    'knock','laughter','mouse','pageturn','pendrop','phone','printer','speech','switch'};


% Find note events on expandedEventRoll
auxEventRoll = diff([zeros(1,16); eventRoll; zeros(1,16);],1); k=0;

for i=1:16
    onsets = find(auxEventRoll(:,i)==1);
    offsets = find(auxEventRoll(:,i)==-1);
    for j=1:length(onsets)
        if((offsets(j)/100-0.01) - (onsets(j)/100) > minDur) % Minimum duration pruning!
            k=k+1;
            onset(k) = onsets(j)/100-shift;
            offset(k) = offsets(j)/100-0.01;
            classNames{k} = eventID{i};
        end;
    end;
end;
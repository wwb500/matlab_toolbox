function [eventRoll] = convertEventListToEventRoll(onset,offset,classNames,classes)


% Initialize
eventRoll = zeros(ceil(offset(length(offset))*100),length(classes));

% Fill-in eventRoll
for i=1:length(onset)
    
    eventRoll(floor(onset(i)*100):ceil(offset(i)*100),strcmp(classNames{i}, classes)) = 1;
    
end;
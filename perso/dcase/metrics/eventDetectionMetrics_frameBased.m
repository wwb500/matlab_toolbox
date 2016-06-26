function [results,eventRoll,eventRollGT] = eventDetectionMetrics_frameBased(prediction,target,classes)

% Convert event list into frame-based representation (10msec resolution)
[eventRoll] = convertEventListToEventRoll(prediction.onsets,prediction.offsets,prediction.classes,classes);
[eventRollGT] = convertEventListToEventRoll(target.onsets,target.offsets,target.classes,classes);


% Fix durations of eventRolls
if (size(eventRollGT,1) > size(eventRoll,1)) eventRoll = [eventRoll; zeros(size(eventRollGT,1)-size(eventRoll,1),16)]; end;
if (size(eventRoll,1) > size(eventRollGT,1)) eventRollGT = [eventRollGT; zeros(size(eventRoll,1)-size(eventRollGT,1),16)]; end;


% Compute frame-based metrics
Nref = sum(sum(eventRollGT));
Ntot = sum(sum(eventRoll));
Ntp = sum(sum(eventRoll+eventRollGT > 1));
Nfp = sum(sum(eventRoll-eventRollGT > 0));
Nfn = sum(sum(eventRollGT-eventRoll > 0));
Nsubs = min(Nfp,Nfn);


results.Rec = Ntp/(Nref+eps);
results.Pre = Ntp/(Ntot+eps);
results.F = 2*((results.Pre*results.Rec)/(results.Pre+results.Rec+eps));
results.AEER = (Nfn+Nfp+Nsubs)/(Nref+eps);
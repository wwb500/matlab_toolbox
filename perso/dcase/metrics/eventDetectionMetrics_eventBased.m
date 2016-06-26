function [results] = eventDetectionMetrics_eventBased(prediction,target)

% Total number of detected and reference events
Ntot = length(prediction.onsets);
Nref = length(target.onsets);


% Number of correctly transcribed events, onsets within a +/-100 ms range
Ncorr = 0;
NcorrOff = 0;
for j=1:length(target.onsets)
    for i=1:length(prediction.onsets)
        
        if( strcmp(prediction.classes{i},target.classes{j}) && (abs(target.onsets(j)-prediction.onsets(i))<=0.1) )
            Ncorr = Ncorr+1; 
            
            % If offsets within a +/-100 ms range or within 50% of ground-truth event's duration
            if abs(target.offsets(j) - prediction.offsets(i)) <= max(0.1, 0.5 * (target.offsets(j) - target.onsets(j)))
                NcorrOff = NcorrOff +1;
            end;
            
            break; % In order to not evaluate duplicates
            
        end;
    end;
    
end;


% Compute onsets-only event-based metrics
Nfp = Ntot-Ncorr;
Nfn = Nref-Ncorr;
Nsubs = min(Nfp,Nfn);
results.Rec = Ncorr/(Nref+eps);
results.Pre = Ncorr/(Ntot+eps);
results.F = 2*((results.Pre*results.Rec)/(results.Pre+results.Rec+eps));
results.AEER= (Nfn+Nfp+Nsubs)/(Nref+eps);


% Compute onsets-offsets event-based metrics
NfpOff = Ntot-NcorrOff;
NfnOff = Nref-NcorrOff;
NsubsOff = min(NfpOff,NfnOff);
results.RecOff = NcorrOff/(Nref+eps);
results.PreOff = NcorrOff/(Ntot+eps);
results.FOff = 2*((results.PreOff*results.RecOff)/(results.PreOff+results.RecOff+eps));
results.AEEROff= (NfnOff+NfpOff+NsubsOff)/(Nref+eps);
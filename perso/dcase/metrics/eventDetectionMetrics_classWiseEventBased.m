function [results] = eventDetectionMetrics_classWiseEventBased(prediction,target,classes)

% Total number of detected and reference events per class
Ntot = zeros(length(classes),1);
for i=1:length(prediction.onsets)
    pos = find(strcmp(prediction.classes{i}, classes));
    Ntot(pos) = Ntot(pos)+1;
end;

Nref = zeros(length(classes),1);
for i=1:length(target.onsets)
    pos = find(strcmp(target.classes{i}, classes));
    Nref(pos) = Nref(pos)+1;
end;

I = find(Nref>0); % index for classes present in ground-truth

% Number of correctly transcribed events per class, onset within a +/-100 ms range
Ncorr = zeros(length(classes),1);
NcorrOff = zeros(length(classes),1);
for j=1:length(target.onsets)
    for i=1:length(prediction.onsets)
        
        if( strcmp(prediction.classes{i},target.classes{j}) && (abs(target.onsets(j)-prediction.onsets(i))<=0.1) )
            pos = find(strcmp(prediction.classes{i}, classes));
            Ncorr(pos) = Ncorr(pos)+1;
            
            % If offset within a +/-100 ms range or within 50% of ground-truth event's duration
            if abs(target.offsets(j) - prediction.offsets(i)) <= max(0.1, 0.5 * (target.offsets(j) - target.onsets(j)))
                pos = find(strcmp(prediction.classes{i}, classes));
                NcorrOff(pos) = NcorrOff(pos) +1;
            end;
            
            break; % In order to not evaluate duplicates
            
        end;
    end;
end;


% Compute onset-only class-wise event-based metrics
Nfp = Ntot-Ncorr;
Nfn = Nref-Ncorr;
Nsubs = min(Nfp,Nfn);
tempRec = Ncorr(I)./(Nref(I)+eps);
tempPre = Ncorr(I)./(Ntot(I)+eps);
results.Rec = mean(tempRec);
results.Pre = mean(tempPre);
tempF =  2*((tempPre.*tempRec)./(tempPre+tempRec+eps));
results.F = mean(tempF);
tempAEER = (Nfn(I)+Nfp(I)+Nsubs(I))./(Nref(I)+eps);
results.AEER = mean(tempAEER);


% Compute onset-offset class-wise event-based metrics
NfpOff = Ntot-NcorrOff;
NfnOff = Nref-NcorrOff;
NsubsOff = min(NfpOff,NfnOff);
tempRecOff = NcorrOff(I)./(Nref(I)+eps);
tempPreOff = NcorrOff(I)./(Ntot(I)+eps);
results.RecOff = mean(tempRecOff);
results.PreOff = mean(tempPreOff);
tempFOff =  2*((tempPreOff.*tempRecOff)./(tempPreOff+tempRecOff+eps));
results.FOff = mean(tempFOff);
tempAEEROff = (NfnOff(I)+NfpOff(I)+NsubsOff(I))./(Nref(I)+eps);
results.AEEROff = mean(tempAEEROff);
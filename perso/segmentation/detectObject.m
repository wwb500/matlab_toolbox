function [onsets,offsets,nvnorm] = detectObject(K,param,normt,dist)

colormap('default');

%% novelty Curve
switch dist
    case 'euc'
        nv = sqrt(sum(diff(K,1,2).^2,1));
        
    case 'hamming'
        nv=sum(diff(K,1,2)~=0,1)/size(K,1);
end

nvnorm=nv;

if normt
    win=round(normt/param.hoptime);
    nvTmp=[zeros(1,win) nv zeros(1,win)];
    for jj=1:length(nv)
        nvnorm(jj)=nv(jj)/max(nvTmp(jj:jj+win*2));
    end
end
[peaks,onsets]=findpeaks(nvnorm);
% onsets(peaks<param.tresh)=[];
% peaks(peaks<param.tresh)=[];

%% get onsets
if onsets(1)~=1
    onsets=[1 onsets+1];
end

nv=[max(nv) nv];
nvnorm=[max(nvnorm) nvnorm];

offsets=[onsets(2:end)-1 size(K,2)];
disp('')

end


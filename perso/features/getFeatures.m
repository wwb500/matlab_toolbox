function [features] = getFeatures(signal,features2use,setting,save_mir)

mirverbose(0);

audio = miraudio(signal(:),setting.sr);
frame = mirframe(audio,'length',setting.wintime,'s','hop',setting.hoptime,'s');
features.size=size(mirgetdata(frame),2);

switch features2use
    case {'RQAchroma','RQAlogmel','RQAmfcc'}
        frame = mirframe(audio,'length',setting.hoptime/setting.rqa.nbPoints*2,'s','hop',setting.hoptime/setting.rqa.nbPoints,'s');
        mir.mel=mirspectrum(frame,'mel','min',setting.minFreq,'max',setting.maxFreq,'bands',setting.melBand);
    case {'chroma','mel','logmel','mfcc','mfccD1','mfccD2','stats'}
        mir.mel=mirspectrum(frame,'mel','min',setting.minFreq,'max',setting.maxFreq,'bands',setting.melBand);
    case 'cqt'
        mir.cqt=mirspectrum(frame','min',setting.minFreq,'max',setting.maxFreq,'ConstantQ',setting.cqtNbBins);
end

switch features2use
    case 'cqt'
        
        features.cqt=mirgetdata(mir.cqt);
        
    case {'scattering','scatteringJoint'}
        
        f=mirgetdata(frame);
        eval(['features.' features2use '=[];']);
        
        for jj=1:size(f,2)
            [S,~,~] = sc_propagate(setting.scat.w.*f(1:setting.scat.N,jj), setting.scat.archs);
            scat =  [format_layer(S{1+1}, 1), format_layer(S{1+2}, 1)].';
            eval(['features.' features2use '(:,jj)=scat(:);']);
        end
        
    case {'chroma','RQAchroma'}
        
        mir.chroma=mirchromagram(frame','min',setting.minFreq,'max',setting.maxFreq);
        
        features.chroma=mirgetdata(mir.chroma);
        
    case {'mel','logmel','RQAlogmel'}
        
        switch features2use
            case {'logmel','RQAlogmel'}
                features.logmel=log((squeeze(mirgetdata(mir.mel)))');
            case 'mel'
                features.mel=(squeeze(mirgetdata(mir.mel)))';
        end
        
    case {'mfcc','mfccD1','mfccD2','RQAmfcc'}
        
        if setting.mfccCoef0==1
            mfccRank0=1;
        else
            mfccRank0=2;
        end
        
        switch features2use
            case {'mfcc','RQAmfcc'} % mfcc
                
                mir.mfcc_d0=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',0,'radius',setting.mfccDeltaRadius);
                
                features.mfcc=mirgetdata(mir.mfcc_d0);
                
            case 'mfccD1' % mfcc delta 1
                
                mir.mfcc_d0=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',0,'radius',setting.mfccDeltaRadius);
                mir.mfcc_d1=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',1,'radius',setting.mfccDeltaRadius);
                
                mfcc_d0=mirgetdata(mir.mfcc_d0);
                mfcc_d1=mirgetdata(mir.mfcc_d1);
                
                % add coef according to mir radius
                mfcc_d1=[mfcc_d1(:,1:setting.mfccDeltaRadius) mfcc_d1 mfcc_d1(:,end-setting.mfccDeltaRadius+1:end)];
                
                features.mfccD1=[mfcc_d0;mfcc_d1];
                
            case 'mfccD2'
                
                mir.mfcc_d0=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',0,'radius',setting.mfccDeltaRadius);
                mir.mfcc_d1=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',1,'radius',setting.mfccDeltaRadius);
                mir.mfcc_d2=mirmfcc(mir.mel,'rank',mfccRank0:setting.mfccRank,'Delta',2,'radius',setting.mfccDeltaRadius);
                
                mfcc_d0=mirgetdata(mir.mfcc_d0);
                mfcc_d1=mirgetdata(mir.mfcc_d1);
                mfcc_d2=mirgetdata(mir.mfcc_d2);
                
                % add coef according to mir radius
                mfcc_d1=[mfcc_d1(:,1:setting.mfccDeltaRadius) mfcc_d1 mfcc_d1(:,end-setting.mfccDeltaRadius+1:end)];
                mfcc_d2=[mfcc_d2(:,1:setting.mfccDeltaRadius*2) mfcc_d2 mfcc_d2(:,end-setting.mfccDeltaRadius*2+1:end)];
                
                
                features.mfccD2=[mfcc_d0;mfcc_d1;mfcc_d2];
                
        end
        
    case {'stats'}
        
        mir.stats(1,:)=mircentroid(mir.mel);
        mir.stats(2,:)=mirspread(mir.mel);
        mir.stats(3,:)=mirkurtosis(mir.mel);
        mir.stats(4,:)=mirflatness(mir.mel);
        mir.stats(5,:)=mirentropy(mir.mel);
        
        stats(1,:)=mirgetdata(mir.stats(1,:));
        stats(2,:)=mirgetdata(mir.stats(2,:));
        stats(3,:)=mirgetdata(mir.stats(3,:));
        stats(4,:)=mirgetdata(mir.stats(4,:));
        stats(5,:)=mirgetdata(mir.stats(5,:));
        
        stats(isnan(stats))=0;
        
        features.stats=stats;
        
    case {'gbfb','sgbfb','RQAgbfb'}
        
        % logmel gbfb toolbox
        % logmel=log_mel_spectrogram(signal, setting.sr, setting.hoptime*1000,setting.wintime*1000, [setting.minFreq setting.maxFreq], setting.melBand);
        
        % logmel mir toolbox
        logmel=log((squeeze(mirgetdata(mir.mel)))');
        
        switch features2use
            case {'RQAgbfb','gbfb'}
                features.gbfb=gbfb(logmel,[pi/2 pi/2],[69 40],[3.5 3.5],[0.3 0.2]);
            case 'sgbfb'
                features.sgbfb=sgbfb(logmel,[pi/2 pi/2],[69 40],[3.5 3.5],[0.3 0.2]);
        end
        
end

%% RQA

switch features2use
    case 'RQAchroma'
        [features.RQAchroma] = getRQA(features.chroma,features.size,setting.rqa);
    case 'RQAlogmel'
        [features.RQAlogmel] = getRQA(features.logmel,features.size,setting.rqa);
    case 'RQAmfcc'
        [features.RQAmfcc] = getRQA(features.mfcc,features.size,setting.rqa);
    case 'RQAgbfb'
        [features.RQAgbfb] = getRQA(features.gbfb,features.size,setting.rqa);
end

%% save mir

if save_mir==1
    features.mir=mir;
end

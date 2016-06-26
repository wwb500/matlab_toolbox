function [] = training(samplesInfos,features,numBases,annotator,savePath)
% Training Algorithm for the Event Detection Task
% LEARNING
% Learn Bases for every Class

dict = [];
hoptime = .1; wintime = hoptime*2;

for ii = 1 : length(samplesInfos.classes)
    
    disp(['     class: ' samplesInfos.classes{ii} '  ' num2str(ii) '/' num2str(size(samplesInfos.xin,1))])
      
    switch features
        
        case 'mfccNorm'
            
            [ftrs,~,~] = melfcc(samplesInfos.xin{ii},samplesInfos.Fs, 'wintime',wintime,'hoptime',hoptime,'nbands',40,'minfreq',0,'maxfreq',12000,'preemph',0,'useenergy',1,'lifterexp',0);
            ftrs=ftrs(2:end,:);
            ftrs = normalizeFeature(ftrs,2, 10^-6);
            
        case 'mfcc'
            
            [ftrs,~,~] = melfcc(samplesInfos.xin{ii},samplesInfos.Fs, 'wintime',wintime,'hoptime',hoptime,'nbands',40,'minfreq',0,'maxfreq',12000,'preemph',0,'useenergy',1,'lifterexp',0);
            ftrs=ftrs(2:end,:);
            
        case 'mel'
            
            [~,ftrs,~] = melfcc(samplesInfos.xin{ii},samplesInfos.Fs, 'wintime',wintime,'hoptime',hoptime,'nbands',40,'minfreq',0,'maxfreq',12000,'preemph',0,'useenergy',1,'lifterexp',0);
            ftrs=log(ftrs);
        case 'melNorm'
            
            [~,ftrs,~] = melfcc(samplesInfos.xin{ii},samplesInfos.Fs, 'wintime',wintime,'hoptime',hoptime,'nbands',40,'minfreq',0,'maxfreq',12000,'preemph',0,'useenergy',1,'lifterexp',0);
            ftrs=log(ftrs);
            ftrs = normalizeFeature(ftrs,2, 10^-6);
            
    end
    
    ftrs=ftrs-min(ftrs(:));
    ftrs=ftrs/max(ftrs(:));
    
    [W,~,~,~] = nmf_beta(ftrs,numBases,'beta',1);
    dict = [dict W];
    
end

if ~isempty(savePath)
    classes=samplesInfos.classes;
    savefile = [savePath 'dict_' num2str(numBases) '_' features  '_' annotator(2:end) '.mat'];
    save(savefile,'dict','classes');
end



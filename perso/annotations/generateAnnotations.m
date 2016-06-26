clear all

datasetPath='~/Dropbox/databases/environment/dcase/QMUL_dev-test/events_OL_test/';
soundIndex=1:11;
annotators={'bdm','sid'};
annotation.step=0.01;

%% select sound

fileId = fopen([datasetPath 'sampleList.txt']);
sounds=textscan(fileId,'%s');sounds=sounds{1};
fclose(fileId);

%% generate clustering like annotations

for jj=soundIndex
    
    annotation.soundName=sounds{jj};
    annotation.soundIndex=jj;
    
    %% load sound
    
    [y,sr]=audioread([datasetPath '/sound/' annotation.soundName '.wav']);
    if min(size(y)) > 1
        y=mean(y,2);
    end
    y=y/max(abs(y));
    annotation.soundDuration = length(y)/sr;
    
    %% load annotation
    
    for pp=1:length(annotators)
        
        annotation.annotator=annotators{pp};
        
        fileId = fopen([datasetPath '/annotation/' annotation.soundName '_' annotation.annotator '.txt']);
        a=textscan(fileId,'%f %f %s');starts=a{1};ends=a{2};classes=a{3};
        fclose(fileId);
        
        annotation.labels=unique(classes);
        
        %% get class per step
        
        annotation.nbWin=ceil(annotation.soundDuration/annotation.step);
        annotation.class_mat=zeros(length(annotation.labels),annotation.nbWin);
        
        for rr=1:length(classes)
            indClass=find(strcmp(classes{rr},annotation.labels));
            inds=round(starts(rr)/annotation.step);
            inde=round(ends(rr)/annotation.step);
            
            annotation.class_mat(indClass,inds:inde)=1;
        end
        
        annotation.labels={annotation.labels{:} 'bg'};
        annotation.class_mat=[annotation.class_mat; ones(1,size(annotation.class_mat,2))];
        
        save([datasetPath '/annotation/' annotation.soundName '_' annotation.annotator '.mat'],'annotation')
        disp('')
    end
end
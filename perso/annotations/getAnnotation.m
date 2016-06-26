function [target] = getAnnotation(dataset,annotator,sound,step,nbWin,classes,mode)

%% load file
fileId = fopen([dataset 'annotation/' sound '_' annotator '.txt']);
annotation=textscan(fileId,'%f %f %s');
fclose(fileId);

target.step=step;

target.time.onsets=annotation{1};
target.time.offsets=annotation{2};
target.time.classes=annotation{3};

%% generate ground truth

switch mode
    case 'mono'
        
        target.frame.classes=annotation{3};
        target.frame.onsets=max(1,round(annotation{1}/step));
        target.frame.offsets=min(nbWin,round(annotation{2}/step));
        
        target.clus=zeros(1,nbWin);
        for jj=1:length(target.frame.onsets)
            class=find(strcmp(target.frame.classes{jj},classes));
            if isempty(class)
                error('wrong label in annotation')
            else
                target.clus(target.frame.onsets(jj):target.frame.offsets(jj))=class;
            end
        end
        
    case 'ploy'
        error('not done')
   
end

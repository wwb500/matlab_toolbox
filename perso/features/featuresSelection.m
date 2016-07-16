function [ features ,setting] = featuresSelection(features,param)

if strcmp(param.type,'null')
    
    setting.type='null';
    
elseif ~isempty(strfind(param.type,'lda'))
    
    setting.type='lda';
    
    if isfield(param,'LTrans')
        
        % project
        features = (features'*param.LTrans)';
    else
        
        setting.nbClass=length(unique(param.classes));
        
        sp=strsplit(param.type,'_');
        setting.thresh=str2double(sp{2});
        
        setting.L = fitcdiscr(features',param.classes(:),'discrimType','pseudoLinear');
        setting.err = loss(setting.L,features',param.classes');
        
        
        % sort by eigenvalues
        % http://fr.mathworks.com/matlabcentral/answers/166385-lda-transformation-matrix-for-discriminative-feature-extraction
        % http://sebastianraschka.com/Articles/2014_python_lda.html#sections
        [LTrans,Lambda] = eig(setting.L.BetweenSigma,setting.L.Sigma,'chol');
        [Lambda,sorted] = sort(diag(Lambda),'descend');
        LTrans = LTrans(:,sorted);
        
        % normalize to get explained variance
        if setting.thresh==100
            setting.eig2keep=setting.nbClass-1;
        else
            Lambda=Lambda/sum(Lambda)*100;
            setting.eig2keep=min(find(cumsum(Lambda)>=setting.thresh,1,'first'),setting.nbClass-1);
        end
        
        setting.LTrans=LTrans(:,1:setting.eig2keep);
        
        % project
        features = (features'*setting.LTrans)';
        
    end
    
elseif ~isempty(strfind(param.type,'pca'))
    
    setting.type='pca';
    
    if isfield(param,'coeff')
        
        features=features-repmat(mean(features,2),1,size(features,2));
        features= param.coeff'*features;
        features=features(1:param.pc2use,:);
        
    else
        
        
        setting.threshVar=str2double(param.type(strfind(param.type,'_')+1:end));
        
        warning off
        [setting.coeff,score,~,~,setting.explained,~] = pca(features');
        warning on
        
        setting.pc2use=max(find(cumsum(setting.explained)>=setting.threshVar,1,'first'),2);
        
        features=score(:,1:setting.pc2use)';
        
    end
    
end

end


function [A,params] = histSimilarity(sceneFeatures,params,gd)

switch params.histDist
    
    case 'quadratic_form_distance'
        
        D=zeros(size(sceneFeatures,2),size(sceneFeatures,2));
        for aa=1:size(sceneFeatures,2)
            for bb=aa:size(sceneFeatures,2)
                D(aa,bb) = quadratic_form_distance(sceneFeatures(:,aa)',sceneFeatures(:,bb)',gd);
                D(bb,aa)=D(aa,bb);
            end
        end
        
    case 'emd'
        
        D=zeros(size(sceneFeatures,2),size(sceneFeatures,2));
        
        if strcmp(params.gdType,'sim')
            f=1-gd;
        else
            f=gd;
        end
        
        flowType=3;
        extra_mass_penalty= -1;
        
        for aa=1:size(sceneFeatures,2)
            for bb=aa+1:size(sceneFeatures,2)
                
                W1=sceneFeatures(:,aa);
                W2=sceneFeatures(:,bb);
                
                F=f(W1~=0,W2~=0);
                
                W1(W1==0)=[];
                W2(W2==0)=[];
                
                if length(W1)==length(W2)
                    
                    % Rubner version (matlab)
                    % [~,C] = emd(F,[],W1,W2,[]);
                    
                    % Rubner version (mex)
                    % [D(aa,bb),~]=emd_mex(W1',W2',F);
                    
                    % assume metric ground distance
                    % D(aa,bb)= emd_hat_gd_metric_mex(W1,W2,F,extra_mass_penalty);
                    % [D(aa,bb),~]= emd_hat_gd_metric_mex(W1,W2,F,extra_mass_penalty,flowType);
                    
                    % just assume non symetric ground distance
                    D(aa,bb)= emd_hat_mex(W1,W2,F,extra_mass_penalty);
                    % [D(aa,bb),~]= emd_hat_mex(W1,W2,F,extra_mass_penalty,flowType);
                    
                else % non equal size histograms
                    
                    extra_mass_penalty=0;
                    [D(aa,bb),~]= emd_hat_mex_nes(W1,W2,F,extra_mass_penalty,flowType);
                    
                end
                
                D(bb,aa)=D(aa,bb);
            end
        end
        
    case 'emd_sg'
        
        D=zeros(size(sceneFeatures,2),size(sceneFeatures,2));
        if strcmp(params.gdType,'sim')
            f=1-gd;
        else
            f=gd;
        end
        flowType=3;
        extra_mass_penalty= -1;
        
        for aa=1:size(sceneFeatures,2)
            for bb=aa:size(sceneFeatures,2)
                
                W1=sceneFeatures(:,aa);
                W2=sceneFeatures(:,bb);
                D(aa,bb)= emd_hat_mex(W1,W2,f,extra_mass_penalty);
                D(bb,aa)=D(aa,bb);
            end
        end
        
    case {'average','furthest','closest','median','kernelClosest'}
        
        if strcmp(params.gdType,'sim')
            [A] = clusterBasedSimilarity(gd,params);
        else
            [A] = clusterBasedSimilarity(1-gd,params); 
        end
        
        
    otherwise
        
        eval(['dist_func=@' params.histDist ';']);
        D=squareform(pdist(sceneFeatures',dist_func));
        
end

switch params.histDist
    
    case {'average','furthest','closest','median','kernelClosest'}
        
        if ~isempty(A(isnan(A)))
            error([params.histDist ': dist outputs nan values'])
        end
        
        if sum(sum(A-A'))~=0
            error('Similarity matrix is not symetric')
        end
        
    otherwise
        
        if ~isempty(D(isnan(D)))
            error([params.histDist ': dist outputs nan values'])
        end
        
        if ~isempty(D(isinf(D)))
            A=zeros(size(D));
            A(~isinf(D))=1-D(~isinf(D))/max(D(~isinf(D)));
        else
            A=exp(-D/mean(squareform(D)));
        end
end


end


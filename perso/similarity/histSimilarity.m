function [A,params] = histSimilarity(sceneFeatures,params,simClus)



switch params.histDist
    
    case 'quadratic_form_distance'
        
        D=zeros(size(sceneFeatures,2),size(sceneFeatures,2));
        for aa=1:size(sceneFeatures,2)
            for bb=aa:size(sceneFeatures,2)
                D(aa,bb) = quadratic_form_distance(sceneFeatures(:,aa)',sceneFeatures(:,bb)',simClus);
                D(bb,aa)=D(aa,bb);
            end
        end
        
    case 'emd'
        
        D=zeros(size(sceneFeatures,2),size(sceneFeatures,2));
        f=1-simClus;
        
        for aa=1:size(sceneFeatures,2)
            for bb=aa+1:size(sceneFeatures,2)
                
                W1=sceneFeatures(:,aa);
                W2=sceneFeatures(:,bb);
                
                F=f(W1~=0,W2~=0);
                
                W1(W1==0)=[];
                W2(W2==0)=[];
                
                flowType=3;
                
                if length(W1)==length(W2)
                    
                    extra_mass_penalty= -1;
                    
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
        
    case {'average','furthest','closest','median'}
        
        [A] = clusterBasedSimilarity(simClus,params);
        D=1-A/max(max(A));
        
    otherwise
        
        eval(['dist_func=@' params.histDist ';']);
        D=squareform(pdist(sceneFeatures',dist_func));
        
end

if ~isempty(D(isnan(D)))
    error([params.histDist ': dist outputs nan values'])
end

if ~isempty(D(isinf(D)))
    A=zeros(size(D));
    A(~isinf(D))=1-D(~isinf(D))/max(D(~isinf(D)));
else
    A=1-D/max(D(:));
end

if sum(sum(A-A'))~=0
    error('Similarity matrix is not symetric')
end

end


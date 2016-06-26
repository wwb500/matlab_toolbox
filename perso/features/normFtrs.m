function [features,setting] = normFtrs(features,param)

setting.type=param.type;


switch param.type
    
    case 'stand'
        
        if isfield(param,'mu')
            
            features=bsxfun(@minus,features,param.mu)./repmat(param.sd,1,size(features,2));
            
        else
            
            setting.mu=mean(features,2);
            setting.sd=std(features,0,2);
            features=bsxfun(@minus,features,setting.mu)./repmat(setting.sd,1,size(features,2));
            
        end
        
    case 'heq'
        
        features = heq(features, 100);
        
    case {'L1','L2'}
        
        [features]= normalizeFeature(features,str2double(param.type(2)), 10^-6);
        
    case {'scattering'}
        
        [ features ] = scatteringNorm(features,param);
        
end

end


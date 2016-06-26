function [f_featureNorm] = normalizeFeature(f_feature,normP, threshold)

% Description:
% - Normalizes a feature sequence according to the l^p norm
% - If the norm falls below threshold for a feature vector, then the
% normalized feature vector is set to be the unit vector.
%
% Input:
%         f_feature
%         normP
%         threshold
%
% Output:
%         f_featureNorm

f_featureNorm = zeros(size(f_feature));

% normalise the vectors according to the l^p norm
unit_vec = ones(1,size(f_feature,1));
unit_vec = unit_vec/norm(unit_vec,normP);

for jj=1:size(f_feature,2);
    
    n= norm(f_feature(:,jj),normP);
    
    if n < threshold
        f_featureNorm(:,jj) = unit_vec;
    else
        f_featureNorm(:,jj) = f_feature(:,jj)/n;
    end
    
end

end
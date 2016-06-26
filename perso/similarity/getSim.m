function [ simMat ] = getSim(features,param)

switch param.type
    case 'kernel-lin'
        simMat=features'*features;
        simMat=sparse(triu(simMat));
    case 'kernel-rbf'
        simMat = conKnl(conDist(features,features), 'nei', param.kernelSig_nei,'knl','g');
        simMat=sparse(triu(simMat));
    case 'kernel-st'
        simMat = conKnl(conDist(features,features),'knl','st','m',param.kernelSig_m);
        simMat=sparse(triu(simMat));
    case 'dtw'
        simMat = getDTWpreSeg(features,param.onsets,param.offsets,param.sim_dtw,param.sim_nei,param.maxDistTime);
        simMat=1-simMat/max(simMat(:));
    case 'euc'
        simMat = pdist(features');
        simMat=squareform(simMat);
        simMat=1-simMat/max(max(simMat));
        simMat=sparse(triu(simMat));
    case 'seuc'
        simMat = pdist(features','seuclidean');
        simMat=squareform(simMat);
        simMat=1-simMat/max(max(simMat));
        simMat=sparse(triu(simMat));
    case 'cosine'
        simMat = pdist(features','cosine');
        simMat=squareform(simMat);
        simMat=1-simMat/max(max(simMat));
        simMat=sparse(triu(simMat));
    otherwise
        error(['wrong setting.method_pwc_sim : ' setting.method_sim])
end

% simMat=sparse(triu(simMat));
% simMat(logical(eye(size(simMat)))) = 0; % set diag to 0 to simulate distance matrix (requiered to run squareform)
% simMat=squareform(simMat);

end


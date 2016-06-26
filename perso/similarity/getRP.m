function [ rp ] = getRP(D,nn,mode)
% Reccurence plot using distance matrix

data2keep=min(round(nn*size(D,1)),size(D,1)-1);
if data2keep<=1
    error('not enough point to compute RP')
end

%% get nn
switch mode
    case 'dist'
        [~,ind_s]=sort(D,'ascend');
    case 'sim'
        [~,ind_s]=sort(D,'descend');
end

D_s_nn=ind_s(2:2+data2keep-1,:);

%% get rp

rp=zeros(size(D));

for jj=1:size(D_s_nn,2)
%     candidats= D_s_nn(:,D_s_nn(:,jj));
%     n=arrayfun(@(x) any(candidats(x,:)==jj), 1:size(candidats,2));
    
    candidats= D_s_nn(:,D_s_nn(:,jj))';
    n=any(bsxfun(@eq,candidats,jj));
    rp(jj,D_s_nn(:,jj))=n;
    rp(D_s_nn(:,jj),jj)=n;
end

rp(logical(eye(size(rp)))) = 1;
rp=full(rp);
end


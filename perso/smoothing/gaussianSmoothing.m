function [ P ] = gaussianSmoothing(L,param)

delta1=sqrt(-(1/2)*(param.t1/4).^2/log(0.5));
delta2=sqrt(-(1/2)*(param.t2/4).^2/log(0.5));

tBin1=round(param.t1/param.hoptime);
tBin2=round(param.t2/param.hoptime);

t1=(0:tBin1)*param.t1/tBin1;
gt1=exp( -(t1-param.t1/2).^2/delta1.^2);

t2=(0:tBin2)*param.t2/tBin2;
gt2=exp( -(t2-param.t2/2).^2/delta2.^2);

G=gt1(:)*gt2(:)';
P=conv2(L,G,'same');

% P(logical(eye(size(P)))) = 0; % set diag to 0 to simulate distance matrix (requiered to run squareform)
% P=squareform(P);
end


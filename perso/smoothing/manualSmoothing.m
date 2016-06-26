function [ K ] = manualSmoothing(K,t1,t2,hoptime )

param.t1=t1;
param.t2=t2;
param.hoptime=hoptime;

if param.t1~=0 && param.t2~=0
    K=gaussianSmoothing(K,param);
end

K=K/max(K(:));


end


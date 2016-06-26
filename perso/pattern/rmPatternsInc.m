function [ patterns ] = rmPatternsInc( patterns,shortPred )


for jj=1:size(patterns,1)
    shortPred=zeros(size(shortPred));
    for ii=1:length(patterns{jj,2})
        shortPred(patterns{jj,2}(ii):patterns{jj,2}(ii)+length(patterns{jj,1})-1)=1;
    end
    patterns{jj,6}=shortPred;
end

ind2rm=zeros(size(patterns,1),1);
for jj=1:size(patterns,1)
    test=[];
    ind2Comp=1:size(patterns,1);
    ind2Comp(ind2Comp==jj)=[];
    for hh=1:length(ind2Comp)
        test=[test;sum((patterns{ind2Comp(hh),6}-patterns{jj,6})==-1)==0];
    end
    ind2rm(jj)=any(test);
end

patterns(logical(ind2rm),:)=[];
disp('');
end


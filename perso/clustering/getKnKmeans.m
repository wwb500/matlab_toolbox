function [ clustering ] = getKnKmeans(K,nbc)

clustering.nbClustersClus=nbc;
clustering.iterMax=250;
clustering.nbRuns = 20;

labels=cell(1,clustering.nbRuns);crit=zeros(1,clustering.nbRuns);logInf=cell(1,clustering.nbRuns);centerDist=cell(1,clustering.nbRuns);


for rr=1:clustering.nbRuns
    if size(K,2) < clustering.nbClustersClus
        clustering.nbClustersClus = size(K,2);
    end
    
    init = [(1:clustering.nbClustersClus) randi(clustering.nbClustersClus,1,size(K,2)-clustering.nbClustersClus)];
    init = init(randperm(length(init)));
    
    [labels{rr},logInf{rr}.energy,logInf{rr}.it,logInf{rr}.crit,centerDist{rr}] = knkmeans(K,init,clustering.iterMax);
    crit(rr)=logInf{rr}.crit(end,3);
end

% get best run
[clustering.globalCrit,indBestRun] = min(crit);
clustering.SS=logInf{rr}.crit(end,2);
clustering.t=logInf{rr}.crit(end,3);
clustering.prediction= labels{indBestRun};
clustering.log= logInf{indBestRun};
clustering.centerDist= centerDist{indBestRun};
end


function [ lab ] = getNbClass( c)

tmp=[];
labUnique=[];
nbElements = size(c,2);
nbFtrs=size(c,1);
lab=zeros(1,nbElements);

% init
lab(1)=1;
labUnique(1)=1;
tmp(:,1)=c(:,1);

for ii=2:nbElements
    flag=1;
    for jj=1:size(tmp,2)
        if sum(tmp(:,jj)==c(:,ii))==nbFtrs
            lab(ii)=labUnique(jj);
            flag=0;
        end
    end
    if flag
        tmp(:,end+1)=c(:,ii);
        lab(ii)=max(labUnique)+1;
        labUnique(end+1)=max(labUnique)+1;
    end
end

end


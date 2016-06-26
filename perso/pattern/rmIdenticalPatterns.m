function [ patterns ] = rmIdenticalPatterns( patterns )

ind2rm=cellfun(@(k) sum(strcmp(cellstr(k(:)),k(1))),patterns(:,1))./cellfun(@length,patterns(:,1)) ==1;
patterns(ind2rm,:)=[];

end


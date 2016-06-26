function [newClus,prob] = votMaj_seg(clus,onsets,offsets,dic,loc)

newClus=zeros(1,length(onsets));
prob=zeros(1,length(onsets));

if isempty(loc)
   loc=1:length(clus); 
end

for jj=1:length(onsets)
    
    c=histc(clus(loc>=onsets(jj) & loc<=offsets(jj)),1:max(dic));
    
    [prob(jj),newClus(jj)]=max(c/sum(c));
    
end

end



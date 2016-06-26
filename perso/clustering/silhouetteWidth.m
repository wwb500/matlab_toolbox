function [ s ] = silhouetteWidth(k,prediction )

s=zeros(1,length(prediction));


for jj=1:length(s)
    
    indClus=prediction(jj);
    indOtherClus=unique(prediction);
    indOtherClus(indOtherClus==indClus)=[];
    
    predTemp=prediction;
    predTemp(jj)=0;
    
    a=mean(k(jj,predTemp==indClus));
    b=min(arrayfun(@(x) mean(k(jj,predTemp==x)),indOtherClus));
    
    
    s(jj)=(b-a)/max([a b]);
end

s=sum(s);

end


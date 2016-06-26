function [ classClusRel ] = getClassClusRelation(clustering,classes,dic_clustering,dic_classes)

classClusRel=zeros(length(dic_classes),length(dic_clustering));


for jj=1:length(dic_classes)
    
    classClusRel(jj,:)=histc(clustering(classes==dic_classes(jj)),dic_clustering);

end

% p(class|clus)
% classClusRel=classClusRel./repmat(sum(classClusRel,1),size(classClusRel,1),1);

% p(clus|class)
classClusRel=classClusRel./repmat(sum(classClusRel,2),1,size(classClusRel,2));

classClusRel(isnan(classClusRel))=0;
function [ prediction ] = votMaj_knn(ind,dist,classesIds)

prediction=zeros(1,size(ind,1));

for jj=1:size(ind,1)
   
   classTmp=classesIds(ind(jj,:));
   count_class=histc(classTmp,1:max(classesIds));
   
   [~,prediction(jj)]=max(count_class);

end


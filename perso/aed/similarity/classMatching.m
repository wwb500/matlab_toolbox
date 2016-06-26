function [ classMatch ] = classMatching(classClusRel,prediction )

classMatch=zeros(size(classClusRel,1),size(prediction,2));

for jj=1:length(prediction)
    
    classMatch(:,jj)=classClusRel(:,prediction(jj));

end

end


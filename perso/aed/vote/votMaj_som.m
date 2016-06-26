function [ prediction,prob] = votMaj_som(classMatch_test,onsets,offsets)

prediction=zeros(1,length(onsets));
prob=zeros(1,length(onsets));

for jj=1:length(onsets)
    
    class_score=sum(classMatch_test(:,onsets(jj):offsets(jj)),2);

    [prob(jj),prediction(jj)]=max(class_score);
    
end





end


function [ T ] = getDurationPatterns(T,onsets,offsets,shortPred)

% shortPredChar = sprintf('%.0f',shortPred);

for jj=1:size(T,1)
%    pat=  sprintf('%.0f',T{jj,1});
  T{jj,2}=strfind(shortPred,T{jj,1});
  dur=[];
  for ll=1:length(T{jj,2})
     dur=[dur offsets(T{jj,2}(ll)+length(T{jj,1})-1)-onsets(T{jj,2}(ll))];
  end
  T{jj,4}=dur;
end

end


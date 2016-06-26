function [ patterns ] = rmMissMatchPatterns( patterns )

ind2rm=[];

for jj=1:size(patterns,1)
    test=diff(patterns{jj,2})<length(patterns{jj,1});
    if any(test)
        for yy=2:length(test)
            if test(yy-1)==1 && test(yy)==1
                test(yy)=0;
            end
        end
        patterns{jj,2}(logical([1 test]))=[];
        patterns{jj,4}(logical([1 test]))=[];
        if length(patterns{jj,2})<=1
            ind2rm=[ind2rm jj];
        end
    end
end

patterns(ind2rm,:)=[];

end


function [newLabel,newStartTime,newEndTime] = rmSilence( data )

startTime = data{1};
endTime = data{2};
label = data{3};
xx=0;

for jj=1:length(startTime)

    if ~strcmpi(label{jj},'Silence') && ~strcmpi(label{jj},'Si')
        xx=xx+1;
        newStartTime(xx) = startTime(jj);
        newLabel(xx) = label(jj);
        newEndTime = endTime(jj);
    end
end


end


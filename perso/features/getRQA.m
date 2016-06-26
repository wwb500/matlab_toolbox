function [rqa] = getRQA(features,maxSize,params)

rqa = [];

for ii = 1:maxSize
    beg = 1+(ii-1)*params.nbPoints;
    term = min(beg+params.nbPoints-1,size(features,2));
    d = squareform(pdist(features(:,beg:term)',params.distance));
    [D] = getRP(d,params.nn,'dist');
    rqa_win = RQA(D,params.dl,params.vl);
    
    if any(isnan(rqa_win))
        error('nan value when computing RQA')
    end
    
    rqa = [rqa rqa_win'];
end

end


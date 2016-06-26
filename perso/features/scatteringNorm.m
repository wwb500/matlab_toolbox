function [ data ] = scatteringNorm(data,params)

data=data';

if params.ftrsNorm_scat_threshold
    med = median(data);
    data = log(bsxfun(@rdivide, data, med*params.ftrsNorm_scat_threshold));
end

if params.ftrsNorm_scat_selection~=1
    v = var(data);
    v = v/sum(v);
    [~,i] = sort(-v);
    cv = cumsum(v(i));
    data =  data(:,i(cv<params.ftrsNorm_scat_selection));
end

data=data';

end


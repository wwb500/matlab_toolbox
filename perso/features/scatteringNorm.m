function [ data ] = scatteringNorm(data,params)

data=data';

if params.ftrsNorm_scat_threshold~=0
    med = median(data);
    data = bsxfun(@rdivide, data, med*params.ftrsNorm_scat_threshold);
end

if params.ftrsNorm_scat_log~=0
    data = log(data);
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


function K = conKnl(D, varargin)
% Construct the kernel matrix from distance.
%
% Input
%   D       -  distance matrix, n x n
%   varargin 
%     knl   -  kernel type, 'g' | 'st' | 'bi'
%              'g':  Gaussian kernel
%              'st': Self Tunning kernel. See the paper in NIPS 2004, Self-Tuning Spectral Clustering
%              'bi': Bipartite Maximum Weight Matching. See the paper in AISTAT 2007, Loopy Belief Propagation for Bipartite Maximum Weight b-Matching
%     nei   -  #nearest neighbour to compute the kernel bandwidth, {.1}
%              0: binary kernel
%              NaN: set bandwidth to 1
%
% Output
%   K       -  kernel matrix, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% function option
knl = ps(varargin, 'knl', 'g');
nei = ps(varargin, 'nei', .1);
m = ps(varargin,'m',.1);

% specific kernel
if strcmp(knl, 'g')
    sigma = bandG(D, nei);
    K = exp(- (D .^ 2) / (2 * sigma ^ 2 + eps));

elseif strcmp(knl, 'st')
    Dsorted = sort(D);

    D2 = Dsorted(1 : m, :);
    sigma = sum(D2, 1) / m;

    K = exp(- (D .^ 2) ./ (sigma' * sigma * 2 + eps));

elseif strcmp(knl, 'bi')
    lb = m;
    ub = m;
    mask = ones(n, n);
    P = bdmatchwrapper(-D, mask, lb, ub);

    D2 = D .* P;
    sigma = sum(D2, 1) / m;
    K = exp(- (D .^ 2) ./ (sigma' * sigma * 2 + eps));

else
    error(['unknown kernel type: ' knl]);
end

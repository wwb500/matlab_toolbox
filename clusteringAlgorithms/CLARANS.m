function  [JC, memIdx, minCost] = CLARANS(dist, numOfObjs, k)
% CLARANS algorithm for cluster
%
%dist:              Inter-point distance array
%numOfObjs:  number of objects to be clustered
%k:                  Number of clusters
%
%



% for indexing the dist array
global cutOffPnt;
cutOffPnt = [0 cumsum(numOfObjs-1:-1:1)];

NumofLocalRegions = 10;
MaxNeighbours = 20;% min(10, k);

% loop over location regions
jTry = 1;
for i = 1:NumofLocalRegions

    kidx = randperm(numOfObjs);
    
    %indices of current medoids
    midx = kidx(1:k);
    
    %indices of unassinged objects
    jidx = kidx(k+1:end);
    
    %assign membership of objects in jidx to current medoidx - midx
    [memIdx, memIdx2] = AssignMemberShip(dist, numOfObjs, midx, jidx);
    
    if(i==1)
        currentCost = CalculateCost(dist, numOfObjs, midx, jidx, memIdx);
        minCost = currentCost;
        optMidx = midx;
    end;

    %loop over neighbors
    while(1)%for j=1: MaxNeighbours

        %randomly pick a candidate to replace a randomly selected medoidx
        oidx = randperm(k); idxMetroid = oidx(1);oidx = midx(oidx(1));
        pidx = randperm(numOfObjs - k); idxReplace = pidx(1); pidx = jidx(pidx(1));

        %evaluate the differential cost: Cjop with j inside jidx excluding
        %the pidx (won't hurt to keep it)
        Cjop = 0;
        for kk=1:numOfObjs - k
            jPointIdx = jidx(kk);

            %find the cluster membership of jPointIdx
            jmemIdx = memIdx(kk);
            jmemIdx2 = memIdx2(kk);
            
            %calc various distances
            distFromJtoN = GetDist(dist, numOfObjs, jPointIdx, jmemIdx);
            distFromJtoJ2 = GetDist(dist, numOfObjs, jPointIdx, jmemIdx2);
            distFromJtoP = GetDist(dist, numOfObjs, jPointIdx, pidx);
            distFromJtoO = GetDist(dist, numOfObjs, jPointIdx, oidx);
             
            if (jmemIdx == oidx)                
                %case 1 as described in the paper
                if(distFromJtoJ2 < distFromJtoP)
                    deltCost = distFromJtoJ2 -  distFromJtoO;
                    
                    % case 2
                else
                    deltCost =  distFromJtoP -  distFromJtoO;
                end;
            else
                if(distFromJtoN > distFromJtoP)
                    deltCost =  distFromJtoP - distFromJtoN;                    
                    % case 4
                else
                    deltCost = 0;
                end;
            end;
            Cjop = Cjop + deltCost;
        end;

        % improved cost
        if(Cjop < 0)
            midx(idxMetroid) = pidx;
            jidx(idxReplace) = oidx;
            [memIdx, memIdx2] = AssignMemberShip(dist, numOfObjs, midx, jidx);
            jTry = 1;
        else
            jTry = jTry + 1;
            if (jTry >MaxNeighbours)
                break;
            end;
        end;
    end;

    currentCost = CalculateCost(dist, numOfObjs, midx, jidx);
    if(minCost > currentCost)
        minCost = currentCost;
        optMidx = midx;
    end;
end;

jidx = setdiff(1:numOfObjs, optMidx);
[memIdx, memIdx2] = AssignMemberShip(dist, numOfObjs, optMidx, jidx);

memIdx = [memIdx optMidx];
jidx = [jidx optMidx];
for i=1:numOfObjs
    JC(jidx(i)) = find(memIdx(i) == optMidx);
end;


%%
function [memIdx, memIdx2] = AssignMemberShip(dist, N, midx, jidx)
%
%
%   objects in midx are current medoidx and jidx are indices of objects to
%   be assigned with a membership in midx
%
%

numOfJObjs = length(jidx);
memIdx = zeros(1, numOfJObjs);
memIdx2 = zeros(1, numOfJObjs);
for i=1:numOfJObjs
    adist = GetDist(dist, N, jidx(i), midx);
    
    [t, memIdx(i)] =min(adist);
    adist(memIdx(i)) = inf;
    [t, memIdx2(i)] =min(adist);

    memIdx(i) = midx(memIdx(i));
    memIdx2(i) = midx(memIdx2(i));
end;


%%%%%%%%
function  currentCost = CalculateCost(dist, numOfObjs, midx, jidx, memIdx)
%
%   Calculate the cost (average distance between objects and their cluster
%   medoid).
%
%
if nargin < 5
    [memIdx] = AssignMemberShip(dist, numOfObjs, midx, jidx);
end;

currentCost = 0;
for i=1:length(memIdx)
    currentCost = currentCost + GetDist(dist, numOfObjs, jidx(i), memIdx(i));
end;
currentCost = currentCost / length(memIdx);


%%%%%%%%
function adist = GetDist(dist, N, idx, jdx)
%
%  Get the distance metric between objects idx and jdx
%
%   N: number of objects

global cutOffPnt;

n = length(jdx);
adist = nan(1, n);
for k=1:length(jdx)
    j = jdx(k);
    if (idx == j)
        adist(k) = 0;
    else
        if(idx < j)
            ix = idx;
            idx = j;
            j = ix;
        end;
        idxToDistArray = cutOffPnt(j) +  idx -  j ;
        adist(k) = dist(idxToDistArray);
    end;
end;
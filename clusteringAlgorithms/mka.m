function [ labels, nbMoved ] = mka( simils, nbClasses, criterion, strategy, initClasses, nbIterations )
  %MKA Summary of this function goes here
  
  % strategy is one of 'batch', 'progressive', 'bestProgressive', 'mixed' and 'bestMixed'  
  % criterion is one of 'raw', 'objectNormalized' or 'classNormalized'
  
  if nargin<4
    error('Function needs at least 4 parameters');
  end
  
  nbObjects = length(simils);
  
  if nargin > 4
    labels = initClasses;
  else
    labels = 1+floor(nbClasses*rand(1,nbObjects));
  end
  
  selfSimilarities = arrayfun(@(i)simils(i,i), 1:nbObjects);
  
  classSizes = arrayfun(@(c) sum(labels==c), 1:nbClasses);
  
  averageSimilarityAccumulators = zeros(nbClasses, nbObjects);
  classObjectSimilarities = zeros(nbClasses, nbObjects);
  classQualities = zeros(nbClasses,1);
  for ic = 1:nbClasses
    averageSimilarityAccumulators(ic,:) = sum(simils(labels==ic,:));
    classObjectSimilarities(ic,labels==ic) = (averageSimilarityAccumulators(ic,labels==ic) - selfSimilarities(labels==ic)) / (classSizes(ic)-1);
    classObjectSimilarities(ic,labels~=ic) = averageSimilarityAccumulators(ic,labels~=ic) / classSizes(ic);
    classQualities(ic) = mean (classObjectSimilarities(ic,labels==ic));
  end
  
  % Possible criterion functions are defined at the end of this file, we
  % select one of them here.
  
  critFun = @(o,c) 'Undefined';
  
  switch criterion(1)
    case 'r' % rawCriterion
      critFun = @rawCriterion;
    case 'o' % objectNormalized
      critFun = @objectNormalizedCriterion;
    case 'c' % classNormalized
      critFun = @classNormalizedCriterion;
  end
  
  if ~exist('nbIterations', 'var'), nbIterations = 200; end
  minIncrement = 0.000001;
  
  if length(strategy)==1
    switch strategy
      case {'P'}
        strategy = 'bestProgressive';
      case {'p'}
        strategy = 'progressive';
      case 'b'
        strategy = 'batch';
      case 'm'
        strategy = 'mixed';
      case 'M'
        strategy = 'bestMixed';
    end
  end
  
  nbMoved = [];
  
  switch strategy
    case 'batch'
      changes = 1;
      loop = 0;
      while changes && loop < nbIterations
        loop = loop+1;
        changes = batchStep();
        nbMoved = [nbMoved changes];
      end
      if (loop == nbIterations)
        disp('Warning: batch k-averages clustering failed to converge within maximum number of iterations.');
      end
%       figure(4);
%       plot(nbMoved);
      
    case 'progressive'
      changes = 1;
      loop = 0;
      while changes && loop < nbIterations
        loop = loop+1;
        changes = progressiveStep();
        nbMoved = [nbMoved changes];
      end
      
      if (loop == nbIterations)
        disp('Warning: progressive k-averages clustering failed to converge within maximum number of iterations.');
      end
%       figure(4);
%       plot(nbMoved);
      
      
    case 'bestProgressive'
      change = true;
      count = 0;
      % Compute all criteria
      criteria = zeros(nbObjects, nbClasses);
      for ob=1:nbObjects
        criteria(ob,:) = arrayfun(@(c) critFun(c, ob), 1:nbClasses);
      end
      while change
        [change, criteria] = bestProgressiveStep(criteria);
        count = count+1;
        if (mod(count,1000) == 0)
          disp(change);
        end
      end
      
    case 'mixed'
      changes = nbObjects;
      loop = 0;
      % Phase 1 : batch
      while changes>nbObjects/10 && loop < nbIterations
        loop = loop+1;
        changes = batchStep();
      end
      % Phase 2 : progressive
      while changes && loop < 2*nbIterations
        loop = loop+1;
        changes = progressiveStep();
      end
      
      if (loop == 2*nbIterations)
        disp('Warning: mixed k-averages clustering failed to converge within maximum number of iterations.');
      end
      
    case 'bestMixed'
      changes = nbObjects;
      loop = 0;
      % Phase 1 : batch
      while changes>nbObjects/10 && loop < nbIterations
        loop = loop+1;
        changes = batchStep();
      end
      % Phase 2 : best progressive
      change = true;
      % Compute all criteria
      criteria = zeros(nbObjects, nbClasses);
      for ob=1:nbObjects
        criteria(ob,:) = arrayfun(@(c) critFun(c, ob), 1:nbClasses);
      end
      while change
        [change, criteria] = bestProgressiveStep(criteria);
      end 
  end
  
  % Defining the optimisation criteria as nested functions here
  % Parameters: object index o, new class index c
  % Return: impact on the global objective function of moving object o to
  % class c
  
  function criterion = rawCriterion (c, o)
    currentSimil = classObjectSimilarities(labels(o),o);
    newSimil = classObjectSimilarities(c,o);
    criterion = newSimil - currentSimil;
  end
  
  function criterion = objectNormalizedCriterion (c, o)
    % See pdf document for  details re: formula
    c1 = labels(o);
    n1 = classSizes(c1);
    c2 = c;
    n2 = classSizes(c2);
    if (c1==c2)
      criterion = 0;
    else
      impactOfLeavingOld =  2 *(n1-1)*(classQualities(c1)-classObjectSimilarities(c1,o)) / (n1-2) - classQualities(c1);
      newClassQualityC2 = ((n2-1)*classQualities(c2)+2*classObjectSimilarities(c2,o)) / (n2+1);
      impactOfJoiningNew = -2 * n2   *(classQualities(c2)-classObjectSimilarities(c2,o)) / (n2+1) + newClassQualityC2;
      criterion = impactOfLeavingOld + impactOfJoiningNew;
    end
  end
  
  function criterion = classNormalizedCriterion (c, o)
    % See pdf document for  details re: formula
    c1 = labels(o);
    n1 = classSizes(c1);
    c2 = c;
    n2 = classSizes(c2);
    if (c1==c2)
      criterion = 0;
    else
      impactOfLeavingOld =  2 *(classQualities(c1)-classObjectSimilarities(c1,o)) / (n1-2);
      impactOfJoiningNew = -2 *(classQualities(c2)-classObjectSimilarities(c2,o)) / (n2+1);
      criterion = impactOfLeavingOld + impactOfJoiningNew;
    end
  end
  
  % Defining the base strategies as nested functions here
  % One function = one iteration step
  % Returns true if change, or number of changes
  
  function changes = batchStep ()
    criteria = zeros(nbObjects, nbClasses);
    for o=1:nbObjects
      criteria(o,:) = arrayfun(@(c) critFun(c, o), 1:nbClasses);
    end
    % Find best target class for all
    [v,i] = max(criteria,[],2);
    % Re-allocate all objects that have a positive change
    % criterion.
    changes = sum(v>minIncrement);
    
    for o=1:nbObjects
      if (v(o) > minIncrement)
        oldC = labels(o); newC = i(o);
        averageSimilarityAccumulators(oldC,:) = averageSimilarityAccumulators(oldC,:) - simils(o,:);
        averageSimilarityAccumulators(newC,:) = averageSimilarityAccumulators(newC,:) + simils(o,:);
        classSizes(oldC) = classSizes(oldC)-1;
        classSizes(newC) = classSizes(newC)+1;
        labels(o) = newC;
      end
    end
    for c=1:nbClasses
      classObjectSimilarities(c,labels==c) = (averageSimilarityAccumulators(c,labels==c) - selfSimilarities(labels==c)) / (classSizes(c)-1);
      classObjectSimilarities(c,labels~=c) = averageSimilarityAccumulators(c,labels~=c) / classSizes(c);
      classQualities(c) = mean (classObjectSimilarities(c,labels==c));
    end
  end
  
  function changes = progressiveStep()
    changes = 0;
    % Taking objects one by one, compute updated criterion then
    % take allocation decision
    for o=1:nbObjects
      criteria = arrayfun(@(c) critFun(c, o), 1:nbClasses);
      [v,newC] = max(criteria);
      if (v>minIncrement)
        % Incremental update of class properties
        changes = changes+1;
        oldC = labels(o);
        labels(o) = newC;
        classQualities(oldC) = (classSizes(oldC)*classQualities(oldC)-2*classObjectSimilarities(oldC,o))/(classSizes(oldC)-2);
        classQualities(newC) = ((classSizes(newC)-1)*classQualities(newC)+2*classObjectSimilarities(newC,o))/(classSizes(newC)+1);
        
        % Incremental update of class-object similarities
        averageSimilarityAccumulators(oldC,:) = averageSimilarityAccumulators(oldC,:) - simils(o,:);
        averageSimilarityAccumulators(newC,:) = averageSimilarityAccumulators(newC,:) + simils(o,:);
        classSizes(oldC) = classSizes(oldC)-1;
        classSizes(newC) = classSizes(newC)+1;
        for c=[oldC,newC]
          classObjectSimilarities(c,labels==c) = (averageSimilarityAccumulators(c,labels==c) - selfSimilarities(labels==c)) / (classSizes(c)-1);
          classObjectSimilarities(c,labels~=c) = averageSimilarityAccumulators(c, labels~=c) / classSizes(c);
        end
      end
    end
  end
  
  function [change, criteria] = bestProgressiveStep(criteria)
    % The "criteria" matrix contains precomputed values and is given as
    % paramater to be updated by this function
    change = 0;
    % Find best of the best
    [vals,bestClasses] = max(criteria,[],2);
    [v,bestObject] = max(vals);
    % Re-allocate best object only
    newC = bestClasses(bestObject);
    if (v>minIncrement)
      change = v;
      oldC = labels(bestObject);
      labels(bestObject) = newC;
      classQualities(oldC) = (classSizes(oldC)*classQualities(oldC)-2*classObjectSimilarities(oldC,bestObject))/(classSizes(oldC)-2);
      classQualities(newC) = ((classSizes(newC)-1)*classQualities(newC)+2*classObjectSimilarities(newC,bestObject))/(classSizes(newC)+1);
      
      % Incremental update of class-object similarities
      averageSimilarityAccumulators(oldC,:) = averageSimilarityAccumulators(oldC,:) - simils(bestObject,:);
      averageSimilarityAccumulators(newC,:) = averageSimilarityAccumulators(newC,:) + simils(bestObject,:);
      classSizes(oldC) = classSizes(oldC)-1;
      classSizes(newC) = classSizes(newC)+1;
      for c=[oldC,newC]
        classObjectSimilarities(c,labels==c) = (averageSimilarityAccumulators(c,labels==c) - selfSimilarities(labels==c)) / (classSizes(c)-1);
        classObjectSimilarities(c,labels~=c) = averageSimilarityAccumulators(c,labels~=c) / classSizes(c);
      end
      % Update criteria for the 2 affected classes
      criteria(:,oldC) = arrayfun(@(ob) critFun(oldC, ob), 1:nbObjects);
      criteria(:,newC) = arrayfun(@(ob) critFun(newC, ob), 1:nbObjects);
    end
  end
end

function [ patternAlpha ] = num2alpha(patternNum)

alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
patternAlpha=arrayfun(@(k) alphabet(k),patternNum);

end


function [ patternNum ] = alpha2num( patternAlpha )

alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
patternNum=strfind(alphabet,patternAlpha);

end


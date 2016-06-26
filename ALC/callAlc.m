function prediction = callAlc(setting, inputFileName, outputFilePrefix)


% first level
alcConfig(1).nbc=100;
alcConfig(1).structToSpectralBalance=0;
alcConfig(1).contToSimilBalance=1;
alcConfig(1).verticalDistanceType='a';
alcConfig(1).horizontalDistanceType='a';
alcConfig(1).cutStrategy = 'mMb';
% second level
alcConfig(2).nbc=100;
alcConfig(2).structToSpectralBalance=0.5;
alcConfig(2).contToSimilBalance=0.5;
alcConfig(2).verticalDistanceType='d';
alcConfig(2).horizontalDistanceType='a';
alcConfig(2).cutStrategy = 'm';
% third level
alcConfig(3).nbc=4;
alcConfig(3).structToSpectralBalance=0.5;
alcConfig(3).contToSimilBalance=0;
alcConfig(3).verticalDistanceType='d';
alcConfig(3).horizontalDistanceType='d';
alcConfig(3).cutStrategy = 'm';

% TODO create tool for injecting settings
alcConfig(1).contToSimilBalance=setting.contToSimilBalance1;
alcConfig(2).nbc=setting.nbc;
alcConfig(2).structToSpectralBalance=setting.structToSpectralBalance;
alcConfig(2).contToSimilBalance=setting.contToSimilBalance2;
% alcConfig(2).verticalDistanceType=setting.verticalDistanceType;
% alcConfig(2).horizontalDistanceType=setting.horizontalDistanceType;
% alcConfig(2).cutStrategy =setting.cutStrategy;



configFileName = [outputFilePrefix '.config'];

fid = fopen(configFileName, 'w');
fprintf(fid, '%d %d %d\n', length(alcConfig), setting.alcNorm, 10); % noramlized or not and nb runs of kaverages
for k=1:length(alcConfig)
    lk =  struct2cell(alcConfig(k));
    fprintf(fid,'%d %f %f %c %c %s \n', lk{:});
end
fclose(fid);

% inputFileName = '/home/lagrange/Dropbox/soundthings/papers/drumsEusipco2015/data/drumScenes/features/drumData_ebr12_avSpaceMode4_1.mfcc';

command = [fileparts(mfilename('fullpath'))  '/alc   -c ' configFileName   ' -d ' inputFileName ' -o ' outputFilePrefix ' -rs 0 2>/dev/null' ];

system(command);

prediction = loadjson([outputFilePrefix '.all.json']);

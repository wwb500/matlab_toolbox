function [] = sf_display(indFig,st_output)

figure(indFig)
subplot 311
imagesc(st_output.featuresMin)
subplot 312
imagesc(st_output.simMatMin)
subplot 313
imagesc(st_output.predictionMin)
title(['class 1: ' num2str(st_output.val(1)) '; class 2:' num2str(st_output.val(2))])

end


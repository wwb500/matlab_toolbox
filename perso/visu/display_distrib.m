function [] = display_distrib(histo,samples2Use,indFig,titles)

nbSample=length(samples2Use);
nbSubPlot=floor(sqrt(nbSample));

if length(titles)==1
    titles=repmat(titles,1,length(samples2Use));
end
    
figure(indFig)
for jj=1:length(samples2Use)
    subplot(nbSubPlot,nbSubPlot+1,jj)
    bar(histo(:,samples2Use(jj)))
    axis tight
    ylim([0 max(histo(:))])
    title(titles{jj})
end


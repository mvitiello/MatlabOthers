% Normal Distribution and Percentiles
% Code 1.1. Example: Histogram and percentile 5% and 1%
% random numbers with a normal distribution
data = randn(10000, 1);
% is 'estimated' (via maximum likelihood) the random vector to 
% obtain a normal distribution to obtain parameters
parn = mle(data, 'distribution', 'norm');
% is simulated random numbers with the parameters obtained 
% parameters should be mean ~ 0 and variance ~ 1
r1 = random('norm', parn(1), parn(2), [10000,1]);
% calculate percentile 5% and 1% as percentile
v1 = prctile(r1, 100 - 95);
v2 = prctile(r1, 100 - 99);
% plot histogram
p1 = figure('visible', 'on', 'units', 'normalized',...
    'outerposition', [0 0 1 1]);
% histogram with normal distribution fitted, 40 bins
histfit(r1, 40, 'normal')
hold on
% line showing the 5 % percentile in the distribution 
xline(v1, 'm--', 'LineWidth', 2);
hold on
xline(v2, 'g--', 'LineWidth', 2);
legend('distribution', 'fit', 'p5', 'p1')
title ('Normal Distribution with percentile')
xlabel('value'), ylabel('frecuency') % axis title
saveas(p1, 'Normal Distribution with percentile', 'jpg')
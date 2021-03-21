% VaR and ES with many distributions
% Code 1.2. Example: VaR and ES with many
% distributions (Analytical calculation)

% clear all workspace
clear
% clear command window
clc

% The data is created
% Data is created with different distributions

% random numbers generator
rng('shuffle')

% random numbers with a normal distribution
data = randn(10000, 1);
parn = mle(data, 'distribution', 'norm');
% is 'estimated' the random number to a normal distribution
% to obtain parameters
r1 = random('norm', parn(1),abs(parn(1))* parn(2), [10000,1]);
% mean
mun = mean(r1);
% standard deviation 
sigman = std(r1);
% skew
skewn =  skewness(r1);
% kurtosis
kurtosisn = kurtosis(r1, 0) - 3; % flag = 0 to fix  the bias
g = figure('visible', 'on', 'units', 'normalized', ...
    'outerposition', [0 0 1 1]);
% is divided the 'plot space' in a matrix 2x2
subplot(2,2,1)
% is plotted the distribution and a normal distribution is fitted
histfit(r1, 40, 'Normal'), xlabel('value'), ylabel('frecuency'),
title(['Normal Distribution (', num2str(parn(1), '%.3f'),',', ...
    num2str(parn(2), '%.3f'),')'])

% random numbers with a lognormal distribution
datalg = lognrnd(0.3, 0.5, 10000, 1);
% is 'estimated' the random number to a lognormal distribution
% to obtain parameters
parlg = mle(datalg, 'distribution', 'lognormal');
r2 = random('lognormal', parlg(1), parlg(2), [10000,1]);
mulg = mean(r2);
sigmalg = std(r2);
skewlg =  skewness(r2);
kurtosislg = kurtosis(r2, 0) - 3;
subplot(2,2,2)
% is plotted the distribution and a lognormal distribution is fitted
histfit(r2, 40, 'lognormal'), xlabel('value'), ylabel('frecuency'),
title(['Log-Normal Distribution(', num2str(parlg(1), '%.3f'),',', ...
    num2str(parlg(2), '%.3f'),')'])

% random number with t distribution with 4 degree of freedom
datat = trnd(4, 10000, 1);
% is 'estimated' the random number to a t scale distribution
% to obtain parameters
pt = mle(datat, 'distribution', 'tlocationscale');
r3 = random('tlocationscale', pt(1), abs(pt(1))*pt(2), pt(3), [10000,1]);
mut = mean(r3);
sigmat = std(r3);
skewt =  skewness(r3);
kurtosist = kurtosis(r3, 0) - 3; % flag = 0 to correct the bis
subplot(2,2,3)
% is plotted the distribution and a t scale distribution is fitted
histfit(r3, 40, 'tlocationscale'), xlabel('value'),
ylabel('frecuency'),
title(['t scale Student distribution(', num2str(pt(1), '%.3f'),',', ...
    num2str(pt(2), '%.3f'),',',num2str(pt(3), '%.3f'),')'])

% random numbers with a Weibull Distribution,
% shape and location parameter  = 0 and scale parameter = 2
dataw = wblrnd(1,1.5,1000,1);
% is 'estimated' the random number to a pareto distribution
% to obtain parameters
parw = mle(dataw, 'distribution', 'wbl');
r4 = random('wbl', parw(1), parw(2), [10000,1]);
skeww =  skewness(r4);
kurtosisw = kurtosis(r4, 0) - 3;
subplot(2,2,4)
% is plotted the distribution and a pareto distribution is fitted
histfit(r4, 40,'wbl'), xlabel('value'), ylabel('frecuency'),
title(['Weibull distribution(', num2str(parw(1), '%.3f'),',', ...
    num2str(parw(2), '%.3f'),')'])
saveas(g, 'Different distributions', 'jpg')

% The VaR is calculated with many distributions
% VAR and ES calculations is presented

% significance levels
al = [0.95 0.99];

%VaR and ES, normal distribution
%VaR defined as quantile function using normal distribution
VARn = -mun + sigman*norminv(al);
VARnp = - mun + sigman * (sqrt(2)) * erfinv(2 *(al) - 1);
% entropic VaR 
EVaR = -mun + sigman*sqrt(-2*log(1 - al));
% Expected Shortfall
ESn = mun + sigman ./ (1-al) .* normpdf(norminv(al));
% ESn with error function  (gives the same value as ESn)
ESnq = mun + sigman ./(sqrt(2.*pi).*(1-al).*exp(erfinv(2.*al-1).^2));
% VaR with Cornish-Fisher Expansion
VaRnCF = VARCornishFisher(-mun, sigman, skewn,kurtosisn, al, 0, 1);
% ES with Cornish-Fisher Expansion
ESnCF = CFisherCVAR(VaRnCF, mun, sigman, al, ...
    skewn, kurtosisn, 0, 1);

%VaR and ES, Log-normal distirbution
VaRln = 1 - exp(parlg(1) - parlg(2) * norminv(al));
%VaR defined as quantile function using Log Normal distribution
VARlnp = exp(parlg(1) - parlg(2)*sqrt(2*erfinv(2*(al)-1)));
% ES lognormal "intuitive" 
ESln = 1 - exp(-parlg(1) + 0.5*parlg(2)^2)*...
    (normcdf(norminv(1-al)-parlg(2)))./(1-al);
% ES lognormal with definition 
ESlnd = exp(-parlg(1)+(parlg(2)^2)/2)./...
    (1 - normcdf((log(VaRln)-parlg(1))./parlg(2))).* ...
    normcdf((- log(VaRln) + parlg(1)+ parlg(2)^2)./ parlg(2));
% ES lognormal with quantile function 
ESlnq = (exp(-parlg(1) + 0.5*parlg(2)^2)*erf((parlg(2)./sqrt(2))*...
    erfinv(2.*al-1)))./(2*(1-al));
% VaR with Cornish-Fisher Expansion
VaRlnCF = VARCornishFisher(-parlg(1), parlg(2), skewlg, ...
    kurtosislg,al, 0, 2);
% ES with Cornish-Fisher Expansion
ESlnCF = CFisherCVAR(VaRlnCF, parlg(1), parlg(2), al, skewlg, ...
    kurtosislg, 0, 2);

%VaR and ES, t de student escaled distribution
VaRt = - mut + tinv(al, pt(3))* sigmat * ...
    sqrt((pt(3)- 2)/pt(3));
ESt =  mut + (sqrt((pt(3) - 2)/pt(3))) * ...
    (sigmat.* (tpdf((tinv(al, pt(3))), pt(3))/(1-al)).* ...
    ((pt(3)+(tinv(al, pt(3))).^2)./(pt(3) - 1)));

% VaR with Cornish-Fisher Expansion
VaRtCF = VARCornishFisher(-mut, sigmat, skewt,kurtosist,...
    al, pt(3), 3);
% ES with Cornish-Fisher Expansion
EStCF = CFisherCVAR(VaRtCF, mut, sigmat, al, skewt,...
    kurtosist, pt(3), 3);

%VaR and ES with Weibull
% parw(1) = scale, lambda
% parw(2) = shape, k
VaRw = parw(1)*((-log(1-al)).^(1/parw(2)));
ESw = parw(1)./(1-al).* gammainc(1 + 1./parw(2),-log(1-al),'upper');
% VaR with Cornish-Fisher Expansion
VaRwCF = VARCornishFisher(parw(1), parw(2), skeww, kurtosisw,...
    al, 0, 4);
% ES with Cornish-Fisher Expansion
ESwCF = CFisherCVAR(VaRwCF, parw(1), parw(2), al, skeww, ...
    kurtosisw, 0, 4);

% VaR and ES table
ap = {'v95perc'; 'v99perc'};
Names = {'VARn' 'VaRnp' 'ESn' 'ESnq' 'VaRCFn' 'ESnCF' 'EVaR' ...
    'VaRln' 'VARlnp' 'ESln' 'ESlnd' 'ESlnq' 'VaRCFln' 'ESlnCF'...
    'VaRt' 'ESt' 'VaRCFt' 'EStCF' 'VaRw' 'ESw' 'VaRCFw' 'ESwCF'};
vTable = rows2vars(table(VARn', VARnp', ESn', ESnq', VaRnCF', ...
    ESnCF', EVaR', VaRln', VARlnp', ESln', ESlnd', ESlnq', ...
    VaRlnCF',ESlnCF', VaRt', ESt', VaRtCF', EStCF', VaRw', ESw',...
    VaRwCF', ESwCF', 'VariableNames', Names, 'RowNames', ap));
vTable.Properties.VariableNames(1) = {'Measure'};
writetable(vTable, 'PVaRES.xls', 'Sheet', 1, ...
    'WriteRowNames', 1)
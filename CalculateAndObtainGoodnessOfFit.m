function [TT1, TT2, TT3, TT4] = ...
    CalculateAndObtainGoodnessOfFit(iniDate, endDate, path, varargin) 
% [TT1, TT2, TT3, TT4] = ...
% CalculateAndObtainGoodnessOfFit(iniDate, endDate, varargin)
% obtain different measures of goodness of fit using the financial time
% series using varargin, that determine the tickers 
% that we want in the analysis. 
% iniDate and endDate are the point in time date that we 
% want to start and finish with in the analysis. 
% requires a path folder, the folder path where the files are saved
% The prices are fitted as LogNormal and Weibull Distribution
% The returns are fitted as Normal and t location scale Distribution.
% try, for exmaple: 
% [T, T2, T3, T4] = CalculateAndObtainGoodnessOfFit('01072008',...
%     '01102018', '^GSPC', '000001.SS', 'HSBC', 'SMFG')
% warning, we have a list of tickers  but maybe 
% this list need to be updated, we included in the code an 
% error message when the ticker is missed: the ticker and 
% the name of the variable is required in the ftick variable. 
% the output are: 
% TT1 = Structure with n tables with measures of fit 
% wrt LogNormal Distribution, where n are the number 
% of variables in the analysis, i.e., tickers
% TT2 = Structure with n tables with measures of fit 
% wrt Weibull Distribution, where n are the number 
% of variables in the analysis, i.e., tickers
% TT3 = Structure with n tables with measures of fit, 
% wrt Normal Distribution, where n are the number 
% of variables in the analysis, i.e., tickers
% TT4 = Structure with n tables with measures of fit 
% wrt t location scale Distribution, where n are the number 
% of variables in the analysis, i.e., tickers

if ~exist(path, 'dir')
    mkdir(path)
end 

% list of tickers
% (maybe this list need to be updated with the ticker 
% and name required)
ftick = {'^GSPC', 'SP500';...
    '^IBEX', 'IBEX35';...
    '^FCHI', 'CAC40';...
    '^FTSE', 'FTSE100';...
    '^N225', 'Nikkei225';...
    '000001.SS', 'SSECompInd';...
    'BAC', 'BankAmer';...
    'C', 'Citigroup';...
    'GS', 'GoldmanSachs';...
    'JPM', 'JPMorgCh';...
    'MS', 'MorgStanl';...
    'BBVA.MC', 'BBVA';...
    'SAN', 'Santander';...
    'CABK.MC', 'Caixabank';...
    'SAB.MC', 'Sabadell';...
    'BNP.PA', 'BNP';...
    'ACA.PA', 'CreditAgricole';...
    'GLE.PA', 'SocieteGenerale';...
    'HSBC', 'HSBC';...
    'BARC.L', 'Barclays';...
    'LLOY.L', 'Lloyds';...
    'RBS.L', 'RoyalBankScot';...
    'MTU', 'MitsubishiBank';...
    'SMFG', 'SumitoBank';...
    'MFG', 'MizuhoBank';...
    '601398.SS', 'ICBC';...
    '601939.SS', 'CBC';...
    '601288.SS', 'ABC';...
    '^GDAXI', 'DAX';...
    '^IXIC', 'NASDAQ';...
    'MSFT', 'Microsoft';...
    'AMZN', 'Amazon';...
    'APPL', 'Apple';... 
    'GOOG', 'Google';...
    'PG', 'Proct&Gamb';...
    'BA', 'Boing'; 
    };

% download the data
if iscell(varargin)
    dtick = varargin{1,:};
else 
    dtick = varargin;
end     

% order the tickers
idx = ismember(ftick, dtick);
rtick = ftick(idx(:, 1), :);
dtick2 = rtick(:, 1);
% error message if we need to update the ftick list
if size(dtick2, 1) ~= size(dtick,2)
    missedTickersloc = ismember(dtick, dtick2);
    missedTickers = strjoin(dtick(~missedTickersloc), ', ');
    error(['There are missed tickers. Consider update the list ',...
        'ftick in the code with the following tickers: ', ...
        missedTickers])
end

% download the data
stocks = hist_stock_data(iniDate,endDate, dtick2);
% Prices
m = size(stocks,2);
disp('Begininig the Fit with Prices')
for i = 1:m
prices = stocks(i).Close; 
disp(['Reading Prices from ', char(string(rtick(i, 2))),...
    ' in ', datestr(datetime(iniDate, 'InputFormat','ddMMyyyy'), ...
    'dd-mm-yyyy'),' to ', datestr(datetime(endDate, ...
    'InputFormat','ddMMyyyy'), 'dd-mm-yyyy')])
% plot the historgrams and qq plots
p = figure('visible', 'off', 'units', 'normalized',...
    'outerposition', [0 0 1 1]);
subplot(2, 2, 1)
dist1 = fitdist(prices, 'lognormal'); 
histfit(prices, 40, 'lognormal'), 
title(['fit to a LogNormal Distribution(',num2str(dist1.mu), ' , ',...
    num2str(dist1.sigma),') from ', char(string(rtick(i, 2)))])
xlabel('value'), ylabel('frecuency')
subplot(2, 2, 3)
qqplot(prices, dist1), 
title(['qqplot from the Lognormal distribution from ',...
    char(string(rtick(i, 2)))])
subplot(2, 2, 2)
dist2 = fitdist(prices, 'weibull');
histfit(prices, 40, 'weibull'), 
title(['fit to Weibull Distribution (',num2str(dist2.A), ' , ',...
    num2str(dist2.B),') from ',char(string(rtick(i, 2)))])
xlabel('value'), ylabel('frecuency')
subplot(2, 2, 4)
qqplot(prices, dist2), 
title(['qqplot from Weibull distribution from ', ...
    char(string(rtick(i, 2)))])
disp(['Saving the plot of fitting test from Prices of ', ...
    char(string(rtick(i, 2)))])
saveas(p, [path, 'goodness of fit of the prices from ', ...
    char(string(rtick(i, 2))), ' in ', datestr(datetime(iniDate,...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'),' to ',...
    datestr(datetime(endDate, 'InputFormat', 'ddMMyyyy'), ...
    'dd-mm-yyyy')], 'jpg')

% some goodness of fit measures
% Anderson-Darling test
[h1, p1, adstat1, cv1] = adtest(prices, 'Distribution', dist1);
 % Kolmogorov - Smirnov test
[h2, p2, ksstat2, cv2] = kstest(prices,'CDF', dist1); 
% Cramer von Mises criterion 
[h3, p3, CvMstat3, cv3] = cmtest(prices, 'CDF', dist1);                     
[h4, p4, adstat4, cv4] = adtest(prices, 'Distribution', dist2);
[h5, p5, ksstat5, cv5] = kstest(prices, 'CDF', dist2);
[h6, p6, CvMstat6, cv6] = cmtest(prices, 'CDF', dist2); 
% tables 
Stats = {'Desicion test'; 'p-value'; 'test statistic';...
    'critical value'};
AD = [h1; p1; adstat1; cv1];
KS = [h2; p2; ksstat2; cv2];
CM = [h3; p3; CvMstat3; cv3];
T  = table(AD, KS, CM, 'RowNames', Stats);
TT1(i).Tbl = T;
TT1(i).Name = ['LogNormal_GoodnessFit_Prices_' , ...
    char(string(rtick(i, 2)))];
disp(['Writing table of fitting test from Prices of ',...
    char(string(rtick(i, 2)))])
% Table from the first distribution 
writetable(T, [path, char(string(rtick(i, 2))),...
    '_LN_GoodnessFit_Prices_', datestr(datetime(iniDate,...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'), '_', ...
    datestr(datetime(endDate, 'InputFormat', ...
    'ddMMyyyy'), 'dd-mm-yyyy'), '.xls'], 'Sheet', 1, ...
    'WriteRowNames', 1)
AD2 = [h4; p4; adstat4; cv4];
KS2 = [h5; p5; ksstat5; cv5];
CM2 = [h6; p6; CvMstat6; cv6];
T2 = table(AD2, KS2, CM2, 'RowNames', Stats); 
TT2(i).Tbl = T2;
TT2(i).Name = ['Weibull_GoodnessFit_Prices_', ...
    char(string(rtick(i, 2)))];
% Table from the second distribution
writetable(T2, [path, char(string(rtick(i, 2))), ...
    '_WB_GoodnessFit_Prices_', datestr(datetime(iniDate, ...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'), '_',...
    datestr(datetime(endDate, 'InputFormat', ...
    'ddMMyyyy'), 'dd-mm-yyyy'), '.xls'], 'Sheet', 1, ...
    'WriteRowNames', 1)
clear prices 
end

% returns
disp('Now continue with the Fit of Returns')
for i = 1:m
rend = price2ret(stocks(i).Close);
disp(['Obtaining Returns from ', char(string(rtick(i, 2))),...
    ' in ', datestr(datetime(iniDate,'InputFormat','ddMMyyyy'),...
    'dd-mm-yyyy'),' to ', datestr(datetime(endDate,'InputFormat',...
    'ddMMyyyy'), 'dd-mm-yyyy')])
p1 = figure('visible', 'off', 'units', 'normalized',...
    'outerposition', [0 0 1 1]);
% plot histogram and qqplot
subplot(2, 2, 1)
dist3 = fitdist(rend, 'normal');
histfit(rend, 40, 'normal'), 
title(['fit to a Normal Distribution(',num2str(dist3.mu),...
    ' , ', num2str(dist3.sigma),') from ', char(string(rtick(i, 2)))]) 
dist4 = fitdist(rend,'tlocationscale');
subplot(2, 2, 2)
histfit(rend, 40, 'tlocationscale'),
title(['fit to a t-location/scale Distribution(',num2str(dist4.mu),...
    ' , ', num2str(dist4.sigma),' , ',num2str(dist4.nu),') from ', ...
    char(string(rtick(i, 2)))]) 
subplot(2, 2, 3)
qqplot(rend) 
title(['qqplot from the Normal ditribution from ',...
    char(string(rtick(i, 2)))])
subplot(2, 2, 4)
qqplot(rend, dist4), 
title(['qqplot from  the ditribution t from ',...
    char(string(rtick(i, 2)))])
disp(['Saving the plot of fitting test from Returns of ', ...
    char(string(rtick(i, 2)))])
saveas(p1, [path,'goodness of fit of the returns from ', ...
    char(string(rtick(i, 2))), ' in ', datestr(datetime(iniDate,...
    'InputFormat','ddMMyyyy'),'dd-mm-yyyy'),' to ', ...
    datestr(datetime(endDate,'InputFormat','ddMMyyyy'),...
    'dd-mm-yyyy')], 'jpg')

% some goodness of fit measures
[h1r, pr1, adstat1r, cv1r] = adtest(rend,'Distribution', dist3);
[h2r, pr2, ksstat2r, cv2r] = kstest(rend,'CDF', dist3);
[h3r, pr3, CvMstat3r, cv3r] = cmtest(rend,'CDF', dist3);
[h4r, pr4, adstat4r, cv4r] = adtest(rend,'Distribution', dist4);
[h5r, pr5, ksstat5r, cv5r] = kstest(rend,'CDF', dist4);
[h6r, pr6, CvMstat6r, cv6r] = cmtest(rend,'CDF', dist4);
% tables
Stats = {'Desicion Test'; 'p-value'; 'test statistic'; ...
    'critical value'};
AD3 = [h1r; pr1; adstat1r; cv1r];
KS3 = [h2r; pr2; ksstat2r; cv2r];
CM3 = [h3r; pr3; CvMstat3r; cv3r];
T3 = table(AD3, KS3, CM3, 'RowNames', Stats);
TT3(i).Tbl = T3;
TT3(i).Name = ['Normal_GoodnessFit_Returns_',...
    char(string(rtick(i, 2)))];
disp(['Writing table of fitting test from Returns of ', ...
    char(string(rtick(i, 2)))])
writetable(T3, [path, char(string(rtick(i, 2))), ...
    '_N_GoodnessFit_Returns_', datestr(datetime(iniDate, ...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'), '_', ...
    datestr(datetime(endDate, 'InputFormat', ...
    'ddMMyyyy'), 'dd-mm-yyyy'), '.xls'], 'Sheet', 1, ...
    'WriteRowNames', 1)
AD4 = [h4r; pr4; adstat4r; cv4r];
KS4 = [h5r; pr5; ksstat5r; cv5r];
CM4 = [h6r; pr6; CvMstat6r; cv6r];
T4 = table(AD4, KS4, CM4, 'RowNames', Stats);
TT4(i).Tbl = T4;
TT4(i).Name = ['T_LocationScale_GoodnessFit_Returns_', ...
    char(string(rtick(i, 2)))];
writetable(T4, [path, char(string(rtick(i, 2))), ...
    '_T_GoodnessFit_Returns_', datestr(datetime(iniDate, ...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'), '_', ...
    datestr(datetime(endDate, 'InputFormat', ...
    'ddMMyyyy'), 'dd-mm-yyyy'), '.xls'], 'Sheet', 1, ...
    'WriteRowNames', 1)
clear rend 
end
end
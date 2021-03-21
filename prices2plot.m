function Gplot = prices2plot(prices, Simul, DateReturns, ...
    inidate, enddate,tickname, ftick, model, path)
% this function only plot prices and the simulation prices
% INPUTS
% prices, simul, variables to plot
% DateReturns, dates downloaded from yahoo
% tickname,ftick, are the ticker of the variable, e.g.,'^GSPC',
% and ftick is the list with the tckers and with long names
% of the ticker,  e.g., ftick = {'^GSPC', 'SP500';...
% '^IBEX', 'IBEX35';...
% '^FCHI', 'CAC40';...
% '^FTSE', 'FTSE100'};
% path is the folder path where the files are saved
% model is the name of the model of the simulated returns, e.g.,
% 'BrowG' refers to the geometric brownian motion. This variable is
% only needed in the name of the plot (only to identify the model)
% Try:
% ftick = {'^GSPC', 'SP500';...
% '^IBEX', 'IBEX35';...
% '^FCHI', 'CAC40';...
% '^FTSE', 'FTSE100'};
% tickname = '^FCHI'
% inidate = '01012008';
% enddate = '01102018';
% model = {'GBM'}
% stocks = hist_stock_data(inidate, enddate, tickname);
% prices = stocks.Close;
% ret = price2ret(prices);
% DateReturns = stocks.Date;
% GBM1 = gbm(mean(ret),std(ret),'StartState', prices(1))
% X = simulate(GBM1, length(ret), 'DeltaTime', 1, 'nTrials', 1);
% P = prices2plot(prices, X, DateReturns, ...
%     inidate, enddate, tickname, ftick, model,...
%     'C:\Users\Desktop\Matlab');

% check the list
idx = ismember(ftick, tickname);
rtick = ftick(idx(:, 1), :);
% get returns
ret = price2ret(prices);
ret = [0; ret];
retsimul = price2ret(Simul);
retsimul = [0; retsimul];
m = size(prices, 1);
% get dates
startDate = datenum(DateReturns(1));
endDate = datenum(DateReturns(size(DateReturns, 1)));
% abcises
xData = linspace(startDate, endDate, size(DateReturns, 1)) ;
m1 = size(xData, 2);
if m1 > m
    xData = linspace(startDate, endDate, size(DateReturns, 1) - 1);
elseif m1 < m
    xData = linspace(startDate, endDate, size(DateReturns, 1) + 1) ;
end
% plot
subplot(2, 2, 1)
plot(xData, [prices, Simul]); xlim([startDate endDate])
datetick('x', 'yyyy', 'keeplimits');
legend ('Real', 'Simulated', 'Location','NorthWest');
title(['Prices real and simulated (',char(string(model)),...
    ') from ' , char(string(rtick(1, 2))), ' in ', ...
    datestr(datetime(inidate,'InputFormat', 'ddMMyyyy'), ...
    'ddmmyyyy'), ' to ', datestr(datetime(enddate, 'InputFormat',...
    'ddMMyyyy'), 'ddmmyyyy')])
ylabel('prices'), xlabel('time')
subplot(2, 2, 2)
plot(xData, [ret, retsimul]); xlim([startDate endDate])
datetick('x', 'yyyy', 'keeplimits');
legend ('Real', 'Simulated', 'Location', 'NorthWest');
title(['Real and simulated Returns(', char(string(model)),...
    ') from ', char(string(rtick(1, 2))), ' in ', ...
    datestr(datetime(inidate,'InputFormat', 'ddMMyyyy'), ...
    'ddmmyyyy'), ' to ', datestr(datetime(enddate, 'InputFormat',...
    'ddMMyyyy'), 'ddmmyyyy')])
ylabel('returns'), xlabel('time')
subplot(2, 2, 3)
histogram(prices,40)
hold on
histogram(Simul,40)
legend ('Real', 'Simulated', 'Location', 'NorthWest');
title(['Real and simulated returns (', char(string(model)),...
    ') from ', char(string(rtick(1, 2))), ' in ', ...
    datestr(datetime(inidate,'InputFormat', 'ddMMyyyy'), ...
    'ddmmyyyy'), ' to ', datestr(datetime(enddate, 'InputFormat',...
    'ddMMyyyy'), 'ddmmyyyy')])
ylabel('frecuancy'), xlabel('value')
subplot(2, 2, 4)
histogram(ret, 40)
hold on
histogram(retsimul, 40)
legend ('Real', 'Simulated', 'Location', 'NorthWest');
title(['Real and simulated returns from ', ...
    char(string(rtick(1, 2))), ' in ',  datestr(datetime(inidate,...
    'InputFormat', 'ddMMyyyy'), 'ddmmyyyy'), ' to ', ...
    datestr(datetime(enddate, 'InputFormat', 'ddMMyyyy'),'ddmmyyyy')])
ylabel('frecuency'), xlabel('value')
Names = {'RealPrices', 'SimulatedPrices', 'RealReturns', ...
    'SimulatedReturns'};
Gplot = timetable(datetime(DateReturns(1:length(prices))),....
    prices, Simul, ret, retsimul);
T = table(prices, Simul, ret, retsimul, 'VariableNames', Names);
writetable(T, [path,char(string(rtick(1, 2))), '_PricesRealSimul_',...
    char(string(model)),'_', datestr(datetime(inidate,'InputFormat', 'ddMMyyyy'), ...
    'ddmmyyyy'), ' to ', datestr(datetime(enddate, 'InputFormat',...
    'ddMMyyyy'), 'ddmmyyyy'),'.xls'], 'Sheet', 1)

% open Activex server
e = actxserver('Excel.Application');
% open file (enter full path!)
ewb = e.Workbooks.Open([path,char(string(rtick(1, 2))), '_PricesRealSimul_',...
    char(string(model)),'_', datestr(datetime(inidate,'InputFormat', 'ddMMyyyy'), ...
    'ddmmyyyy'), ' to ', datestr(datetime(enddate, 'InputFormat',...
    'ddMMyyyy'), 'ddmmyyyy'),'.xls']);
% rename 1st sheet
ewb.Worksheets.Item(1).Name = [char(string(rtick(1, 2))), ...
    '_PrRealSim_', char(string(model))] ;
% save to the same file
ewb.Save
ewb.Close(false)
e.Quit
end
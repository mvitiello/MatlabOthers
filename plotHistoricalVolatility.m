function [historicalVol, returnsHV] = plotHistoricalVolatility(iniDate,...
    endDate, days, path, varargin)
% plotHistoricalVolatility(startDate, endDate, days,...
% varargin) obtain the historical volatility of the prices
% and returns with a moving standard deviation n days,
% where n days is determined with the input 'days'.
% iniDate and endDate are the point in time date that we
% want to start and finish with in the analysis
% varargin determine the tickers that we want in the analysis
% the output is
% historicalVol, returnsHV, historical volatility
% from n days of the prices and returns
% for example try
% [hvp, hvr] = plotHistoricalVolatility('01012008', '31102018',...
%     '^GSPC','000001.SS', 'HSBC', 'SMFG');
% warning, we have a list of tickers  but maybe
% this list need to be updated, we included in the code an
% error message when the ticker is missed: the ticker and
% the name of the variable is required in the ftick variable.

if ~exist(path, 'dir')
    mkdir(path)
end

% list of tickers
% (maybe this list
% need to be updated with the ticker and name required)
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
stocks = hist_stock_data(iniDate, endDate, dtick2);
m = size(stocks, 2);

% prices
p1 = figure('visible', 'off', 'units', 'normalized', ...
    'outerposition', [0 0 1 1]);
disp(['Begininig with HV', num2str(days), 'D from Prices'])
for i = 1:m
    prices = stocks(i).Close;
    disp(['Reading prices from ', char(string(rtick(i, 2))),....
        ' in ', datestr(datetime(iniDate,'InputFormat',...
        'ddMMyyyy'), 'dd-mm-yyyy'), ' to ', ...
        datestr(datetime(endDate, 'InputFormat', 'ddMMyyyy'),...
        'dd-mm-yyyy')])
    % historical volatility
    historicalVol  = movstd(prices, days);
    % dates
    D  = stocks(i).Date;
    sD = datenum(D(1));
    eD = datenum(D(size(D, 1)));
    xD = linspace(sD,eD,size(D, 1));
    m1 = size(xD, 2);
    m2 = size(prices, 1);
    if m1 > m2
        xD = linspace(sD, eD, size(D, 1) - 1);
    end
    
    % plots
    disp(['Ploting HV', num2str(days), 'D from prices of ',...
        char(string(rtick(i, 2)))])
    % to plot we need divide the plot area and this
    % depend on the numebers of variables, i.e., tickers
    switch m
        case 1
            k1 = 1;
            k2 = 1;
        case 2
            k1 = 1;
            k2 = 2;
        case 3
            k1 = 1;
            k2 = 3;
        case 4
            k1 = 2;
            k2 = 2;
        otherwise
            k1 = 2;
            k2 = round(m/2);
    end
    
    subplot(k1, k2, i)
    
    yyaxis left
    plot(xD, prices), xlim([sD eD])
    datetick('x', 'yyyy', 'keeplimits');
    yyaxis right
    plot(xD, historicalVol), xlim([sD eD])
    datetick('x', 'yyyy', 'keeplimits');
    yyaxis left, ylabel('prices')
    legend ('Prices', ['HV', num2str(days), 'D'], ...
        'Location', 'north');
    yyaxis right, ylabel(['HV', num2str(days), 'D'])
    title(['Prices  and HV', num2str(days), 'D from ' , ...
        char(string(rtick(i, 2)))])
    xlabel('Date')
end

saveas(p1, [path, 'Prices and HV', num2str(days),'D from different', ...
    'financial series from ', datestr(datetime(iniDate,'InputFormat',...
    'ddMMyyyy'), 'dd-mm-yyyy'), ' to ', ...
    datestr(datetime(endDate,'InputFormat','ddMMyyyy'),...
    'dd-mm-yyyy')], 'jpg')

% returns

p2 = figure('visible', 'off', 'units', 'normalized', ...
    'outerposition', [0 0 1 1]);

disp(['Now with HV', num2str(days), 'D from returns'])
for i = 1:m
    disp(['Obtaining returns from ',char(string(rtick(i, 2))),...
        ' in ', datestr(datetime(iniDate,'InputFormat','ddMMyyyy'), ...
        'dd-mm-yyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat','ddMMyyyy'), 'dd-mm-yyyy')])
    ret = tick2ret(stocks(i).Close);
    % historical volatility
    returnsHV  = movstd(ret, days);
    % Dates
    D  = stocks(i).Date;
    sD = datenum(D(1));
    eD = datenum(D(size(D, 1)));
    xD = linspace(sD, eD, size(D, 1));
    m3 = size(xD, 2);
    m4 = size(ret, 1);
    if m3 > m4
        xD = linspace(sD, eD, size(D, 1) - 1);
    end
    % plot
    disp(['Ploting HV', num2str(days), 'D from returns of ',...
        char(string(rtick(i, 2)))])
    % to plot we need divide the plot area and this
    % depend on the numebers of variables, i.e., tickers
    switch m
        case 1
            k1 = 1;
            k2 = 1;
        case 2
            k1 = 1;
            k2 = 2;
        case 3
            k1 = 1;
            k2 = 3;
        case 4
            k1 = 2;
            k2 = 2;
        otherwise
            k1 = 2;
            k2 = round(m/2);
    end
    subplot(k1, k2, i)
    yyaxis left
    plot(xD, ret), xlim([sD eD])
    datetick('x', 'yyyy', 'keeplimits');
    yyaxis right
    plot(xD, returnsHV), xlim([sD eD])
    datetick('x', 'yyyy', 'keeplimits');
    yyaxis left, ylabel('Returns')
    legend ('Returns', ['HV', num2str(days), 'D'],....
        'Location', 'north');
    yyaxis right, ylabel(['HV', num2str(days), 'D'])
    title(['Returns and HV', num2str(days), 'D from ' ,...
        char(string(rtick(i, 2)))])
    xlabel('Dates')
end

saveas(p2,[path, 'Returns and HV', num2str(days), 'D from different', ...
    ' financial series from ', datestr(datetime(iniDate,...
    'InputFormat','ddMMyyyy'),'dd-mm-yyyy'), ' to ', ...
    datestr(datetime(endDate,'InputFormat','ddMMyyyy'),...
    'dd-mm-yyyy')], 'jpg')
end
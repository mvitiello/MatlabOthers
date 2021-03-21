function tablePVESRModel = simulateVGandVARES(startDate, ...
    endDate, lambda, path, varargin)

% tablePVESRModel = simulateVGandVARES(startDate, ...
%     endDate, lambda, path, varargin)

% this code calculates (and plot) a "dynamic" VaR and ES
% (using a time horizon window) with Variance - Gamma (VG) Model
% first, calculate the parametric dynamic VaR
% (the code use a "rough" approximation).
% is assumed a 250 days of window
% second, calculate the parametric dynamic VaR and ES
% but calculating the volatility with an EWMA model
%(EWMA requires a lambda value as input, i.e, smoothing parameter)
% Third, calculate the historic (with quantile) dynamic VaR and ES
% a 95 and 99 confidence level is used.
% varargin determine the tickers that we want in the analysis
% iniDate and endDate are the point in time date that we
% want to start and finish with in the analysis
% requires a path folder, the folder path where the files are saved
% finally we obtain as output TableDVaRESRModel, a structure array
% with all Var and ES calculated from the financial series
% the code calculates the VAR and ES with real and simulated returns.
% try, for exmaple:
% tablewithVarESModel = simulateVGandVARES('01012014', ...
%     '01012018', 0.98, 'C:\Users\Desktop\Matlab', '^GSPC','^IBEX',...
%     '^GDAXI', '^IXIC','000001.SS','BNP.PA','BAC','BBVA.MC',...
%     'HSBC','SMFG');
% warning, we have a list of tickers  but maybe
% this list need to be updated, we included in the code an
% error message when the ticker is missed: the ticker and
% the name of the variable is required in the ftick variable.

% check folder
if ~exist(path, 'dir')
    mkdir(path)
end

% list(maybe this list need to be updated with the ticker
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

idx = ismember(ftick, dtick);
rtick = ftick(idx(:,1), :);
dtick2 = rtick(:, 1);
% error message if we need to update the ftick list
if size(dtick2, 1) ~= size(dtick,2)
    missedTickersloc = ismember(dtick, dtick2);
    missedTickers = strjoin(dtick(~missedTickersloc), ', ');
    error(['There are missed tickers. Consider update the list ',...
        'ftick in the code with the following tickers: ', ...
        missedTickers])
end
m = size(dtick2, 1);
ti = year(datetime(startDate,'InputFormat', 'ddMMyyyy')) + 1;


% get the parameters and create the path of prices
for i = 1 : m
    tickname = dtick2(i);
    disp(['Reading Prices from ', char(string(rtick(i, 2))),...
        ' in ', datestr(datetime(startDate, 'InputFormat',...
        'ddMMyyyy'), 'dd-mm-yyyy'),' to ', datestr(datetime(endDate,...
        'InputFormat','ddMMyyyy'), 'dd-mm-yyyy')])
    
    % download prices
    [prices, ~, ret, ~, DateReturns] = GBMSP(startDate, endDate,...
        tickname, ftick, 0);
    S0 = prices(1);
    N = size(ret, 1);
    n = 1;
    pr = readtable([path, char(string(rtick(i, 2))), '_ParamsVG_',...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'),...
        'ddmmyyyy'), '_', datestr(datetime(endDate, 'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'),'.xls'], 'Sheet', 1);
    k = pr.params(1);
    mu = pr.params(2);
    sigma = pr.params(3);
    d = pr.params(4);
    vgPath = simulaVG(S0, k, sigma, mu, d, N, n, 0);
    retVG = price2ret(vgPath);
    model = {'VG'};
    p1 = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition', [0 0 1 1]);
    % plot
    P = prices2plot(prices, vgPath, DateReturns, startDate, ...
        endDate, tickname, ftick, model, path);
    saveas(p1, [path, 'PricesAndReturnsSimulationVGFrom_', ...
        char(string(rtick(i, 2))), ...
        ' in ', datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    % "Static" (quantile) VAR - ES
    p2 = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition', [0 0 1 1]);
    TABLEVARES = VRES(ret, retVG, tickname, ftick, model, ...
        startDate, endDate, 1);
    writetable(TABLEVARES, [path, char(string(rtick(i, 2))), ...
        '_VARESRealSimul_VG_',...
        datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy'), '.xls'], 'Sheet', 1)
    saveas(p2, [path, 'VARESVGReturnsFrom_', char(string(rtick(i, 2))),...
        ' in ', datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    % " Dynamic " Rough Parametric VAR
    p3 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition' , [0 0 1 1]);
    tablePVESRModelR = PVARESNMODEL(ret, DateReturns ,...
        ti, startDate, endDate, tickname, ftick, 0, model, path,...
        d, k);
    tablePVESRModel(i).Name =  [char(string(rtick(i, 2))),'_',...
        datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), '_',...
        datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')];
    tablePVESRModel(i).PVESRMR = tablePVESRModelR;
    saveas(p3, [path,'VARPRVGReturnsFrom_', char(string(rtick(i, 2))),...
        ' in ', datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    p4 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition' , [0 0 1 1]);
    tablePVESRModelS = PVARESNMODEL(retVG, DateReturns ,...
        ti, startDate, endDate, tickname, ftick, 1, model, path,...
        d, k);
    tablePVESRModel(i).PVESRMR = tablePVESRModelS;
    
    saveas(p4, [path,'VARPSVGReturnsFrom_', char(string(rtick(i, 2))),...
        ' in ', datestr(datetime(startDate,'InputFormat',...
        'ddMMyyyy'), 'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    % "Dynamic"  EWMA VAR / ES
    p5 = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition' , [0 0 1 1]);
    tableMEWMANTVESR = VAREWMANT(ret, lambda, DateReturns ,...
        ti, startDate, endDate, tickname, ftick, model, 0, path);
    tablePVESRModel(i).MEWMANTVESR = tableMEWMANTVESR;
    saveas(p5,[path, 'VARESVGEWMAParamAndRealReturnsFrom_',...
        char(string(rtick(i, 2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    p6 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition', [0 0 1 1]);
    tableMEWMANTVESS = VAREWMANT(retVG, lambda, DateReturns ,...
        ti, startDate, endDate, tickname, ftick, model, 1, path);
    tablePVESRModel(i).MEWMANTVESR = tableMEWMANTVESS;
    saveas(p6, [path, 'VARESVGEWMAParamAndSimulatedReturnsVGFrom_',...
        char(string(rtick(i, 2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate, ...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    % " Dynamic" Historical VAR / ES
    p7 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition', [0 0 1 1]);
    tableMHVESR = HVARES(ret, DateReturns, ti,...
        startDate, endDate, tickname, ftick, model, 0, path);
    tablePVESRModel(i).MHVESR = tableMHVESR;
    saveas(p7, [path, 'VARESVGHistRealReturnsFrom_', ...
        char(string(rtick(i, 2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate, ...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    p8 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition',[0 0 1 1]);
    
    disp(['Writing last table VAR/ES from Prices of ',...
        char(string(rtick(i, 2)))])
    
    tableMHVESS = HVARES(retVG, DateReturns, ti,...
        startDate, endDate, tickname, ftick, model, 1, path);
    tablePVESRModel(i).MHVESS = tableMHVESS;
    saveas(p8, [path, 'VARESVGHistSimulatedReturnsVGFrom_', ...
        char(string(rtick(i ,2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    % VAR - Cornish Fisher Expansion
    
    p9 = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition', [0 0 1 1]);
    tableCFNTVR =  CFPVARNT(ret, DateReturns, ti,...
        startDate, endDate, tickname, ftick, model, 0, path);
    tablePVESRModel(i).CFNTVR = tableCFNTVR;
    
    saveas(p9, [path, 'VARCFVGrealreturnsfrom_',...
        char(string(rtick(i, 2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
    p10 = figure('visible', 'off', 'units', 'normalized',...
        'outerposition', [0 0 1 1]);
    disp(['Writing last table VAR/ES from Prices of ',...
        char(string(rtick(i, 2))), ', Model ',...
        char(string(model))]);
    tableCFNTVS = CFPVARNT(retVG, DateReturns, ti,...
        startDate, endDate, tickname, ftick, model, 1, path);
    tablePVESRModel(i).CFNTVS = tableCFNTVS;
    
    saveas(p10, [path, 'VARCFVGsimulatedreturnsVGfrom_',...
        char(string(rtick(i, 2))), ' in ', ...
        datestr(datetime(startDate,'InputFormat', 'ddMMyyyy'), ...
        'ddmmyyyy'), ' to ', datestr(datetime(endDate,...
        'InputFormat', 'ddMMyyyy'), 'ddmmyyyy')], 'jpg')
    
end
end
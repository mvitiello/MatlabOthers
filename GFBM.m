function SS = GFBM(prices,h, tickname, startDate, endDate, path)

% function SS = GFBM(prices,h, tickname, startDate, endDate)

% obtains the simulation of the financial series (prices as input) 
% with a geometric fractional brownian motion (GFBM) 
% using a 'h' (input) Hölder Exponent
% startdate and endDate are the point in time date that we
% want to start and finish with in the analysis.
% tickname is the ticker of the variable, e.g.,'^GSPC',
% requires a path folder, the folder path where the files are saved
% We use the cholesky method to capture the covariance structure 
% and true realization of the FBM
% try
% GBM = gbm(0.003, 0.08, 'StartState', 100);
% X = simulate(GBM, 3*252, 'DeltaTime', 1, 'nTrials', 1);
% SS = GFBM(X,0.73, 'IBEX', '01012016', '10092018');

n = size(prices, 1);
ret = price2ret(prices);
S0 = prices(1);
mu0 = mean(ret);
std0 = std(ret);
dt = 1;
XX = cholesky(n, h); % new FGN 
BB = cumsum(XX);
for t=2:n % new stocks
    SS(1) = S0;
    SS(t) = S0*exp(mu0*dt - 0.5 * std0^2*dt + std0*BB(t));
end
p1 = figure('visible', 'off', 'units', 'normalized',...
    'outerposition', [0 0 1 1]);
subplot(2,2,1)
% first date to a number
iniDate = datenum(datestr(datetime(startDate,'InputFormat',...
    'ddMMyyyy'), 'dd-mm-yyyy'));
% last date to a number
enddate = datenum(datestr(datetime(endDate,'InputFormat',...
    'ddMMyyyy'), 'dd-mm-yyyy'));
% vector of dates
xData = linspace(iniDate, enddate, size(prices, 1));
plot(xData, [SS' prices])
legend('Simulated', 'Real')
xlim([iniDate enddate])
datetick('x', 'yyyy', 'keeplimits');
xlabel('Time'), ylabel('Prices'), 
title(['Prices simulated with a GFBM using a Hölder Exponent = ',...
    num2str(h)])
subplot(2,2,2)
histogram(SS, 40)
hold on
histogram(prices, 40)
legend('Simulated', 'Real')
xlabel('value'), ylabel('Frecuency'), title(['Histogram of Prices'...
    ' in ', datestr(datetime(startDate,...
    'InputFormat', 'ddMMyyyy'), 'dd/mm/yyyy'),'-',...
    datestr(datetime(endDate, 'InputFormat', 'ddMMyyyy'), ...
    'dd/mm/yyyy')])
subplot(2,2,3)
plot(xData, [[0;price2ret(SS)'] [0;price2ret(prices)]])
xlim([iniDate enddate])
datetick('x', 'yyyy', 'keeplimits');
legend('Simulated', 'Real')
xlabel('Time'), ylabel('Returns'), title(['Returns, ',...
    datestr(datetime(startDate,...
    'InputFormat', 'ddMMyyyy'), 'dd/mm/yyyy'),'-',...
    datestr(datetime(endDate, 'InputFormat', 'ddMMyyyy'), ...
    'dd/mm/yyyy')])
subplot(2,2,4)
histogram(price2ret(SS), 40)
hold on
histogram(price2ret(prices), 40)
legend('Simulated', 'Real')
xlabel('value'), ylabel('Frecuency'), title('Histogram of Returns')
saveas(p1, [path, 'Simulation of a Geometric Fractional ',...
    ' Brownian Motion of ', char(string(tickname)), ' in ',...
    datestr(datetime(startDate,...
    'InputFormat', 'ddMMyyyy'), 'dd-mm-yyyy'),' to ',...
    datestr(datetime(endDate, 'InputFormat', 'ddMMyyyy'), ...
    'dd-mm-yyyy')], 'jpg')
end

function X = cholesky(n, h)

% we need a method that completely capture the covariance 
% structure and true realization of the fractional Brownian motion 
% Given that we are dealing with the covariance structure in
% matrix form, it is natural to go with the Cholesky decomposition: 
% decomposing the covariance matrix into the product of a
% lower triangular matrix and its conjugate-transpose 
% inputs
% n = size of the serie
% h = hölder exponent

% n*1 vector with each random element following N(0,1)
V = normrnd(0, 1, [n, 1]);
% covariance matrix of random vector
sigma = zeros(n);
% time span is 1 day
dt = 1;
% start at time 1 and end at time n
for t= 1:n
    for s = 1:n
        ds = t-s;
        % the autocovariance function of Fractional Gaussian Noise
        c = (1/2)*(abs(ds + dt).^(2*h)...
            -2*abs(ds).^(2*h)+ abs(ds - dt).^(2*h));
        sigma(t, s) = c;
    end
end
% Cholesky decomposition
L = chol(sigma,'lower');
% the random vector
X = L * V;
end
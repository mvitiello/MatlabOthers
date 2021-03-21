function XX = poisson(Tmax, varargin)
% Function that generate a Poisson process
% varargin is the number of process that the user need to generate
% Tmax can be interpretaded as the time horizon, for example 1 year
% XX is the output and is structure array with the procces generated
% try, for example: P1 = poisson(1, 25, 45)

% generate the process
% generate the first event
numbersOfProcess = size(varargin, 2);
for i = 1:numbersOfProcess
    X = zeros(1,1);
    XX(i).Pr = X;
    intensity = cell2mat(varargin);
    XX(i).Pr = exprnd( 1 ./ intensity(i) );
    j = 1;
    while XX(i).Pr(j) < Tmax
        XX(i).Pr(j + 1) = XX(i).Pr(j) + exprnd( 1 ./ intensity(i) );
        j = j + 1;
    end
    XX(i).Pr(j) = Tmax;
    % P1 = X;
    R = price2ret(XX(i).Pr(:));
    % plot and graph of the process
    p = figure('visible', 'on', 'units', 'normalized',...
        'outerposition', [0 0 1 1]);
    % to plot we need divide the plot area and this
    % depend on the numebers of variables, i.e., tickers
    subplot(1,2,1)
    stairs(XX(i).Pr(1:j), 0:(j - 1)),
    title(['Poisson process with intensity \lambda = ' ...
        num2str(intensity(i))])
    xlabel('t'), ylabel('N(t)')
    subplot(1,2,2)
    histfit(R, 40, 'exponential'),
    title(['Distribution of the Poisson process "Returns" ',...
        'with intensity  \lambda = ' num2str(intensity(i))])
    xlabel('value'), ylabel('frecuency')
    saveas(p,['Poisson process with intensity ',...
        'of ' num2str(intensity(i))], 'jpg')
end
end
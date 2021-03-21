function XX = poisscompd(T, N, varargin)
% function to generate the compesated Poisson Process
% varargin is the number of process that the user need to generate
% Tmax can be interpretaded as the time horizon, for example 1 year
% N, are the time steps (number of points that 
% the time horizone is divided), for example, days
% XX is the output and is a structure array with the procces generated
% try, for example: P1 = poisscompd(1, 5000, 25, 45)

% the process is generated
h = T/N;
t = (0:h:T);
numbersOfProcess = size(varargin, 2);
intensity = cell2mat(varargin);
for k = 1:numbersOfProcess
    I = zeros(N, 1);
    X = zeros(N + 1, 1);
    XX(k).Pr = X;
    XX(k).Int = I;
    for j = 1:N
        XX(k).Int(j) = pssrnd1(h * intensity(k));
        XX(k).Pr(j + 1) = XX(k).Pr(j) - intensity(k) * h ...
            + XX(k).Int(j);
    end
    
    % plot the process
    p = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition', [0 0 1 1]);
    subplot(1, 2, 1)
    plot(t, XX(k).Pr(:)),
    title(['Compensated Poisson process with ', ...
        'intensity \lambda = ' num2str(intensity(k))])
    xlabel('time'), ylabel('Process')
    subplot(1, 2, 2)
    histfit(XX(k).Pr(:), 40),
    title(['Distribution of the Compensated Poisson process ', ...
        ' with intensity \lambda = ' num2str(intensity(k))])
    xlabel('value'), ylabel('frecuency')
    saveas(p, ['Compensated Poisson Process with ', ...
        ' intensity of ' num2str(intensity(k))], 'jpg')
end
end
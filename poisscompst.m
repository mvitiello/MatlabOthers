function XX = poisscompst(T, N, varargin)
% function that generates the Poisson Process compound
% varargin is the number of process that the user need to generate
% T, can be interpretaded as the time horizon, for example 1 year
% N, are the time steps (number of points that 
% the time horizone is divided), for example, days
% XX is the output and is a structure array with the procces generated
% try, for example: P1 = poisscompst(1, 5000, 25, 45)

% generate the process
h = T/N;
t = (0:h:T);
numbersOfProcess = size(varargin, 2);
intensity = cell2mat(varargin);
for k = 1:numbersOfProcess
    I = zeros(N, 1);
    X = zeros(N + 1, 1);
    F = zeros(N + 1, 1);
    XX(k).Pr = X;
    XX(k).Int = I;
    XX(k).Diff = F;
    for i = 1:N
        XX(k).Int(i) = pssrnd1(h * intensity(k));
        if XX(k).Int(i) == 0
            XX(k).Diff(i) = 0;
        else
            XX(k).Diff(i) = randn;
        end
        XX(k).Pr(i + 1) = XX(k).Pr(i) + XX(k).Diff(i);
    end
    % plot the process
    p = figure('visible', 'off', 'units', 'normalized', ...
        'outerposition', [0 0 1 1]);    
    subplot(1, 2, 1)
    plot(t, XX(k).Pr(:)),
    title(['Poisson Process Compound with ',...
        'intensity \lambda = ' num2str(intensity(k))]),
    xlabel('t'), ylabel('Y(t)')
    subplot(1, 2, 2)
    histfit(XX(k).Pr(:), 40),
    title(['Distribution Poisson Process Compound with ', ... 
        'intensity \lambda = ' num2str(intensity(k))])
    xlabel('value'), ylabel('frecuency')
    saveas(p, ['Poisson Process Compound with intensity of '...
        num2str(intensity(k))], 'jpg')
end
end

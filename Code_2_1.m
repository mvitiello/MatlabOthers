% Brownian Motion  
% Code 2.1. This code is a function that 
% generates a brownian motion path 

% Clear all
clear ; clc; close all
% for example a Brownian motion with 2 years of time horizon
% 504 days and 4 different simulations 
B = brown(2, 504, 4);

function brownian = brown(T, N, M)
% brownian = brown(T1,N,M) generate the path of a brownian motion
% The inputs are 
% T, the " maturity ", i,e., 
% the time horizon, for example T = 2 years 
% N, the time step, i.e, 
% the number of times that T is divided, for
% example, days, N = 504, 
% M, are the numbers of simulations
% Try, for example, B = brown(2, 504, 4); 

% set randomness
rng('shuffle') 
% differential time
dt = T/N; 
% create the initial variables 
dW = zeros(N, M); 
W = zeros(N, M);
% initial conditions
dW(1, :) = sqrt(dt) * randn;
W(1, :) = dW(1); 
% generate the loop
for i = 2:N
    for j = 1:M
        dW(i, j) = sqrt(dt) * randn;
        W(i, j) = W(i - 1, j) + dW(i, j);
    end
end
brownian = W;

% figure
f = figure('visible', 'off', 'units', 'normalized', ...
    'outerposition', [0 0 1 1]);

if M == 1
    subplot(1,2,1)
    X = (0:dt:T)' .* ones(N+1, 1);
    % plot
    plot(X, [zeros(1, M); W]), ylabel ('B(t)'), xlabel('time') 
    title('Brownian motion')
    legend('1º simulation')
else
    for k1 = 1:M
        legendName = strcat(num2str(k1), 'º simulation');
        legendTitle{1, k1} = legendName;
    end
    subplot(1,2,1)
    X = (0:dt:T)' .* ones(N+1, M);
    plot(X, [zeros(1, M); W]), ylabel ('B(t)'), xlabel('time')
    title('Brownian motion')
    legend(legendTitle)
end

subplot(1,2,2)
if M == 1
    histfit(W, 40), title('Distribution of the Brownian process')
    ylabel ('frecuency'), xlabel('value')
    legend('1º simulation')
else
    for k2 = 2:M
        histogram(W(:, 1), 40), 
        title('Distribution of the Brownian process')
        hold on
        histogram(W(:, k2), 40), 
        title('Distribution of the Brownian process')
        ylabel ('frecuency'), xlabel('value')
        legend(legendTitle)
    end    
end
saveas(f, 'Brownian Motion', 'jpg')
end
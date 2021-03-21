function JM = jumpmertonpath(S0, R0, mu, sigma, L, muj,...
    sigmaj, T, NS, NR, plotg)

% The function jumpmertonpath simulate NR price paths 
% with NS points (days) and using a Brownian motion with jumps 
% (following the Merton model). 
% The following INPUTS are needed: 
% mu   = process's drift
% muj  = jump process's drift
% sigma   = process's diffusion (volatility), constant
% sigmaj  = jump process's diffusion (volatility), constant
% S0  = initial price of the path
% R0  = initial return of the path
% T   = period of time, usually daily, i.e t = 1
% NS   = time horizon: points, days, usually 252 days or more  
% NR   = numbers of paths
% plotg is to plot the graphs
% OUTPUT
% assetpath = prices paths (Matrix NS,NR) 
% try
% J = jumpmertonpath(100, -0.02, -0.05, 0.30, 40, 0.02,0.20, 1, ...
% 252, 2, 1)



% generates the process
% initial variables
I = zeros(NR, NS + 1); 
X = zeros(NR, NS + 1); 
X(:,1) = R0; 
F = zeros(NR, NS + 1);
% dt
h = T/NS;
% loop for generate the process
for i = 1 : NR
    for j = 1 : NS
        I(i, j) = pssrnd1(h * L);
            if I(i, j) == 0
                F(i, j) = 0;
            else
                F(i, j) = muj * I(i,j) + sqrt(sigmaj) *...
                    sqrt(I(i, j))* randn;
            end
        X(i, j + 1) = X(i, j) + mu * h + sigma * ...
            sqrt(h)*randn + F(i, j);
    end
end 
J = S0 .* exp(X');
JM = J;
if plotg
% plot the process 
xline = linspace(1, NS + 1, NS + 1);
plot(xline, J),
title('Brownian motion with jumps Bj(t)'), xlabel('time'),...
    ylabel('Sj(t)'), xlim([1 NS + 1])
end
end
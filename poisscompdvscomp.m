function [pcd,PCC]= poisscompdvscomp(L,T,N)
% fucntion that compare the poisson process compensated and compound  
% generate the poisson compensated process
% dt
h =  T / N; 
% time horizon
t = (0: h :T);
% initial varaibles
I = zeros(N, 1); 
X = zeros(N + 1, 1); 
X(1) = 0;
% loop to generate the process
for i = 1 : N
I(i) = pssrnd1(h * L);
X(i+1) = X(i) -L * h + I(i);
end
pcd = X;
% plot the process
p = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(2, 2, 1)
plot(t, X), 
title(['Compensated Poisson Process with intensity \lambda =' num2str(L)]), 
xlabel('t'), ylabel('Ncd')
% generate the poisson Compound process
I2 = zeros(N, 1); 
Y = zeros(N + 1, 1); 
Y(1) = 0; 
F = zeros(N + 1, 1);
% loop to generate the process
for k = 1 : N
I2(k) = pssrnd1(h * L);
if I2(k) == 0
    F(k) = 0;
else
    F(k) = randn;
end
Y(k + 1) = Y(k) + F(k);
end
PCC = Y;
subplot(2, 2, 2)
plot(t, Y), 
title(['Compound Poisson Process with intensity \lambda =' num2str(L)]),
xlabel('t'), ylabel('Y(t)')
subplot(2, 2, [3, 4])
plot(t, X, 'b', t, Y, 'g'), 
title(['Compound and Compensated Poisson Process with intensity \lambda =' num2str(L)]), 
legend('Compensated Poisson','Compound Poisson','Location','southwest')
xlabel('t'), ylabel('Ncd and Y(t)')
saveas(p,'Compensated and Compound Poisson Process','fig')
saveas(p,'Compensated and Compound Poisson Process','jpg')
end
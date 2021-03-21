function pssrndg = pssrnd1(lambda)
% pssrnd1 = pssrnd1(lambda) is a generator of 
% random number of a poisson process 
% initial variables 
X = 0;
Sum = 0;
flag = 0;
% loop
while flag == 0
E = -log(rand);
Sum = Sum + E;
if Sum < lambda
X = X + 1;
else
flag = 1;
end
pssrndg = X;
end
end
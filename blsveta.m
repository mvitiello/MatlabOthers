function veta = blsveta(so,x,r,t,sig,q) 
%   Vt = BLSVETA(SO,X,R,T,SIG) measures the rate of change in the
%   vega with respect to the passage of time.  
%   SO is the current stock price, X is the exercise
%   price, R is the risk-free interest rate, T is the ttm of the
%   option in years, SIG is the standard deviation of the annualized 
%   continuously compounded rate of return of the stock 
%   (aka, "volatility"), and Q is the dividend rate. The default Q is 0.
%       
%   Note: 
%   This function uses normpdf, the normal probability density function 
%   in the Statistics and Machine Learning Toolbox.
%   For example, try v = blsveta(50,50,.12,.25,.3,0)
%   See also BLSPRICE, BLSDELTA, BLSTHETA, BLSRHO, BLSVEGA, BLSLAMBDA.
%
%   Reference:Haug, Espen Gaardner (2007). 
%   The Complete Guide to Option Pricing Formulas. 

if nargin < 5 
  error(message('finance:blsgamma:missingInputs')) 
end 
if any(so <= 0 | x <= 0 | r < 0 | t <=0 | sig < 0) 
  error(message('finance:blsgamma:invalidInputs')) 
end 
if nargin < 6 
  q = zeros(size(so)); 
end 
 
blscheck(so, x, r, t, sig, q);

d1 = (log(so ./ x) + (r - q + sig .^2 ./ 2) .* t)/ (sig .* sqrt(t));
d2 = d1 - sig .* sqrt(t);
veta = -so .* exp(- q .* t)*normpdf(d1).* sqrt(t).* ...
    (q + ((r - q).*d1)./(sig .* sqrt(t)) - ((1 + d1.* d2)./2*t));
end
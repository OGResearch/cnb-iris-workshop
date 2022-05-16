%
% signal = asymmetricCredibility(x, omega1, omega2, k1, k2)
%
% x - inflation from target
% omega1 - left-tail omega (undershooting)
% omega2 - right-tail omega (overshooting)
% k1 - left-tail k (undershooting)
% k2 - right-tail k (overshooting)
%

function s = asymmetricCredibility(dev, varargin)

isSeries = isa(dev, 'tseries') || isa(dev, 'Series');
if isSeries
    store = dev;
    dev = dev.Data(:, 1);
end

for i = 1 : numel(varargin)
    if isscalar(varargin{i})
        varargin{i} = repmat(varargin{i}, size(dev));
    end
end

[omega1, omega2, k1, k2] = varargin{1:4};

s = nan(size(dev));
inxBelow = dev<0;
s(inxBelow) = exp(-(omega1(inxBelow) .* dev(inxBelow)) .^ k1(inxBelow));
s(~inxBelow) = exp(-(omega2(~inxBelow) .* dev(~inxBelow)) .^ k2(~inxBelow));

if isSeries
    s = fill(store, s);
end

end%


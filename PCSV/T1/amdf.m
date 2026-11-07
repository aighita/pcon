function a = amdf(x, m, N, lambdaMax)
a = zeros(lambdaMax + 1, 1);

for lambda = 0 : lambdaMax
    for n = m - N + 1 : m
        a(lambda + 1) = a(lambda + 1) + abs(x(n) - x(n - lambda));
    end
end

a = a ./ N;

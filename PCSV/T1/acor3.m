function r = acor3(x, m, N, lambdaMax)
    r = zeros(lambdaMax + 1, 1);

    for lambda = 0 : lambdaMax
        for n = m - N + 1 : m
            r(lambda + 1) = r(lambda + 1) + x(n) * x(n - lambda);
        end
    end

    r = r ./ N;
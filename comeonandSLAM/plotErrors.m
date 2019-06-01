function plotErrors(oracle, EKF)
    errs = abs(oracle - EKF);
    figure
    hold on
    plot(errs(:, 1), 'r-o')
    plot(errs(:, 2), 'b-o')
    plot(errs(:, 3), 'k-o')
end
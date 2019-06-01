function errs = calcErrors(oracle, EKF)
    errs = abs(oracle - EKF);
    errs(:, 4) = sqrt(sum((oracle(:, 1:2) - EKF(:, 1:2)).^2, 2));
end
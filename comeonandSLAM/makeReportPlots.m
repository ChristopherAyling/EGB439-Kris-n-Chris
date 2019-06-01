close all

% configure vals to test

Rdef = diag([.01 5*pi/180]).^2;
Qdef = diag([.3 4*pi/180]).^2;

vals = [
    0, deg2rad(0);
    0.1, deg2rad(5);
    0.2, deg2rad(10);
    0.3, deg2rad(15);
    0.4, deg2rad(20);
];

% loop through Qs and make plots!

for i = 1:size(vals, 1)
    v = vals(i, :);
    R = Rdef;
    Q = diag([v(1) v(2)]).^2;
    
    figure()
    subplot(1, 2, 1)
    replay;
    
    errs = calcErrors(oracleLocalisations, EKFLocalisations);
    sse = sumSquaredErrors(EKFLocalisations, oracleLocalisations);
    
    subplot(1, 2, 2)
    hold on
    axis square
    grid on
    plot(errs(:, 1), 'r-o')
    plot(errs(:, 2), 'b-o')
    plot(errs(:, 3), 'k-o')
    plot(errs(:, 4), 'm-o')
    legend('x error', 'y error', 'theta error', 'euclidean error')
    xlabel('timestep')
    ylabel('absolute error')
    titletext = ['R Matrix r=', num2str(v(1)),' \beta=',  num2str(rad2deg(v(2))), char(176), ' SSE=', num2str(sse)];
    title(titletext, 'Interpreter', 'tex')
    hold off
end

% loop through Rs and make plots!

for i = 1:size(vals, 1)
    v = vals(i, :);
    R = diag([v(1) v(2)]).^2;
    Q = Qdef;
    
    figure()
    subplot(1, 2, 1)
    replay;
    
    errs = calcErrors(oracleLocalisations, EKFLocalisations);
    sse = sum(errs(:, 4).^2);
    
    subplot(1, 2, 2)
    hold on
    axis square
    grid on
    plot(errs(:, 1), 'r-o')
    plot(errs(:, 2), 'b-o')
    plot(errs(:, 3), 'k-o')
    plot(errs(:, 4), 'm-o')
    legend('x error', 'y error', 'theta error', 'euclidean error')
    xlabel('timestep')
    ylabel('absolute error')
    titletext = ['R Matrix r=', num2str(v(1)),' \beta=',  num2str(rad2deg(v(2))), char(176), 'd SSE=', num2str(sse)];
    title(titletext, 'Interpreter', 'tex')
    hold off
end
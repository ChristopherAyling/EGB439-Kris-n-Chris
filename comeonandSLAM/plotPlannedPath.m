function plotPlannedPath(plannedPath)
    xs = plannedPath(:, 1);
    ys = plannedPath(:, 2);
    plot(xs, ys, 'k--');
end
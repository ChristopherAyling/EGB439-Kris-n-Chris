function [x, y, pgon] = calcCentroid(points)
    xs = points(:, 1);
    ys = points(:, 2);
    pgon = polyshape(xs, ys);
    [x, y] = centroid(pgon);
end

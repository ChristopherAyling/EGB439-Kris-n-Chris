function [xs, ys] = getFigure8Points(xbound, steps)
    A = xbound/sqrt(2);

    ts = linspace(0, 2*pi, steps);

    xs = zeros(1, steps);
    ys = zeros(1, steps);

    i = 1;
    for t = ts
        xs(i) = (A*sqrt(2)*cos(t))/((sin(t)^2)+1);
        ys(i) = (A*(sqrt(2))*cos(t)*sin(t))/(((sin(t)^2)+1));
        i = i+1;
    end
end


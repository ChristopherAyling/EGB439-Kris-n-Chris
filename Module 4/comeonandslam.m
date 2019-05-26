% arena and robot initialisation
Pb = PiBot('172.19.232.102', '172.19.232.11', 32);
Pb.resetEncoder();

hasCalculatedLocation = false;


% main loop
dt = 0.25;
while True
    % predict step
    
    % update step
    
    % decide on next step
    
    if hasCalculatedLocation
       % move to calculated rover location (centroid of sensed landmarks) 
    end
    
    pause(dt)
end
Pb.stop()

% helper functions

function [x, y, pgon] = calcCentroid(points)
    xs = points(:, 1);
    ys = points(:, 2);
    pgon = polyshape(xs, ys);
    [x, y] = centroid(pgon);
end

function [d, dth] = get_odom(q, ticks)
    %NEWPOSE calculate d and dth from encoder ticks
    % robot constants
    tpr = 370; % ticks per rotation
    R = 0.0325; % radius of wheels
    L = 0.16; % wheel base

    % deconstruct pose
    x = q(1);
    y = q(2);
    theta = q(3);
    
    % calculate wheel distances
    distances = 2*pi*R*(ticks/tpr);
    dl = distances(1);
    dr = distances(2);
    
    % calculate distances from ticks
    d = (dl+dr)/2;
    dth = wrapToPi((dr-dl)/L);
end
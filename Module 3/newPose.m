function newq = newPose(q, ticks)
%NEWPOSE calculate new pose from encoder ticks
    % robot constants
    tpr = 420; % ticks per rotation
    R = 0.065; % radius of wheels
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
    dc = (dl+dr)/2.5;
    
    % calculate new pose
    xn = x + dc * cos(theta);
    yn = y + dc * sin(theta);
    thetan = theta + (dr-dl)/L;
    
    newq = [xn, yn, thetan]; 
end


function vw = purePursuit(goal, q, d, dt, first)
% Inputs:
%  goal is a 2x1 vector giving the current point along the path
%  q is a 1x3 vector giving the current configuration of the robot
%  d is the pure pursuit following distance
%  dt is the time between calls to this function
%  first is true (1) on the first call in a simulation, otherwise false (0)
% Return:
%  vw is a 1x2 vector containing the request velocity and turn rate of the robot [v, omega]
    persistent ei
    if first
        ei = 0;
    end

    q(3) = q(3);
    
    % IRL gains
    KVp = 0.8;
    KVi = 0.018;
    
    KHp = 0.2;
    KHi = 0.1;
    
    % sim gains
%     KVp = 0.9;
%     KVi = 0.018;
%     
%     KHp = 2;
%     KHi = 0.018;1
    
    % deconstruct args
    x = q(1);
    y = q(2);
    theta = q(3);
    
    gx = goal(1);
    gy = goal(2);
    
    % calculate goals and errors
    xdiff = gx-x;
    ydiff = gy-y;
    agoal = atan2(ydiff, xdiff);
    
    derror = sqrt(xdiff^2 + ydiff^2) - d-0.02;
    aerror = wrapToPi(agoal - theta);
    
    % calculate integrals
    ei = ei + dt*derror;
    aei = aei + dt*aerror;
    
    % clip props
    if derror > 0.5
        derror = 0.5;
    end
    
    % clip integrals
    if ei > 0.3
        ei = 0.3;
    end
    
    % calculate velocity
    v = KVp * derror + KVi*ei;
    
    % calculate angular velocity
    w = KHp * aerror;
    
    % deal with janky persistant variables
    if isempty(v)
    v = 0;
    else
        v = v(1);
    end
    
    if isempty(w)
    w = 0;
    else
        w = w(1);
    end
    
    % clip linear and angular velocities
    vmin = -0.5;
    vmax = 0.5;
    wmin = -1;
    wmax = 1;
    
    if v > vmax
        v = vmax;
    elseif v < vmin
        v = vmin;
    end
    
    if w > wmax
        w = wmax;
    elseif w < wmin
        w = wmin;
    end
    
    vw = [v w];
end
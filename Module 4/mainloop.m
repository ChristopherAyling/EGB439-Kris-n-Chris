% goal counting
completeGoals = 0;
totalGoals = 2;

% arena and robot initialisation
Pb = PiBot('172.19.232.102', '172.19.232.11', 32);
Pb.resetEncoder();

sensed = [];

start = [1 1 deg2rad(90)];
q = start;

landmarks = [
    30 2 0.1;
    45 1 0.1;
    27 0.1 0.1;
    57 1.7 1.9;
    39 0.4 1.9;
];

unloadingAreas = [
    0.5 0.8 deg2rad(45);
    1.5 0.8 deg2rad(135);
];

% tracking of poses and covariances
scovs = [];
sqs = [];

% setup purepursuit
goal = unloadingAreas(1, :);
d = 0.05;
dt = 0.2;
fd = 0.12;
first = true;

pixelsInM = 50;
goalInPx = round(goal(1:2) * pixelsInM);
startInPx = round(start(1:2) * pixelsInM);

nav = zeros(100);
dx = DXform(nav);
dx.plan(goalInPx);
p = dx.query(startInPx);
plannedPath = p/50;

a = 1;
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% setup EKF localisation
S = diag([1 1 5*pi/180]).^2;
R = diag([.01 3*pi/180]).^2;
Q = diag([3 20*pi/180]).^2;

while true
    % update mu and Sigma
    q = q';
    [dtravelled, dtheta] = findChange(q, tickPose(q, Pb));
    [q, S] = predictStep(q, S, dtravelled, dtheta, R);
    [z, map, sensedd] = sense(q, Pb, landmarks);
    sensed = [sensed; sensedd];
    [q, S] = updateStep(map, z, q, S, Q);
    q = q';
%     q = tickPose(q, Pb);
    sqs = [sqs; q];
    scovs = [scovs; S];
    
    % update purepursuit
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]';
    loc = [q(1), q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd; % dist from current goal < following dist
    as = 0;
    while closeEnough && as < 20
        as = as + 1;
        disp("updating a")
        a = min(a+1, length(plannedPath)); % set next point on path as current goal
        % calculate current goal
        currentX = plannedPath(a, 1);
        currentY = plannedPath(a, 2);
        currentGoal = [currentX currentY]';
        dist = pointDist(loc, currentGoal');
        closeEnough = dist < fd; % dist from current goal < following dist
    end
    
    % if at goal location
    distFromGoal = pointDist(q(1:2), goal(1:2));
    atGoalLocation = distFromGoal < 0.1;
    if atGoalLocation
        disp("at goal location")
        Pb.setVelocity([30 30], 0.4)
        Pb.stop();
        % rotate to goal orientation
        angleFromBeacon = rad2deg(q(3) - goal(3));
        atGoalOrientation = angleFromBeacon < 10 && angleFromBeacon > -10;
        while ~atGoalOrientation
            disp("rotating to face desired direction")
            if angleFromBeacon < 0 % rotate the fastest direction
                vel = [-1 1];
            else
                vel = [1 -1];
            end
            velMul = 10; %vel speed
            Pb.setVelocity(vel*velMul);
            q = tickPose(q, Pb);
            sqs = [sqs; q];
            plotArena(sqs, scovs, unloadingAreas, landmarks(:, 2:end), plannedPath, []);
            angleFromBeacon = rad2deg(q(3) - goal(3));
            atGoalOrientation = angleFromBeacon < 10 && angleFromBeacon > -10;
            pause(0.25);
        end
        % pause for 5 seconds
        disp("pausing for 5 seconds")
        Pb.stop()
        pause(5);
        
        % check if done all goals
        disp("moving to next goal")
        completeGoals = completeGoals + 1;
        if completeGoals >= totalGoals
            disp("number of complete goals is equal to the total number of goals; exiting.")
           break; 
        end
        
        % set new goal
        disp("setting new goal");
        goal = unloadingAreas(2, :);
        goalInPx = round(goal(1:2) * pixelsInM);
        startInPx = round(q(1:2) * pixelsInM);

        nav = zeros(100);
        dx = DXform(nav);
        dx.plan(goalInPx);
        p = dx.query(startInPx);
        plannedPath = p/50;
        a = 1;
        
        plotArena(sqs, scovs, unloadingAreas, landmarks(:, 2:end), plannedPath, sensed);
    end
    
    % calculate new velocities
    vw = purePursuit(currentGoal, q, d, dt, first); first = false;
    vel = vw2wheels(vw, true);
    
    % set new velocities
    Pb.setVelocity(vel);
    
    % plot graphics
    disp("plotting")
    plotArena(sqs, scovs, unloadingAreas, landmarks(:, 2:end), plannedPath, sensed);
    pause(dt);
end
Pb.stop()

function [xt,S] = predictStep(xt,S,d,dth,R)
    x = xt(1);
    y = xt(2);
    theta = xt(3);

    xt = [
        x+(d*cos(theta));
        y+(d*sin(theta));
        wrapToPi(theta+dth);
    ];

    Jx = [
        1 0 -d*sin(theta);
        0 1 d*cos(theta);
        0 0 1;
    ];

    Ju = [
        cos(theta) 0;
        sin(theta) 0;
        0 1;
    ];

    S = Jx*S*Jx' + Ju*R*Ju'; 
end

function [x,S] = updateStep(map,z,x,S,Q)
    for i=1:size(z,1)
        xr = x(1);
        yr = x(2);
        theta = x(3);
        lm = map(i,:);

        r = z(i, 1);
        b = z(i, 2);

        xl = lm(1);
        yl = lm(2);

        G = [
            -(xl-xr)/r, -(yl-yr)/r, 0;
            (yl-yr)/(r*r), -(xl-xr)/(r*r), -1;
        ];

        h = [
            sqrt((xl-xr)^2+(yl-yr)^2)
            wrapToPi(atan2(yl-yr, xl-xr)-theta)
        ];

        K = S*G'*(G*S*G' + Q)^-1;

        err = z(i, :)-h';
        err = [err(1); wrapToPi(err(2))]
        x = x + K*(err);
        x = [x(1), x(2), wrapToPi(x(3))]';
        S = (eye(length(K)) - K*G)*S;
    end
end

function [d, dth] = findChange(q1, q2)
    % Returns d (change) and dtheta (change) from previous q and present
    % x y th
    if ~isreal(q1) || ~isreal(q2)
       disp("the findChange function was passed an imaginary number") 
    end
    x = [q1(1), q2(1)];
    y = [q1(2), q2(2)];
    th = [q1(3), q2(3)];
    
    d = pointDist(q1(1:2)', q2(1:2));
    dth = th(2) - th(1);
    if ~isreal(d) || ~isreal(dth)
       disp("the findChange function made an imaginary number") 
    end
end
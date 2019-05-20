% goal counting
completeGoals = 0;
totalGoals = 2;

% arena and robot initialisation
Pb = PiBot('172.19.232.102', '172.19.232.11', 32);
Pb.resetEncoder();

start = [1 1 deg2rad(90)];
q = start;

landmarks = [
    0.1 0.1;
    1.9 1.9;
    0.1 1.9;
    1.9 0.1;
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
Q = diag([.1 3*pi/180]).^2;

while true
    % update mu and Sigma
%     dtravelled = 
%     dtheta = 
%     [q, S] = predictStep(q, S, dtravelled, dtheta, R);
%     z = []; % to do
%     [q, S] = updateStep(landmarks, z, q, S, Q);
    q = tickPose(q, Pb);
    sqs = [sqs; q];
    
    % update purepursuit
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]';
    loc = [q(1), q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd; % dist from current goal < following dist
    as = 0
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
        % rotate to goal orientation
        angleFromBeacon = rad2deg(bearing([q(1) q(2)], goal, q(3)));
        atGoalOrientation = angleFromBeacon < 10 && angleFromBeacon > -10;
        while ~atGoalOrientation
            disp("rotating to face desired direction")
            if angleFromBeacon < 0 % rotate the fastest direction
                vel = [1 -1];
            else
                vel = [-1 1];
            end
            velMul = 10; %vel speed
            Pb.setVelocity(vel*velMul);
            q = tickPose(q, Pb);
            angleFromBeacon = rad2deg(bearing([q(1) q(2)], goal, q(3)));
            atGoalOrientation = angleFromBeacon < 10 && angleFromBeacon > -10;
            pause(0.25);
        end
        % pause for 5 seconds
        Pb.stop()
        pause(5);
        
        % check if done all goals
        completeGoals = completeGoals + 1;
        if completeGoals >= totalGoals
            disp("number of complete goals is equal to the total number of goals; exiting.")
           break; 
        end
        
        % set new goal
        disp("setting new goal");
        goal = unloadingAreas(2, :);
        goalInPx = round(goal(1:2) * pixelsInM);
        startInPx = round(start(1:2) * pixelsInM);

        nav = zeros(100);
        dx = DXform(nav);
        dx.plan(goalInPx);
        p = dx.query(startInPx);
        plannedPath = p/50;
        a = 1;
    end
    
    % calculate new velocities
    vw = purePursuit(currentGoal, q, d, dt, first); first = false;
    vel = vw2wheels(vw, true);
    
    % set new velocities
    Pb.setVelocity(vel);
    
    % plot graphics
    disp("plotting")
    plotArena(sqs, scovs, unloadingAreas, landmarks);
    pause(dt);
end
Pb.stop()

function [xt,S] = predict_step(xt,S,d,dth,R)

end

function [x,S] = update_step(map,z,x,S,Q)

end
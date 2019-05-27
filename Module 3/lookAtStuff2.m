Pb = PiBot('172.19.232.170', '172.19.232.11', 32);
Pb.resetEncoder();

ticktracker = [];

% set up plotting
clf
figure(1)
axis square;
grid on
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on

% initialise
q = [0.1, 0.1, 0];
start = [q(1), q(2)];
startTheta = q(3);
startTheta = degtorad(startTheta);
q = [start, startTheta];
first = true;

goal = [0.6 1.2]; % set goal here

% landmarks
landmarks = containers.Map();
landmarks(dec2bin(27, 6)) = [1.7; 1.9];
landmarks(dec2bin(39, 6)) = [0.3; 1.9];
landmarks(dec2bin(45, 6)) = [0.1; 0.1];
landmarks(dec2bin(30, 6)) = [1; 0.1];
landmarks(dec2bin(57, 6)) = [1.9; 0.1];

plotLandmarks(landmarks)

% EKF Localisation setup
Sigma = diag([1 1 10*pi/180]).^2;
R = diag([.01 3*pi/180]).^2;
Q = diag([.1 10*pi/180]).^2;

% convert from real to px units
pixelsInM = 50;
goalInPx = round(goal * pixelsInM);
startInPx = round(start * pixelsInM);

% compute path using distance transform
nav = zeros(100);
dx = DXform(nav);
dx.plan(goalInPx);
p = dx.query(startInPx);
plannedPath = p/50;

% other config
dt = 0.2;
a = 1;
d = 0.05;
fd = 0.12;
steps = 100;

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% run
plotBotFrame(q);
plotPlannedPath(plannedPath);
for i = 1:steps
    % get ticks and estimate new pose
    ticks = Pb.getEncoder();
    Pb.resetEncoder();
    q = newPose(q, ticks);
    
    % see if reached current goal
    loc = [q(1), q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd; % dist from current goal < following dist
    while closeEnough
        a = min(a+1, length(plannedPath)); % set next point on path as current goal
        % calculate current goal
        currentX = plannedPath(a, 1);
        currentY = plannedPath(a, 2);
        currentGoal = [currentX currentY]';
        dist = pointDist(loc, currentGoal');
        closeEnough = dist < fd; % dist from current goal < following dist
    end
    
    % run controller
    vw = purePursuit(currentGoal, q, d, dt, first);
    first = false;
    vel = vw2wheels(vw, true);
    
    % set velocities
    Pb.setVelocity(vel*1.5);
    
    % check if done
    pd = pointDist(loc, goal);
    minPhotoDist = 0.3;
    if pd < minPhotoDist
        disp("close enough to goal point")
        Pb.stop()
        % turn to face beacon
        angleFromBeacon = rad2deg(bearing([q(1), q(2)], goal, q(3)));
        Pb.resetEncoder();
        while ~(angleFromBeacon < 10 && angleFromBeacon > -10)
            % rotate and estimate pose
            disp("rotating to face desired direction")
            if angleFromBeacon < 0 % rotate the fastest direction
                vel = [1 -1];
            else
                vel = [-1 1];
            end
            velMul = 10; %vel speed
            Pb.setVelocity(vel*velMul);
            ticks = Pb.getEncoder();
            Pb.resetEncoder();
            q = newPose(q, ticks);
            plotBotFrame(q);
            % check angle error
            angleFromBeacon = rad2deg(bearing([q(1), q(2)], goal, q(3)));
            pause(0.25)
        end
        % begin doing laps
        disp("doing laps")
        c = 0;
        maxSteps = 125;
        mu = q;
        while c < maxSteps
            c = c + 1;
            ticks = Pb.getEncoder();
            ticktracker = [ticktracker, ticks];
            Pb.resetEncoder();
            Pb.setVelocity([50 35]/2);
            q = newPose(q, ticks);
            [d, dth] = get_odom(mu, ticks);
            % predict step
            [mu, Sigma] = predict_step(mu, Sigma, d, dth, R);
            
            % take photo
            img = Pb.getImage();
            plotBotFrame(q);
            
            % analyse photo
            [binaryCode, centroidLocations] = identifyBeaconId(img);
            % process results
            z = containers.Map();
            for idx=1:length(binaryCode)
                if binaryCode(idx) ~= -1 && binaryCode(idx) ~= 54
                  
                    range = beaconDistance(centroidLocations(idx,:));
                    b = beaconBearing(centroidLocations(idx,:));
                    b = deg2rad(b);
                    x = q(1);
                    y = q(2);
                    t = q(3);
                    loc = [
                        x + range * cos(t + b)
                        y + range * sin(t + b)
                    ];

                    plotBeacon(loc, binaryCode(idx))
                    z(dec2bin(binaryCode(idx), 6)) = loc;
                end
            end
            % update step
            [mu, Sigma] = update_step(landmarks, z, mu, Sigma, Q);
            plot(mu(1), mu(2), 'bp', 'MarkerSize', 8)
            plot_cov(mu, Sigma, 3)
            pause(0.2)
        end
        break 
    end
    
    % graphics
    plot(currentX, currentY, 'kp')
    plotBotFrame(q);
    
    pause(dt)
end

% cleanup
Pb.stop();
hold off

% helper functions
function plotPlannedPath(plannedPath)
    pathY = plannedPath(:,1);
    pathX = plannedPath(:,2);
    plot(pathY, pathX, 'k--');
end

function r = range_(p1, p2)
    %RANGE distance between two points
    % _ is there as range is a built in function
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    
    r = sqrt((x1-x2)^2 + (y1-y2)^2);
end

function [xt,S] = predict_step(xt,S,d,dth,R)
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

function [x,S] = update_step(map,Z,x,S,Q)
    zks = keys(Z);
    mks = keys(map);
    
    for i=1:length(Z)
        z = Z(zks{i})';
        xr = x(1);
        yr = x(2);
        theta = x(3);
        lm = map(zks{i})';

        r = z(1);
        b = z(2);

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

        err = z(:)-h';
        err = [err(1); wrapToPi(err(2))];
        x = x + K*(err);
        x = [x(1), x(2), wrapToPi(x(3))]';
        S = (eye(length(K)) - K*G)*S;
    end
end

function plot_cov(x,P,nSigma)
    disp("plotting cov")
    P = P(1:2,1:2);
    x = x(1:2);
    if(~any(diag(P)==0))
        disp("plotting cov with diag")
        [V,D] = eig(P);
        y = nSigma*[cos(0:0.1:2*pi);sin(0:0.1:2*pi)];
        el = V*sqrtm(D)*y;
        el = [el el(:,1)]+repmat(x,1,size(el,2)+1);
        line(el(1,:),el(2,:), 'Color', [0.3010 0.7450 0.9330], 'LineStyle', '--', 'LineWidth', 1.5);
    end
end
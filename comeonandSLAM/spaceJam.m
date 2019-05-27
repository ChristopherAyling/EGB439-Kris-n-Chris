Pb = PiBot('172.19.232.125');
Pb.setLEDArray(bin2dec('0000000000000000'))
Pb.resetEncoder();

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
landmarks(dec2bin(30, 6)) = [1; 1.9];
landmarks(dec2bin(45, 6)) = [1.9; 1.7];
landmarks(dec2bin(27, 6)) = [0.1; 1];
landmarks(dec2bin(39, 6)) = [1; 0.1];
landmarks(dec2bin(57, 6)) = [1.9; 0.1];

plotLandmarks(landmarks)

% EKF Localisation setup
Sigma = diag([1 1 5*pi/180]).^2;
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
prevEncoder = [0 0];

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% run
plotBotFrame(q);
plotPlannedPath(plannedPath);
for i = 1:steps
    % get ticks and estimate new pose
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
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
            % rotate the fastest direction
            if angleFromBeacon < 0; vel = [1 -1];
            else; vel = [-1 1]; end
            % set speed
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
        Pb.setVelocity([50 35]/2);
        Pb.setLEDArray(bin2dec('1111111100000000'))
        while c < maxSteps
            c = c + 1;
            % get ticks and calculate odometry
            encoder = Pb.getEncoder();
            ticks = encoder-prevEncoder;
            prevEncoder = encoder;
            [d, dth] = get_odom(mu, ticks);
            
            % predict step
            [mu, Sigma] = predictStep(mu, Sigma, d, dth, R);
            
            % take photo
            img = Pb.getImage();
            
            % analyse photo
            [binaryCode, centroidLocations] = identifyBeaconId(img);
            % process results
            z = containers.Map();
            for idx=1:length(binaryCode)
                if binaryCode(idx) ~= -1 && binaryCode(idx) ~= 54
                  
                    range = beaconDistance(centroidLocations(idx,:));
                    b = beaconBearing(centroidLocations(idx,:));
                    x = mu(1);
                    y = mu(2);
                    t = mu(3);
                    loc = [
                        x + range * cos(t + b)
                        y + range * sin(t + b)
                    ];

                    plotBeacon(loc, binaryCode(idx))
                    z(dec2bin(binaryCode(idx), 6)) = loc;
                end
            end
            % update step
            [mu, Sigma] = updateStep(landmarks, z, mu, Sigma, Q);
            plot(mu(1), mu(2), 'bp', 'MarkerSize', 8)
            plotBotFrame(mu(1:3))
            plot_cov(mu, Sigma, 3) 
            pause(0.2)
        end
        % move to centroid
%         centroid = 
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
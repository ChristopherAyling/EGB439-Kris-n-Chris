%{
    Look at me still talking when there's science to do
    When I look out there
    It makes me glad I'm not you
    I've experiments to be run
    There is research to be done
    On the people who are
    Still alive.
%}

qs = [];

Pb = PiBot('172.19.232.125');
Pb.setLEDArray(bin2dec('0000000000000000'))
Pb.stop()
Pb.resetEncoder();

% set up plotting
clf
figure(1)
axis square;
grid on
ARENASIZE = [2, 2];
zoom = 0;
axis([0 ARENASIZE(1) 0 ARENASIZE(2)] + [-1 1 -1 1]*zoom)
hold on

% landmark initialisation
landmarks = containers.Map();
landmarks(dec2bin(27, 6)) = [1.9; 1.3];
landmarks(dec2bin(39, 6)) = [1.9; 1.0];
landmarks(dec2bin(45, 6)) = [1.9; 0.7];
plotLandmarks(landmarks)

% initialise
mu = [0.5; 1; 0];
start = [mu(1), mu(2)];
startTheta = mu(3);
startTheta = degtorad(startTheta);
mu = [start, startTheta];
first = true;

goal = [1.5 1]; % set goal here

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
prevEncoder = [0 0];
scanSteps = 0;
desiredScanSteps = 100;

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% initialise mode_
mode_ = "moving";

takenPath = [mu(1:3)];
idKeys = [-1, -2, -3, -4, -5];
idBeacons = [30, 57, 27, 39, 45];
idValues = [1, 2, 3, 4, 5];
landmarkIDs = containers.Map(idKeys, idValues);
currentID = -1;

seenLandmarks = [0, 0, 0, 0, 0];
seenLandmarks = containers.Map(idValues, seenLandmarks);

% EKF Initialisations 
Sigma = diag([0.1 0.1 0.1*pi/180]).^2;
R = diag([.01 10*pi/180]).^2; % dependant variable
Q = diag([.15 4*pi/180]).^2; % dependant variable

disp("And when you're dying I'll be still alive")
while true
    % get ticks and estimate new pose
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, dth] = get_odom(mu(1:3), ticks);
    
    % Predict Step
    [mu, Sigma] = predictStepReport(mu, Sigma, d, dth, R);
    
    % Sense Step
    img = Pb.getImage();
    [binaryCode, centroidLocations] = identifyBeaconId(img);
    z = [beaconDistance(centroidLocations(i, :)); beaconBearing(centroidLocations(i, :))];
    
    % Update Step
    [mu, Sigma] = updateStepReport(landmarks, z, mu, Sigma, Q);    
    
    
    % predict step
    disp("Running predict step (predict_slam):")
    [mu, Sigma] = predict_slam(mu, Sigma, d, dth, R);
    
    
    % ----------- Not Sure About the stuff below this comment -----------
    
    % record calculated pose
    takenPath = [takenPath; mu(1:3)'];
    
    % calculate next movement
    loc = mu(1:2);
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd;
    while closeEnough
        disp("updating a")
        a = min(a+1, length(plannedPath)); % set next point on path as current goal
        % calculate current goal
        currentX = plannedPath(a, 1);
        currentY = plannedPath(a, 2);
        currentGoal = [currentX currentY]';
        dist = pointDist(loc, currentGoal');
        closeEnough = dist < fd; % dist from current goal < following dist
    end

    disp("movement: pure pursuiting")
    vw = purePursuit(currentGoal, mu(1:3), d, dt, first); first = false;
    disp("pure pursuiting")
    %vw = purePursuit(currentGoal, q, d, dt, first); first = false;
    vel = vw2wheels(vw, true);
    Pb.setVelocity(vel)  
    
    % Check if reached goal
    loc = mu(1:2);
    distanceFromGoal = pointDist(loc', goal);
    minDistanceFromGoal = 0.5;
    if distanceFromGoal < minDistanceFromGoal
        % change mode_ to scan
        mode_ = "complete";
    end
    
    % graphics
    disp("making pretty pictures")
    clf
    axis square;
    grid on
    ARENASIZE = [2, 2];
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)] + [-1 1 -1 1]*zoom)
    hold on
    
    % plot robot frame
    plotBotFrame(mu(1:3))
    % plot robot covariance
    plot_cov(mu(1:3), Sigma(1:3, 1:3), 3)
    % plot landmark mus & covs
    plot_landmarks(mu(4:end), Sigma(4:end, 4:end))
    
    % plot planned path
    plot(currentX, currentY, 'kp')
    plotPlannedPath(plannedPath)
    
    % plot path taken
    plotTakenPath(takenPath)
    
    % temp
    q = newPose(mu(1:3), ticks);
    qs = [qs; q];
    plotTakenPath(qs);
    
    % LEDS
    displayMode(mode_, Pb);
    
    % break out of loop if everything is done
    if mode_ == "complete"; break; end
    pause(dt);
end

Pb.stop();
disp("And when you're dead I will be still alive")
%{
    Everybody get up it's time to slam now
    We got a real jam goin' down
    Welcome to the Space Jam
    Here's your chance do your dance at the Space Jam
    Alright
%}

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
mu = [0.1, 0.1, 0];
start = [mu(1), mu(2)];
startTheta = mu(3);
startTheta = degtorad(startTheta);
mu = [start, startTheta];
first = true;

goal = [0.6 1.2]; % set goal here

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

% EKF SLAM Initialisation
Sigma = diag([1 1 5*pi/180]).^2;
R = diag([.01 3*pi/180]).^2;
Q = diag([.1 10*pi/180]).^2;

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
mode_ = "setup";

takenPath = [mu(1:3)];

idKeys = [30, 57, 27, 39, 45];
idValues = [1, 2, 3, 4, 5];
landmarkIDs = containers.Map(idKeys, idValues);
currentID = -1;

disp("beginning mission")
while true
    disp("mode: " + mode_)
    % get ticks and estimate new pose
    disp("calculating [d, dth] using odometry")
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, dth] = get_odom(mu, ticks);
    
    % predict step
    disp("running predict step")
    [mu,Sigma] =predict_slam(mu, Sigma, d, dth, R);
    
    % sense
        % take photo
    img = Pb.getImage();
        % process image
        % if we see a never before seen, run init landmarks
    [binaryCode, centroidLocations] = identifyBeaconId(img);
    for i = 1:length(binaryCode)
        if ismember(binaryCode(i), idKeys)
            % Map landmark id to currentID (for easier indexing)
            currentID = landmarkIDs(binaryCode(i));
            % range and bearing / z
            z = [beaconDistance(centroidLocations(i, :)); beaconBearing(centroidLocations(i, :))];
            % update step 
            [mu, Sigma] = update_slam(currentID, z, mu, Sigma, Q);
        end
    end
    
    % record calculated pose
    takenPath = [takenPath; mu(1:3)'];
    
    % calculate next movement
    switch mode_
        case "scan"
            disp("movement: going in circle")
            Pb.setVelocity([50 35]/2)
        otherwise
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
            vel = vw2wheels(vw, true);
            Pb.setVelocity(vel)
    end    
    
    % do some thinking and planning
    switch mode_
        case "setup"
            % check if in location to start scanning
            loc = mu(1:2);
            distanceFromGoal = pointDist(loc, goal);
            minDistanceFromGoal = 0.3;
            if distanceFromGoal < minDistanceFromGoal
                % change mode_ to scan
                mode_ = "scan";
            end
            
        case "scan"
            scanSteps = scanSteps + 1;
            % check if done scanning
            if scanSteps >= desiredScanSteps
                % change mode_ to "d2c"
                mode_ = "d2c";
            end
            
        case "d2c"
            % calculate centroid (goal)
            disp("calculating centroid")
            points = mu2points(mu(4:end));
            [centroid, pgon] = calcCentroid(points);
            goal = centroid;
            % check if at centroid
            loc = mu(1:2);
            distanceFromGoal = pointDist(loc, goal);
            minDistanceFromGoal = 0.3;
            if distanceFromGoal < minDistanceFromGoal
                % change mode_ to complete
                disp("close enough to centroid, exiting")
                mode_ = "complete";
            else
                disp("planning new path")
                % plan new path
                start = mu(1:2);
                goalInPx = round(goal * pixelsInM);
                startInPx = round(start * pixelsInM);

                % compute path using distance transform
                nav = zeros(100);
                dx = DXform(nav);
                dx.plan(goalInPx);
                p = dx.query(startInPx);
                plannedPath = p/50;
                
                % reset a
                a = 1;
            end
    end
    
    % graphics
    disp("making pretty pictures")
    % plot robot frame
    plotBotFrame(mu(1:3))
    % plot robot covariance
    plot_cov(mu(1:3), Sigma(1:3, 1:3), 3)
    % plot landmark mus & covs
    plot_landmarks(mu(4:end), Sigma(4:end, 4:end))
    
    % plot planned path
    if strcmp(mode_, "setup") || strcmp(mode_, "d2c")
        plotPlannedPath(plannedPath)
    end
    % plot path taken
    plotTakenPath(takenPath)
    
    % LEDS
    displaymode_(mode_, Pb);
    
    % break out of loop if everything is done
    if mode_ == "complete"; break; end
    pause(dt);
end

Pb.stop();
disp("mission complete")
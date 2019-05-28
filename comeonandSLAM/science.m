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
zoom = 1;
axis([0 ARENASIZE(1) 0 ARENASIZE(2)] + [-1 1 -1 1]*zoom)
hold on

% initialise
mu = [0.1; 0.1; 0];
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
Sigma = diag([0.1 0.1 0.1*pi/180]).^2;
R = diag([.01 10*pi/180]).^2;
Q = diag([.15 4*pi/180]).^2;

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
idKeys = [-1, -2, -3, -4, -5];
idBeacons = [30, 57, 27, 39, 45];
idValues = [1, 2, 3, 4, 5];
landmarkIDs = containers.Map(idKeys, idValues);
currentID = -1;

disp("beginning mission")
seenLandmarks = [0, 0, 0, 0, 0];
seenLandmarks = containers.Map(idValues, seenLandmarks);

map2 = containers.Map();

while true
    disp("mode: " + mode_)
    % get ticks and estimate new pose
    disp("calculating [d, dth] using odometry")
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, dth] = get_odom(mu(1:3), ticks);
    
    % predict step
    disp("Running predict step (predict_slam):")
    [mu, Sigma] = predict_slam(mu, Sigma, d, dth, R);
    
    % sense
        % take photo
    img = Pb.getImage();
        % process image
        % if we see a never before seen, run init landmarks
    [binaryCode, centroidLocations] = identifyBeaconId(img);
    for i = 1:length(binaryCode)
        if ismember(binaryCode(i), idBeacons) % in set of existing
            if ismember(-1, idKeys)
                if ~ismember(binaryCode(i), idKeys)
                    for j = 1:length(idKeys)
                        if(idKeys(j) < 0)
                            idKeys(j) = binaryCode(i)
                            
                            landmarkIDs = containers.Map(idKeys, idValues)
                            cell2mat(landmarkIDs.keys)
                            cell2mat(landmarkIDs.values)
                            break;
                        end
                    end
                end
            end
            % Map landmark id to currentID (for easier indexing)
            disp("For the ID:")
            i
            binaryCode(i)
            currentID = landmarkIDs(binaryCode(i));
            % range and bearing / z
            z = [beaconDistance(centroidLocations(i, :)); beaconBearing(centroidLocations(i, :))];
            if (seenLandmarks(currentID) == 0)
                disp("Initialising (initLandmarksSlam):")
                [mu, Sigma] = initLandmarksSlam(z, Q, mu, Sigma);
                seenLandmarks(currentID) = 1;
            else
            	% update step 
                disp("Updating (update_slam):")
                [mu, Sigma] = update_slam(currentID, z, Q, mu, Sigma);
            end
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
            disp("pure pursuiting")
            %vw = purePursuit(currentGoal, q, d, dt, first); first = false;
            vel = vw2wheels(vw, true);
            Pb.setVelocity(vel)
    end    
    
    % do some thinking and planning
    switch mode_
        case "setup"
            % check if in location to start scanning
            loc = mu(1:2);
            distanceFromGoal = pointDist(loc', goal);
            minDistanceFromGoal = 0.5;
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
    if strcmp(mode_, "setup") || strcmp(mode_, "d2c")
        plot(currentX, currentY, 'kp')
        plotPlannedPath(plannedPath)
    end
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
disp("mission complete")
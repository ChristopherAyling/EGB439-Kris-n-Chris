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

% initialise mode
mode = "setup";

idKeys = [30, 57, 27, 39, 45];
idValues = [1, 2, 3, 4, 5];
landmarkIDs = containers.Map(idKeys, idValues);
currentID = -1;

while true
    % get ticks and estimate new pose
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, th] = get_odom(mu, ticks);
    
    % predict step
    
    
    % sense
        % take photo
    img = Pb.getImage();
        % process image
        % if we see a never before seen, run init landmarks
    [binaryCode, centroidLocations] = identifyBeaconId(img);
    for i = 1:length(binaryCode)
        if ismember(binaryCode(i), idKeys)
            currentID = landmarkIDs(binaryCode(i));
            % update step 
            [mu, Sigma] = update_slam(currentID, z, mu, Sigma, Q);
        end
    end
    % run controller to calc new vw
    
    
    % calculate next movement
    switch mode
        case "scan"
            disp("going in circle")
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
            
            disp("pure pursuiting")
            vw = purePursuit(currentGoal, mu(1:3), d, dt, first); first = false;
            vel = vw2wheels(vw, true);
            Pb.setVelocity(vel)
    end    
    
    % do some thinking and planning
    switch mode
        case "setup"
            % check if in location to start scanning
            loc = mu(1:2);
            distanceFromGoal = pointDist(loc, goal);
            minDistanceFromGoal = 0.3;
            if distanceFromGoal < minDistanceFromGoal
                % change mode to scan
                mode = "scan";
            end
            
        case "scan"
            scanSteps = scanSteps + 1;
            % check if done scanning
            if scanSteps >= desiredScanSteps
                % change mode to "d2c"
                mode = "d2c";
            end
            
        case "d2c"
            % calculate centroid (goal)
            points = mu2points(mu);
            [centroid, pgon] = calcCentroid(points);
            goal = centroid;
            % check if at centroid
            loc = mu(1:2);
            distanceFromGoal = pointDist(loc, goal);
            minDistanceFromGoal = 0.3;
            if distanceFromGoal < minDistanceFromGoal
                % change mode to complete
                disp("close enough to centroid, exiting")
                mode = "complete";
            else
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
    
    % LEDS
    displayMode(mode, Pb)
    
    % break out of loop if everything is done
    if mode == "complete"; break; end
    pause(dt);
end

Pb.stop();
disp("mission complete")
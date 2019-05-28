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
mu = [0.5; 1; deg2rad(0)];

% other config
dt = 0.25;

% encoder setup
prevEncoder = [0 0];

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
R = diag([.01 10*pi/180]).^2; % independant variable
Q = diag([.15 4*pi/180]).^2; % independant variable

% Data collection structures
oracleLocalisations = [];
EKFLocalisations = [];

% start moving
Pb.setVelocity([50, 50])

disp("And when you're dying I'll be still alive")
while true
    disp("mode: " + mode_)
    % Predict Step
    [x,S] = predictStepReport(x,S,d,dth,R);
    
    % Sense Step
    z = [beaconDistance(centroidLocations(i, :)); beaconBearing(centroidLocations(i, :))];
    
    % Update Step
    [x,S] = updateStepReport(map,z,x,S,Q);    
    
    % Data collection
    oracleLocalisation = getPose(pb);
    oracleLocalisations = [oracleLocalisations; oracleLocalisation];
    EKFLocalisations = [EKFLocalisations; mu(1:3)'];
    
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
    
    % Check if stopped moving
    loc = oracleLocalisation(1:2);
    prevLoc = oracleLocalisations(end, 1:2);
    distanceMoved = pointDist(loc', prevLoc);
    threshold = 0.05;
    if distanceMoved < threshold
        % change mode to complete.
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
    
    % LEDS
    displayMode(mode_, Pb);
    
    % break out of loop if everything is done
    if mode_ == "complete"; break; end
    pause(dt);
end

Pb.stop();
disp("And when you're dead I will be still alive")

% Save data
fname = datestr(datetime('now'));
save(fname); % save all variables in workspace, it just makes things easier
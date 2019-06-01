%{
    Look at me still talking when there's science to do
    When I look out there
    It makes me glad I'm not you
    I've experiments to be run
    There is research to be done
    On the people who are
    Still alive.
%}

% set up plotting
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

mappyboi = [1.9, 1.3;
            1.9, 1.0;
            1.9, 0.7];

% initialise
mu = [0.5; 1; deg2rad(0)];

% other config
dt = 0;

% encoder setup
prevEncoder = [0 0];

% make instructions
instruction = [10, 10];
steps = 10;
instructions = repmat(instruction, steps, 1);
stepsTaken = 0;

% EKF Initialisations 
Sigma = diag([0.1 0.1 0.1*pi/180]).^2;

% Data collection structures
idBeacons = [27, 39, 45];
EKFLocalisations = [];

disp("And when you're dying I'll be still alive")
tic
for instruction = instructions'
    i = stepsTaken + 1;
    disp("steps taken: "+stepsTaken+"/"+steps)
    % get ticks and estimate new pose
    ticks = trackedTicks(1, :);
    [d, dth] = get_odom(mu(1:3), ticks);
    
    % Predict Step
    [mu, Sigma] = predictStepReport(mu, Sigma, d, dth, R);
    
    % Sense Step
    img = images{i};
    [binaryCode, centroidLocations] = identifyBeaconId(img);

    z = [beaconDistance(centroidLocations); beaconBearing(centroidLocations)];
    % Update Step
    [mu, Sigma] = updateStepReport(mappyboi, z, mu, Sigma, Q);    

    
    % Act Step
    % no acting as in replay mode
    
    % Data collection
    % no data collection as in replay mode
    EKFLocalisations = [EKFLocalisations; mu(1:3)'];
    
    % graphics
    disp("making pretty pictures")
    cla
    axis square;
    grid on
    ARENASIZE = [2, 2];
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)] + [-1 1 -1 1]*zoom)
    hold on
    
    % plot robot frame
    plotBotFrame(mu(1:3))
    % plot robot covariance
    plot_cov(mu(1:3), Sigma(1:3, 1:3), 3)
    
    % plot path taken
    plotTakenPath(oracleLocalisations(1:i, :), "b");
    plotTakenPath(EKFLocalisations, "r");
    
    % plot landmarks
    plotLandmarks(landmarks)

    pause(dt);
    stepsTaken = stepsTaken+1;
end
toc

disp("And when you're dead I will be still alive")
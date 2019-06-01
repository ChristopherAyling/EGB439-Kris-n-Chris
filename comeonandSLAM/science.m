%{
    Look at me still talking when there's science to do
    When I look out there
    It makes me glad I'm not you
    I've experiments to be run
    There is research to be done
    On the people who are
    Still alive.
%}

clear

Pb = PiBot('172.19.232.125', '172.19.232.11', 32);
Pb.setLEDArray(bin2dec('0000000001000000'))
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

mappyboi = [1.9, 1.3;
            1.9, 1.0;
            1.9, 0.7];

% initialise
mu = [0.5; 1; deg2rad(0)];

% other config
dt = 0.25;

% encoder setup
prevEncoder = [0 0];

% make instructions
instruction = [10, 10];
steps = 10;
instructions = repmat(instruction, steps, 1);
stepsTaken = 0;

% EKF Initialisations 
Sigma = diag([0.1 0.1 0.1*pi/180]).^2;
R = diag([.01 10*pi/180]).^2; % independant variable
Q = diag([.15 4*pi/180]).^2; % independant variable

% Data collection structures
oracleLocalisations = [];
EKFLocalisations = [];
images = {};

idBeacons = [27, 39, 45];

disp("And when you're dying I'll be still alive")
tic
for instruction = instructions'
    disp("steps taken: "+stepsTaken+"/"+steps)
    % get ticks and estimate new pose
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, dth] = get_odom(mu(1:3), ticks);
    
    % Predict Step
    [mu, Sigma] = predictStepReport(mu, Sigma, d, dth, R);
    
    % Sense Step
    img = Pb.getImage();
    [binaryCode, centroidLocations] = identifyBeaconId(img)
    for i = 1:length(binaryCode)
        if ismember(binaryCode(i), idBeacons) % in set of existing
        	z = [beaconDistance(centroidLocations(i, :)); beaconBearing(centroidLocations(i, :))]
            % Update Step
            [mu, Sigma] = updateStepReport(mappyboi, z, mu, Sigma, Q);    
        end
    end
    
    % Act Step
    disp("executing instruction");
    Pb.setVelocity(instruction');
    
    % Data collection
    oracleLocalisation = getPose(Pb);
    oracleLocalisations = [oracleLocalisations; oracleLocalisation];
    EKFLocalisations = [EKFLocalisations; mu(1:3)'];
    images{stepsTaken+1} = img;
    
    
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
    
    % plot path taken
    plotTakenPath(oracleLocalisations, "b");
    plotTakenPath(EKFLocalisations, "r");
    
    % plot landmarks
    plotLandmarks(landmarks)

    pause(dt);
    stepsTaken = stepsTaken+1;
end
toc

Pb.stop();
disp("And when you're dead I will be still alive")

% Save data
fname = char(java.util.UUID.randomUUID);
save(fname); % save all variables in workspace, it just makes things easier
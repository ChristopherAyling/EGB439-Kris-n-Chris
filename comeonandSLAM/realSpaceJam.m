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
steps = 100;
prevEncoder = [0 0];

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

mode = "";

while true
    % get ticks and estimate new pose
    encoder = Pb.getEncoder();
    ticks = encoder-prevEncoder;
    prevEncoder = encoder;
    [d, th] = get_odom(mu, ticks);
    % predict step
    
    % sense
        % take photo
        % process image
    
    % update step
    
    % run controller to calc new vw
    
    % switch
        % setup
        
        % scan
        
        % drive to centroid
    
end
Pb.stop()

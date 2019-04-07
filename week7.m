% Week 7 Practical
% 1. 


% Connect to bot
Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

% Get Image
image = getLocalizerImage(Pb);

% make occupancy grid
%{
normImage = double(image) / 255;
biColour = (normImage > 0.9) - (normImage > 0.16);
biColourClean = bwareaopen(biColour, 700);
occupancyGrid = imresize(biColourClean, 1/5);

RGB  = zeros(100, 100, 3);  % RGB Image
R    = RGB(:, :, 1) + occupancyGrid;
G    = RGB(:, :, 2) + (occupancyGrid).^-1 - occupancyGrid;
B    = RGB(:, :, 3);
colourisedGrid = cat(3, R, G, B);
%}

% initialisation
pose = Pb.getLocalizerPose();
start = [pose.pose.x, pose.pose.y];
startTheta = pose.pose.theta;
startTheta = degtorad(startTheta);
q = [start, startTheta];

goal = [0.3 0.3]; % set goal here

% convert from real to px units
pixelsInM = 50;
goalInPx = goal * pixelsInM;
startInPx = start * pixelsInM;

% compute occupancy grid
dx = DXform(occupancyGrid);

% compute distance transform
dx.plan(goalInPx);

% compute shortest path 
p = dx.query(startInPx);

pathX = [q(1)];
pathY = [q(2)];

plannedPath = p/50;

first = true;
a = 1;

dt = 0.25;
d = 0.1;

% Start simulation
done = false;

for a = 1:length(plannedPath)
    % calcualte current goal
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]';
    
    % run controller
    vw = purePursuit(currentGoal, q, d, dt, first);
    vel = vw2wheels(vw, 1);
    
    % set velocities
    q = qupdate(q, vel, dt);
    
    % store path
    pathX = [pathX, q(1)];
    pathY = [pathY, q(2)];
    actualPath = cat(1, pathX, pathY)';
   
	% plot graphics
	week6graphics(colourisedGrid, q, plannedPath, actualPath, start, goal)
    
    % creative LEDs
    maxDist = sqrt(8);
    actualDist = 2;
    LEDDistDisplay(Pb, maxDist, actualDist);
    
    % pause to not overwhelm localiser
	pause(dt);
end
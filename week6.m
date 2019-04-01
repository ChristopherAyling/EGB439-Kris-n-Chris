% Week 6 Practical

% Connect to bot
% Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

% Get Image
% image = getLocalizerImage(Pb);

% make occupancy grid
%{
normImage = double(image) / 255;
biColour = (normImage > 0.9) - (normImage > 0.25);
biColourClean = bwareaopen(biColour, 700);
occupancyGrid = imresize(biColourClean, 1/5);

RGB  = zeros(100, 100, 3);  % RGB Image
R    = RGB(:, :, 1) + occupancyGrid;
G    = RGB(:, :, 2) + (occupancyGrid).^-1 - occupancyGrid;
B    = RGB(:, :, 3);
colourisedGrid = cat(3, R, G, B);
%}

% plan path
start = [0.3 0.3];
startTheta = 180;
goal = [1.6, 1.6];
startTheta = degtorad(startTheta);
q = [start, startTheta];

pixelsInM = 50;
goalInPx = goal * pixelsInM;
startInPx = start * pixelsInM;

dx = DXform(occupancyGrid);
dx.plan(goalInPx);
p = dx.query(startInPx);

pathX = [q(1)];
pathY = [q(2)];

plannedPath = p/50;
% actualPath = [0 0; 0.5 1];

first = true;
a = 1;

dt = 0.25;
d = 0.1;

% Start simulation
done = false;

for a = 1:length(plannedPath)
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    
    currentGoal = [currentX currentY]';
    
    vw = purePursuit(currentGoal, q, d, dt, first);
    vel = vw2wheels(vw, 1);
    

    q = qupdate(q, vel, dt);
    
    pathX = [pathX, q(1)];
    pathY = [pathY, q(2)];
    actualPath = cat(1, pathX, pathY)';
   
	% plot graphics
	week6graphics(colourisedGrid, q, plannedPath, actualPath, start, goal)
	pause(0.01);
end

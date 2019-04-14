% Week 6 Practical

% Connect to bot
Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

% Get Image
% image = getLocalizerImage(Pb);

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

% plan path
start = [1.84, 1.84];
startTheta = 0;
goal = [0.15 0.2];
startTheta = degtorad(startTheta);
q = [start, startTheta];

pixelsInM = 50;
goalInPx = round(goal * pixelsInM);
startInPx = round(start * pixelsInM);

dx = DXform(flipud(occupancyNav));
dx.plot()
dx.plan(goalInPx);
p = dx.query(startInPx);

pathX = [q(1)];
pathY = [q(2)];

plannedPath = p/50;
% actualPath = [0 0; 0.5 1];

first = true;
a = 1;

dt = 0.25;
d = 0.05;

% Start simulation
done = false;

currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);    
currentGoal = [currentX currentY]';

fd = 0.15;

finalCountdown = 0;
while true
    i = i+1;
    % check if close to pursuit goal
    loc = [q(1) q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd;
    if closeEnough
        a = a+1;
    end
    if a > length(plannedPath)
        a = length(plannedPath);
        d = 0;
        finalCountdown = finalCountdown + 1;
    end
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);    
    currentGoal = [currentX currentY]';
    
    vw = purePursuit(currentGoal, q, d, dt, first); first = false;
    vel = vw2wheels(vw, 1);

    q = qupdate(q, vel, dt);
    
    pathX = [pathX, q(1)];
    pathY = [pathY, q(2)];
    actualPath = cat(1, pathX, pathY)';
   
	% plot graphics
    pursuit = currentGoal;
	week6graphics(colourisedGrid, q, plannedPath, actualPath, start, goal, pursuit)
	pause(0.01);
    
    if finalCountdown > 15
       break 
    end
end

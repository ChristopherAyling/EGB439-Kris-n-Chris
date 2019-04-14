% Connect to bot
Pb = PiBot('172.19.232.171', '172.19.232.12', 32);

% initialisation
q = getPose(Pb);
start = [q(1), q(2)];
startTheta = q(3);
startTheta = degtorad(startTheta);
q = [start, startTheta];

goal = [0.15 0.2]; % set goal here

% convert from real to px units
pixelsInM = 50;
goalInPx = round(goal * pixelsInM);
startInPx = round(start * pixelsInM);

% compute occupancy grid
dx = DXform(flipud(occupancyNav));

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
d = 0.05;
fd = 0.15;

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

dx.plot(p);
pause(1);

% Start simulation
finalCountdown = 0;
while true
    q = getPose(Pb);
    
    loc = [q(1), q(2)];
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
    if pointDist(loc, goal) < 0.1
       finalCountdown = 10000;
    end 
    % calcualte current goal
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]';
    
    % run controller
    vw = purePursuit(currentGoal, [q(1) q(2) deg2rad(q(3))], d, dt, first);
    first = false;
    vel = vw2wheels(vw, true);
    
    % set velocities
    Pb.setVelocity(vel);
    
    % store path
    pathX = [pathX, q(1)];
    pathY = [pathY, q(2)];
    actualPath = cat(1, pathX, pathY)';
   
	% plot graphics
	week6graphics(colourisedGrid, [q(1) q(2) degtorad(q(3))], plannedPath, actualPath, start, goal, currentGoal')
    
    % creative LEDs
    maxDist = sqrt(8);
    actualDist = pdist([q(1), q(2); goal], 'euclidean');
    LEDDistDisplay(Pb, maxDist, actualDist);
    
    % pause to not overwhelm localiser
	pause(dt);
    if finalCountdown > 15
        finalCountdown
       break 
    end
end
ex

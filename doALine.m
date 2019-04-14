% purepursuit a line
Pb = PiBot('172.19.232.171', '172.19.232.12', 32);

q = getPose(Pb);
start = [q(1) q(2)];
goal = [1, 1];

% convert from real to px units
pixelsInM = 50;
goalInPx = goal * pixelsInM;
startInPx = round(start * pixelsInM);

% compute occupancy grid
dx = DXform(flipud(occupancyNav));

% compute distance transform
dx.plan(goalInPx);

% compute shortest path 
p = dx.query(startInPx);
plannedPath = p/50;

pathX = [q(1)];
pathY = [q(2)];

figure(1)
dx.plot(p)

pause(1)
% pure pursuit it
dt = 0.25;
d = 0.05;
fd = 0.15;
a = 1;
finalCountdown = 0;
while true
    % get current pose
    q = getPose(Pb);
    
    % store paths
    pathX = [pathX, q(1)];
    pathY = [pathY, q(1)];
    actualPath = cat(1, pathX, pathY)';
    
    % choose current goal
    dist = pointDist([q(1), q(2)], currentGoal');
    closeEnough = dist < fd;
    if closeEnough
        a = a+1
    end
    if a > length(plannedPath)
        a = length(plannedPath);
        d = 0;
        finalCountdown = finalCountdown + 1;
    end
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]'
    
    % run controller
    ppq = [q(1) q(2) deg2rad(q(3))];
    vw = purePursuit(currentGoal, ppq, d, dt, first);
    first = false;
%     vel = control(q, goal);
    
    % update wheels
    vel = vw2wheels(vw, false)/2
    Pb.setVelocity(vel)
    
    % update graphics
    gq = [q(1) q(2) degtorad(q(3))];
	week6graphics(colourisedGrid, gq, plannedPath, actualPath, start, goal, currentGoal')
    
    % update LEDS
    maxDist = sqrt(8);
    actualDist = pdist([q(1), q(2); goal], 'euclidean');
    LEDDistDisplay(Pb, maxDist, actualDist);
    
    % maybe quit
    if finalCountdown > 15
        break
    end
    
    % give localiser a break
    pause(dt);
end
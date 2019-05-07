Pb = PiBot('172.19.232.200', '172.19.232.11', 32);
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

goals = [
    0.5 0.5;
    1 0.5;
    1 1;
    0.5 1;
];
goal_idx = 1;
goal = goals(goal_idx, :); % set goal here

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

% other config
dt = 0.2;
a = 1;
d = 0.05;
fd = 0.12;
steps = 100;

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% run
plotBotFrame(q);
plotBeacon(goal);
plotPlannedPath(plannedPath);
while true
    % get ticks and estimate new pose
    ticks = Pb.getEncoder();
    Pb.resetEncoder();
    q = newPose(q, ticks);
    
    % see if reached current goal
    loc = [q(1), q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd; % dist from current goal < following dist
    while closeEnough
        a = min(a+1, length(plannedPath)); % set next point on path as current goal
        % calculate current goal
        currentX = plannedPath(a, 1);
        currentY = plannedPath(a, 2);
        currentGoal = [currentX currentY]';
        dist = pointDist(loc, currentGoal');
        closeEnough = dist < fd; % dist from current goal < following dist
    end
    
    % run controller
    vw = purePursuit(currentGoal, q, d, dt, first);
    first = false;
    vel = vw2wheels(vw, true);
    
    % set velocities
    Pb.setVelocity(vel*1.5);
    
    % take a photo
    img = Pb.getImage();
    [binaryCode, centroidLocations] = identifyBeaconId(img);
    if binaryCode ~= -1
        for i = 1:length(centroidLocations)
            if centroidLocations(i, 1) ~= -1
                distance = beaconDistance(centroidLocations(i, :));
                
                plotBeacon(centroidLocations(i, :), binaryCode(i));
            end
        end
    end
    
    % continue path
    pd = pointDist(loc, goal);
    minDist = 0.1;
    if pd < minDist
        goal_idx = goal_change + 1;
        a = 0;
        
        currentX = plannedPath(a, 1);
        currentY = plannedPath(a, 2);
        currentGoal = [currentX currentY]';
        
        
    end
    
    % graphics
    plot(currentX, currentY, 'kp')
    plotBotFrame(q);
    
    pause(dt)
end

% cleanup
Pb.stop();
hold off

% helper functions
function plotPlannedPath(plannedPath)
    pathY = plannedPath(:,1);
    pathX = plannedPath(:,2);
    plot(pathY, pathX, 'k--');
end

function r = range_(p1, p2)
    %RANGE distance between two points
    % _ is there as range is a built in function
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    
    r = sqrt((x1-x2)^2 + (y1-y2)^2);
end

function plannedPath = computeNewPath(goal, start)
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
end
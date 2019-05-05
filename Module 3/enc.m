Pb = PiBot('172.19.232.171', '172.19.232.11', 32);
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

goal = [1 1]; % set goal here

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
dt = 0.25;
a = 1;
d = 0.05;
fd = 0.15;
steps = 100;

% calcualte current goal
currentX = plannedPath(a, 1);
currentY = plannedPath(a, 2);
currentGoal = [currentX currentY]';

% run
plotBotFrame(q);
plotPlannedPath(plannedPath);
for i = 1:steps
    % get ticks and estimate new pose
    ticks = Pb.getEncoder();
    Pb.resetEncoder();
    q = newPose(q, ticks);
    
    % see if reached current goal
    loc = [q(1), q(2)];
    dist = pointDist(loc, currentGoal');
    closeEnough = dist < fd; % dist from current goal < following dist
    if closeEnough
        a = min(a+1, length(plannedPath)); % set next point on path as current goal
    end
    
    % calculate current goal
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    currentGoal = [currentX currentY]';
    
    % run controller
    vw = purePursuit(currentGoal, q, d, dt, first);
    first = false;
    vel = vw2wheels(vw, true);
    
    % set velocities
    Pb.setVelocity(vel);
    
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

% Week 6 Practical

% Connect to bot
% Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

% Get Image
% image = getLocalizerImage(Pb);

start = [0.3 0.3];
startTheta = 180;
goal = [1.6, 1.6];
q = [start, startTheta];

first = true;

% plan path
plannedPath = p/50;
actualPath = [0 0; 1 1];

dt = 0.25;
d = 0.1;

% Start simulation
done = false;
for a = 1:length(plannedPath)
    currentX = plannedPath(a, 1);
    currentY = plannedPath(a, 2);
    
    % do calc
    vw = purepursuit(goal, q, d, dt, first);
	vel = vw2wheels(vw, 1);
    
	q = qupdate(q, vel, dt);
   
	% plot graphics
	week6graphics(colourisedGrid, q, plannedPath, actualPath, start, goal)
	pause(0.25);
end

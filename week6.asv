% Week 6 Practical

% Connect to bot
% Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

% Get Image
% image = getLocalizerImage(Pb);

start = [0.3 0.3];
startTheta = 180;
goal = [1.6, 1.6];
q = [start, startTheta];

% plan path
plannedPath = p/50;
actualPath = [0 0; 1 1];

% Start simulation
done = false;
while ~done
   % do calc
   q = q
   
   % plot graphics
   week6graphics(colourisedGrid, q, plannedPath, actualPath, start, goal)
   pause(0.25);
   done = true; % 
end

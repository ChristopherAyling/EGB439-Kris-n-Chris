% Connect the piBot to the arena. Include out group number
% Near door: 172.19.232.11
% Near far wall: 172.19.232.12
%Pb = PiBot('172.19.232.191');

%Pb.setVelocity([0, 50], 3.33)
%Pb.setVelocity([50, 100], 3.245)

% Read localiser %
Pb = PiBot('172.19.232.104', '172.19.232.12', 32);
blueLEDs(Pb, 0);
figure;
x = 0;
y = 0;
theta = 0;

n = 1000;
pathX = ones(1, n);
pathY = ones(1, n);
a = false;

goalX = 1;
goalY = 1;
pathN = 1; 
while(a == false)
    pose = Pb.getLocalizerPose();
    
    x = pose.pose.x;
    y = pose.pose.y;
    
    pathX(pathN) = x;
    pathY(pathN) = y;
    theta = pose.pose.theta;
    
    drawBot(x, y, theta, pathX(1:pathN), pathY(1:pathN), goalX, goalY)
    
    vel = control([x y theta], [goalX goalY]);
    Pb.setVelocity([vel(1), vel(2)]);
    
    if vel(1) == 0 && vel(2) == 0
        a = true;
        blueLEDs(Pb, 1);
    end
    pathN = pathN + 1;
end

Pb.stop();


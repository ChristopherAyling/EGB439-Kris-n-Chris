% Connect the piBot to the arena. Include out group number
% Near door: 172.19.232.11
% Near far wall: 172.19.232.12
%Pb = PiBot('172.19.232.191');

% Moving robot in a circle 300-500mm in diameter
% 11cm = 40 (both wheels) for 1s, v = 11cm/s = 110mm
% 27cm = 10 (both) for 5s, v = 5.3cm/s
% Robot is 18cm from outside of wheels
% rotates 540deg @ 50 for 5s = 108deg/s @ 50
% Pb.setVelocity([50, 0], 3.33) rotates 360deg
% 942.48
% 1507.96

%Pb.setVelocity([0, 50], 3.33)
%Pb.setVelocity([50, 100], 3.245)

% Read localiser %
Pb = PiBot('172.19.232.191', '172.19.232.11', 32);
figure;
x = 0;
y = 0;
%theta = 0;
n = 1000;
pathX = ones(1, 1000);
pathY = ones(1, 1000);
a = 1;
%Pb.setVelocity([15, 15]);
Pb.setVelocity([50, 100]);

while(a < 20)
    pose = Pb.getLocalizerPose();
    x = pose.pose.x;
    y = pose.pose.y + 0.075;
    pathX(a) = pose.pose.x;
    pathY(a) = pose.pose.y + 0.075;
    theta = 0;
    arenaDraw(x, y, theta, pathX(1:a), pathY(1:a))
    a = a + 1;
    pause(0.5);
end
Pb.stop();


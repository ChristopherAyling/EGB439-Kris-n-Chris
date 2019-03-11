% Connect the piBot to the arena. Include out group number
% Near door: 172.19.232.11
% Near far wall: 172.19.232.12
%Pb = PiBot('192.168.0.16');

% Moving robot in a circle 300-500mm in diameter
% 11cm = 40 (both wheels) for 1s, v = 11cm/s = 110mm
% 27cm = 10 (both) for 5s, v = 5.3cm/s
% Robot is 18cm from outside of wheels
% rotates 540deg @ 50 for 5s = 108deg/s @ 50
% Pb.setVelocity([50, 0], 3.33) rotates 360deg
% 942.48
% 1507.96

%Pb.setVelocity([0, 50], 3.33)
%Pb.setVelocity([50, 100], 10)

% Read localiser %
%Pb = PiBot('172.19.232.101', '172.19.232.11', 32); 
%pose = Pb.getLocalizerPose();
%figure;
%x = 200;
%y = 200;
%theta = 0;

%a = 0;
%while(a < 100)
%    x = x + 5;
%    y = y + 5;
%    theta = theta + 2;
%    arenaDraw(x, y, theta)
%    a = a + 1;
%    pause(0.001);
%end


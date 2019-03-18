bot = '172.19.232.104';
localiser = '';
groupNumber = 2;

pb = PiBot(bot, localiser, groupNumber);

% drive the robot in a circle

pb.setVelocity([50, 0], 3.33)

% read localiser at 2HZ and display configuration as well as path over last
% 5 seconds

HZ = 2;

while(1)
    pose = pb.getLocalizerPose();
    cx = pose.pose.x;
    cy = pose.pose.y;
    drawBot()
    pause(1/HZ)
end
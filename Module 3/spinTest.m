% set up plotting
clf
figure(1)
axis square;
grid on
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on

% face a point
q = [0.1, 0.1, 0]
goal = [1, 1]

angleFromBeacon = rad2deg(bearing([q(1), q(2)], goal, q(3)));
Pb.resetEncoder();
while ~(angleFromBeacon < 2 && angleFromBeacon > -2)
    % rotate and estimate pose
    if angleFromBeacon < 0 % rotate the fastest direction
        vel = [20 -20];
    else
        vel = [-20 20];
    end
    Pb.setVelocity(vel/2);
    ticks = Pb.getEncoder();
    Pb.resetEncoder();
    q = newPose(q, ticks)
    
    plotStuff(q)
    
    % check angle error
    angleFromBeacon = rad2deg(bearing([q(1), q(2)], goal, q(3)))
    pause(0.25)
end
Pb.stop()

function plotStuff(q)
    clf
    axis square;
    grid on
    ARENASIZE = [2, 2];
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
    hold on
    plotBotFrame(q);
end
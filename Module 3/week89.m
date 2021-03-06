% Week 8-9 Practical Script

% Connect to bot
Pb = PiBot('172.19.232.171', '172.19.232.11', 32);

beaconLoc = [1, 1]; % given to us
beaconID = NaN;

q = [0 0 0];

while true
    % get q
    q = [0 0 0];
    
    % check if done
    
    % update velocities
    vw = [0 0]; % TODO run the controller
    vel = vw2wheels(vw);
    Pb.setVelocity(vel);
    
    % plot bot
    plotBotFrame(q);
    
    % plot beacon
    if isnan(beaconID)
       plotBeacon(beaconLoc) 
    else
       plotBeacon(beaconLoc, beaconID) 
    end
end

% range and bearing measurement models

function r = range_(p1, p2)
    %RANGE distance between two points
    % _ is there as range is a built in function
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    
    r = sqrt((x1-x2)^2 + (y1-y2)^2);
end

function b = bearing(p1, p2, theta)
    %BEARING
    % theta is in radians
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    
    b = atan2(y2-y1, x2-x1) - theta;
end
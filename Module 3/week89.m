% Week 8-9 Practical Script

% Connect to bot
Pb = PiBot('172.19.232.171', '172.19.232.11', 32);

beaconLoc = [1, 1]; % given to us

q = [0 0 0]

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
end
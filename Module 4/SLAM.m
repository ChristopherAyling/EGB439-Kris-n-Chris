% SLAM

% arena and robot initialisation
Pb = PiBot('172.19.232.102', '172.19.232.11', 32);
Pb.resetEncoder();

% initial variables
q = [initX, initY, initTh];
seenBeacons = [0, 0, 0, 0, 0];

while true
    % Plot:
    % plotArenaSlam()
    % Move:
    % slamMove(...)
    % Perform a prediction step:
    %[...] = predictStep(...);
    % Make a new measurement (range and bearing to landmark):
    z = sense(q, Pb);
    
    % Separate out beacon ids in measurement
    currentBeacons = z(3);
    seenBeacons = [0, 0, 0, 0, 0];
    
    for i = 1:length(currentBeacons)
        % if we haven't seen this landmark before:
        if (ismember(currentBeacons(i), seenBeacons) == 0)
            % add it to the arr of seen beacons
            for j = 1:length(seenBeacons)
                if seenBeacons(j) == 0
                    seenBeacons(j) = currentBeacons(j);
                    break;
                end
            end
            % initialise landmark based on the robot estimated pose and expanded
            % mean and covariance:
            %[...] = initialiseStep(...);
            
        % else
        else
            % perform the update step and update the mean and covariance
            %[...] = updateStep(...);:
        end
    end 
end

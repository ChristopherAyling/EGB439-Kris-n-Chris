function [arrived] = slamMove(inputargshere)
    % move function - avoid beacons and continuously move (circle?)
    % until confident enough that the beacon locations are correct.
    % Once this confidence is high enough, move towards final location
    % (but continue updating everything). Maybe have a binary output on the
    % move function -- if it thinks it's in the final position, break
    % the loop, light LEDs
    

    arrived = false;
end


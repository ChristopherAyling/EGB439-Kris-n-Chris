function LEDDistDisplay(pb, maxDist, actualDist)
    % turns on more lights the closer the robot gets to the goal
    
    % calculate the distance as a fraction of 16
    outOf16 = ceil(((actualDist/maxDist)*10)*1.6);
    
    % calcualte how many LEDS to turn on
    nTolightUp = 16 - outOf16;
    
    % calculate integer required to lightup that many LEDs
    v = 0;
    for i = 0:nTolightUp-1
        v = v + (2^i);
    end
    
    % just for debugging
    bs = dec2bin(v);
    bssz = size(bs);
%     assert(bssz(2) == nTolightUp)
    
    % set the LED array
    pb.setLEDArray(v)
end


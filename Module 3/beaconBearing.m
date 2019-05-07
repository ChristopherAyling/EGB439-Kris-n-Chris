function [bearingFromBot] = beaconBearing(centroid)
    % Only feed this one image at a time or it'll get mad and explode
    % Bottom centroid: 50mm
    % Middle centroid: 100mm
    % Top centroid: 150mm   
    focalLength = 3.04; %mm
    realHeight = 100; %mm
    imageHeight = 240; %px
    hfov = 62.2; % degrees
    
    rangeFromBot = 
end
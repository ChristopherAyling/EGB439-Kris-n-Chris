function [distanceFromBot] = beaconDistanceOld(centroid)
    % Only feed this one image at a time or it'll get mad and explode
    % Bottom centroid: 50mm
    % Middle centroid: 100mm
    % Top centroid: 150mm   
    focalLength = 3.04; %mm
    realHeight = 100; %mm
    imageHeight = 240; %px
    
    objectHeight = centroid(1) - centroid(2); %px
    sensorHeight = 2.76; %mm also ???
    
    distanceFromBot = (focalLength * realHeight * imageHeight) / (objectHeight * sensorHeight);
end
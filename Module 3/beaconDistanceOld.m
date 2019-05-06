function [distanceFromBot] = beaconDistanceOld(middleCentroid)
    % Only feed this one image at a time or it'll get mad and explode
    % Bottom centroid: 50mm
    % Middle centroid: 100mm
    % Top centroid: 150mm   
    focalLength = 1.33; %mm
    realHeight = 100; %mm
    imageHeight = 240; %px
    
    objectHeight = imageHeight - middleCentroid; %px
    sensorHeight = 1.38; %mm also ???
    
    distanceFromBot = (focalLength * realHeight * imageHeight) / (objectHeight * sensorHeight);
end
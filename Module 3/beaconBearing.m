function [bearingFromBot] = beaconBearing(centroid)
    % Only feed this one image at a time or it'll get mad and explode
    % Bottom centroid: 50mm
    % Middle centroid: 100mm
    % Top centroid: 150mm  
    xLoc = (centroid(1) + centroid(3)) / 2;
    screenWidth = 320;
    middleScreen = screenWidth / 2;
    hfov = 62.2; % degrees
    
    if xLoc >= middleScreen
        distToX = middleScreen - (screenWidth - xLoc);        
        bearingFromBot = ((distToX * (hfov/2)) / middleScreen) + (hfov/2);
    else
        distToX = middleScreen - (middleScreen - xLoc);        
        bearingFromBot = (distToX * (hfov/2)) / middleScreen;
    end
end
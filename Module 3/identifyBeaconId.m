function [binaryCode] = identifyBeaconId(image)
    % Provide identifyBeaconId an image via I = imread('x.format'); or
    % via an image taken with the camera and output the binary Code if
    % there's a beacon
    
    close all
    
    normImage = double(image) / 255;
    %biColour = (normImage > 0.9) - (normImage > 0.16);
    %biColourClean = bwareaopen(biColour, 800);
    %occupancyGrid = imresize(biColourClean, 1/5);
    r = normImage(:, :, 1);
    g = normImage(:, :, 2);
    b = normImage(:, :, 3);
    
    rBW = ((r - g) - b) > 0.1;
    gBW = ((g - r) - b) > 0;
    bBW = ((b - g) - r) > 0;
    yBW = ((r + g) - b) > 0.99;
    
    rClean = bwareaopen(rBW, 100);
    gClean = bwareaopen(gBW, 100);
    bClean = bwareaopen(bBW, 100);
    yClean = bwareaopen(yBW, 100);
    
    figure;
    idisp(normImage);
    
    figure;
    idisp(yClean);
    figure;
    idisp(bClean);
    
    % Red Blob and Centroid
    rBlob = bwlabel(rClean);
    rCentroid = regionprops(rBlob,'centroid');
    % Blue Blob and Centroid
    bBlob = bwlabel(bClean);
    bCentroid = regionprops(bBlob,'centroid');
    % Yellow Blob and Centroid
    yBlob = bwlabel(yClean);
    yCentroid = regionprops(yBlob,'centroid');
    
    figure;
    imshow(normImage);
    hold on;
    plot(rCentroid(1).Centroid(1),rCentroid(1).Centroid(2),'ro');
    plot(bCentroid(1).Centroid(1),bCentroid(1).Centroid(2),'bo');
    plot(yCentroid(1).Centroid(1),yCentroid(1).Centroid(2),'yo');
    hold off;
    
    redY = rCentroid(1).Centroid(2);
    blueY = bCentroid(1).Centroid(2);
    yellowY = yCentroid(1).Centroid(2);
    
    
    
end


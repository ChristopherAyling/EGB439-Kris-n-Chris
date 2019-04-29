function [binaryCode] = identifyBeaconId(image)
    % Provide identifyBeaconId an image via I = imread('x.format'); or
    % via an image taken with the camera and output the binary Code if
    % there's a beacon
    
    % Comment this out unless testing
    close all
    
    % Normalise image so it ranges 0-1
    normImage = double(image) / 255;
    
    % Seperate RGB layers
    r = normImage(:, :, 1);
    g = normImage(:, :, 2);
    b = normImage(:, :, 3);
    
    % Remove influence of other colours from each layer, and create a 
    % yellow layer via r + g
    rBW = ((r - g) - b) > 0.1;
    gBW = ((g - r) - b) > 0;
    bBW = ((b - g) - r) > 0;
    yBW = ((r + g) - b) > 0.99;
    
    % Remove small blobs
    rClean = bwareaopen(rBW, 50);
    gClean = bwareaopen(gBW, 50);
    bClean = bwareaopen(bBW, 50);
    yClean = bwareaopen(yBW, 50);
    
    % Disp blobs (for testing)
    figure;
    idisp(normImage);
    figure;
    idisp(rClean);
    figure;
    idisp(yClean);
    figure;
    idisp(bClean);
    
    % Identify and plot centroids of blobs for each colour    
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
    
    % y-values of blobs
    redY = rCentroid(1).Centroid(2);
    blueY = bCentroid(1).Centroid(2);
    yellowY = yCentroid(1).Centroid(2); 
    
    RED = '01';
    BLUE = '10';
    YELLOW = '11';
    
    % Gross Code to Find Top, Bottom, and Middle Binary Codes
    %TOP
	if redY > blueY && redY > yellowY
        topBin = RED;
    elseif blueY > redY && blueY > yellowY
        topBin = BLUE;
    else
        topBin = YELLOW;
    end
   
	if topBin == RED
        if blueY > yellowY
            middleBin = BLUE;
        else
            middleBin = YELLOW;
        end
    elseif topBin == BLUE
        if redY > yellowY
            middleBin = RED;
        else
            middleBin = YELLOW;
        end
    else
       middleBin = YELLOW;
    end
    
    if strcmp(topBin, RED) && strcmp(middleBin, BLUE)
        bottomBin = YELLOW;
    elseif strcmp(topBin, RED) && strcmp(middleBin, YELLOW)
        bottomBin = BLUE;
    elseif strcmp(topBin, BLUE) && strcmp(middleBin, RED)
        bottomBin = YELLOW;
    elseif strcmp(topBin, BLUE) && strcmp(middleBin, YELLOW)
        bottomBin = RED;
    elseif strcmp(topBin, YELLOW) && strcmp(middleBin, BLUE)
        bottomBin = RED;
    else
        bottomBin = BLUE;
    end
        
        
    binaryString = strcat(bottomBin, middleBin, topBin);
        
    binaryCode = bin2dec(binaryString);
end


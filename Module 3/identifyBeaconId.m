function [binaryCode, centroidLocations] = identifyBeaconId(img)
    % Provide identifyBeaconId an img via I = imread('x.format'); or
    % via an img taken with the camera and output the binary Code if
    % there's a beacon
    
    % Comment this out unless testing
    %close all
    
    % Normalise img so it ranges 0-1
    normImg = double(img) / 255;
    
    % Seperate RGB layers
    r = normImg(:, :, 1);
    g = normImg(:, :, 2);
    b = normImg(:, :, 3);
    
    % Remove influence of other colours from each layer, and create a 
    % yellow layer via r + g
    rBW = ((r - g) - b) > 0.1;
    gBW = ((g - r) - b) > 0;
    bBW = ((b - g) - r) > 0;
    yBW = ((r + g) - b) > 0.85;
    
    % Remove small blobs
    rClean = bwareaopen(rBW, 20);
    %gClean = bwareaopen(gBW, 50);
    bClean = bwareaopen(bBW, 20);
    yClean = bwareaopen(yBW, 20);
    
    % Close any gaps (important because sometimes the beacons have white
    % sections between coloured bits and it thinks there's two beacons
    SE = strel('rectangle', [5, 10]);
    rClean = imclose(rClean, SE);
    bClean = imclose(bClean, SE);
    yClean = imclose(yClean, SE);
    
    %{
    figure;
    idisp(normImg);
    figure;
    idisp(rClean);
    figure;
    idisp(bClean);
    figure;
    idisp(yClean);
    %}
    
    
    % Disp blobs (for testing)

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
    
    if (length(rCentroid) >= 1 && length(bCentroid) >= 1 && length(yCentroid) >= 1)
        blobsR = length(rCentroid);
        blobsB = length(bCentroid);
        blobsY = length(yCentroid);

        if blobsR == blobsB && blobsB == blobsY
            beaconN = blobsR;
        else
            beaconN = 1;
        end

        beaconIDs = ones(beaconN, 1);
        centroidLocations = ones(length(bCentroid), 2)*-1;
        
        for i = 1:beaconN
            %{
            figure;
            imshow(normImg);
            hold on;
            plot(rCentroid(i).Centroid(1),rCentroid(i).Centroid(2),'ro');
            plot(bCentroid(i).Centroid(1),bCentroid(i).Centroid(2),'bo');
            plot(yCentroid(i).Centroid(1),yCentroid(i).Centroid(2),'yo');
            hold off;
            %}

            % y-values of blobs
            redY = rCentroid(i).Centroid(2);
            blueY = bCentroid(i).Centroid(2);
            yellowY = yCentroid(i).Centroid(2);

            RED = '01';
            BLUE = '10';
            YELLOW = '11';

            % Gross Code to Find Top, Bottom, and Middle Binary Codes
            %TOP
            if redY < blueY && redY < yellowY
                topBin = RED;
            elseif blueY < redY && blueY < yellowY
                topBin = BLUE;
            else
                topBin = YELLOW;
            end

            if strcmp(topBin, RED)
                if blueY < yellowY
                    middleBin = BLUE;
                else
                    middleBin = YELLOW;
                end
            elseif strcmp(topBin, BLUE)
                if redY < yellowY
                    middleBin = RED;
                else
                    middleBin = YELLOW;
                end
            elseif strcmp(topBin, YELLOW)
                if redY < blueY
                    middleBin = RED;
                else
                    middleBin = BLUE;
                end
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
            
            if strcmp(bottomBin, BLUE)
                centroidLocations(i, 1:2) = bCentroid(i).Centroid;
            elseif strcmp(bottomBin, RED)
                centroidLocations(i, 1:2) = rCentroid(i).Centroid;
            elseif strcmp(bottomBin, YELLOW)
                centroidLocations(i, 1:2) = yCentroid(i).Centroid;
            end   
            
            if strcmp(topBin, BLUE)
                centroidLocations(i, 3:4) = bCentroid(i).Centroid;
            elseif strcmp(topBin, RED)
                centroidLocations(i, 3:4) = rCentroid(i).Centroid;
            elseif strcmp(topBin, YELLOW)
                centroidLocations(i, 3:4) = yCentroid(i).Centroid;
            end   

            binaryString = strcat(bottomBin, middleBin, topBin);

            beaconIDs(i) = bin2dec(binaryString);
        end
        
        binaryCode = beaconIDs;
    else
        binaryCode = [-1];
        centroidLocations = [-1, -1];
    end   
end


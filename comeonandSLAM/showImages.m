function showImages(images)
    figure(3)
    hold on
    n_images = length(images);
    for i = 1:n_images
        img = images{i};
        subplot(1, n_images, i);
        imshow(img);
        titleString = "image "+num2str(i)+"";
        [binaryCode, centroidLocations] = identifyBeaconId(img);
        for idx=1:length(binaryCode)
           if binaryCode(idx) ~= -1
                range = beaconDistance(centroidLocations(idx,:));
                b = beaconBearing(centroidLocations(idx,:));
                titleString = sprintf("%s\nid%s r%.2f b%.2f", titleString, num2str(binaryCode(idx)), range, b);          
           end
        end
        
        title(titleString)
    end
end
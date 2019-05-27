function plotLandmarks(landmarks)
    ids = cell2mat(landmarks.keys);
    locs = cell2mat(landmarks.values)';
    
    for i = 1:length(locs)
        id = ids(i*6-5:i*6);
        loc = locs(i, :);
        
        plot(loc(1), loc(2), 'kp');
        plotBeacon(loc, id);
    end
end
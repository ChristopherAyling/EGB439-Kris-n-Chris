function [z, map, sensed] = sense(q, Pb, landmarks)
% SENSE return a column vector of [range, bearing, id] values
    z = [];
    map = [];
    sensed = [];
    img = Pb.getImage();
%     load('30cm.mat')
    [binaryCodes, centroidLocations] = identifyBeaconId(img);
    for idx=1:length(binaryCodes)
       if binaryCodes(idx) ~= -1

           r = beaconDistance(centroidLocations(idx,:));
           b = beaconBearing(centroidLocations(idx,:));
           b = deg2rad(b);
           x = q(1);
           y = q(2);
           t = q(3);
           loc = [
                x + r * cos(t + b)
                y + r * sin(t + b)
           ]';
       
           z = [z; r b];
           map = [map; landmarks(landmarks(:, 1) == binaryCodes(idx), 2:end)];
           sensed = [sensed; loc binaryCodes(idx)];
       end
    end
end
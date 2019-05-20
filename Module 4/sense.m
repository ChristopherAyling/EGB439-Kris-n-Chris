function z = sense(q, Pb)
% SENSE return a column vector of [range, bearing, id] values
    z = [];
    img = Pb.getImage();
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
           ];
           z = [z; binaryCodes(idx) r b loc'];
       end
    end
end
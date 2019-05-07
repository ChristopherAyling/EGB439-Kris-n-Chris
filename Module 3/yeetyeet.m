clf
figure(1)
axis square;
grid on
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on
% img = Pb.getImage();

q = [1 1 deg2rad(90)];
plotBotFrame(q);

% take photo
[binaryCode, centroidLocations] = identifyBeaconId(img);
for idx=1:length(binaryCode)
   if binaryCode(idx) ~= -1
        range = beaconDistance(centroidLocations(idx,:));
        b = beaconBearing(centroidLocations(idx,:));
        b = deg2rad(b)
        x = q(1);
        y = q(2);
        t = q(3);
        loc = [
            x + range * cos(t + b)
            y + range * sin(t + b)
        ];
        plotBeacon(loc, binaryCode(idx))
   end
end
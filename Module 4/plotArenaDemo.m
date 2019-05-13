unloadingAreas = [
    0.5 0.8 deg2rad(45);
    1.5 0.8 deg2rad(135);
];

landmarks = [
    0.1 0.1;
    1.9 1.9;
    0.1 1.9;
    1.9 0.1;
];

qs = [
    [1, 1, deg2rad(90)];
    [1.1, 1.1, deg2rad(90)];
    [1.2, 1.2, deg2rad(90)];
    [1.3, 1.3, deg2rad(90)];
];

S = diag([0.4, 0.8 5*pi/180]).^2;
S = S / 200;

covs = [
    S;
    S;
    S;
    S;
];

for step = 1:length(qs)
    sqs = qs(1:step, :)
    scovs = covs(1:step*3, :)
    plotArena(sqs, scovs, unloadingAreas, landmarks)
    pause(0.2)
end

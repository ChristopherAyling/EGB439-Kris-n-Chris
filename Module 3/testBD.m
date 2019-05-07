%Pb = PiBot('172.19.232.200', '172.19.232.11', 32);
%img = Pb.getImage();
%idisp(img)

cm30 = load("images/30cm.mat");
cm45 = load("images/45cm.mat");
cm60 = load("images/60cm.mat");
cm90 = load("images/90cm.mat");
cm120 = load("images/120cm.mat");
cm150 = load("images/150cm.mat");


cm30 = cm30.img;
cm45 = cm45.img;
cm60 = cm60.img;
cm90 = cm90.img;
cm120 = cm120.img;
cm150 = cm150.img;

%{
figure;
idisp(cm30);
figure;
idisp(cm45);
figure;
idisp(cm60);
figure;
idisp(cm90);
figure;
idisp(cm120);
figure;
idisp(cm150);
%}


% 30
[var, locs] = identifyBeaconId(cm30);
bd30 = beaconDistance(locs);

% 45
[var, locs] = identifyBeaconId(cm45);
bd45 = beaconDistance(locs);

% 60
[var, locs] = identifyBeaconId(cm60);
bd60 = beaconDistance(locs);

% 90
[var, locs] = identifyBeaconId(cm90);
bd90 = beaconDistance(locs);

% 120
[var, locs] = identifyBeaconId(cm120);
bd120 = beaconDistance(locs);

% 150
[var, locs] = identifyBeaconId(cm150);
bd150 = beaconDistance(locs);

pass = 0;
fail = 6;

if(bd30 >= 0.25 && bd30 <= 0.35)
    pass = pass + 1;
end
if(bd45 >= 0.4 && bd45 <= 0.5)
    pass = pass + 1;
end
if(bd60 >= 0.55 && bd60 <= 0.65)
    pass = pass + 1;
end
if(bd90 >= 0.85 && bd90 <= 0.95)
    pass = pass + 1;
end
if(bd120 >= 1.15 && bd120 <= 1.25)
    pass = pass + 1;
end
if(bd150 >= 1.45 && bd150 <= 1.55)
    pass = pass + 1;
end

fail = fail - pass;
disp("Fail: ");
disp(fail);
disp("Pass: ");
disp(pass);


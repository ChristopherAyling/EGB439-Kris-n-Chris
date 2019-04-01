% Pb = PiBot('172.19.232.191', '172.19.232.12', 32);

% image = getLocalizerImage(Pb);
normImage = double(image) / 255;
biColour = (normImage > 0.9) - (normImage > 0.25);
biColourClean = bwareaopen(biColour, 700);
occupancyGrid = imresize(biColourClean, 1/5);

%RGB  = zeros(100, 100, 3);  % RGB Image
%R    = RGB(:, :, 1) + occupancyGrid;
%G    = RGB(:, :, 2) + (occupancyGrid).^-1 - occupancyGrid;
%B    = RGB(:, :, 3);
%colourisedGrid = cat(3, R, G, B);

figure;

pixelsInM = 50;

goal = [0.3 0.3] * pixelsInM;
start = [1.6 1.6] * pixelsInM;

theta = 180;

dx = DXform(occupancyGrid);
dx.plan(goal)

p = dx.query(start);

hold on;
idisp(colourisedGrid, 'xydata', {[0 2], [0 2]});
xlabel('u (metres)') 
ylabel('v (metres)') 
hold off;

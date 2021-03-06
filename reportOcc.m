% Connect to bot
Pb = PiBot('172.19.232.171', '172.19.232.11', 32);

% Get Image
image = getLocalizerImage(Pb);
figure(1)
idisp(image);

% make occupancy grid
normImage = double(image) / 255;
biColour = (normImage > 0.05) - (normImage > 0.5);
biColourClean = bwareaopen(biColour, 1000);
occupancyGrid = imresize(biColourClean, 1/5);

figure(2)
idisp(occupancyGrid);

% create enlarged version of occupancy grid for navigation
thickenOperations = 1;
occupancyFilled = bwmorph(occupancyGrid, 'fill');
occupancyNav = bwmorph(occupancyFilled, 'thicken', thickenOperations);
occupancyNav = bwmorph(occupancyNav, 'open', 20);

occupancyNav =  conv2(occupancyNav, ones(6), 'same');

occupancyNav = bwmorph(padarray(occupancyNav, [1, 1], 1, 'both'), 'thicken', 3);
occupancyNav = bwmorph(occupancyNav, 'close');

figure(3)
idisp(occupancyNav);

RGB  = zeros(100, 100, 3);  % RGB Image
R    = RGB(:, :, 1) + occupancyGrid;
G    = RGB(:, :, 2) + (occupancyGrid).^-1 - occupancyGrid;
B    = RGB(:, :, 3);
colourisedGrid = cat(3, R, G, B);

figure(4)
idisp(colourisedGrid)
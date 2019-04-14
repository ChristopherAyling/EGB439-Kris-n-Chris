% Connect to bot
Pb = PiBot('172.19.232.173', '172.19.232.11', 32);

% Get Image
image = getLocalizerImage(Pb);

% make occupancy grid
normImage = double(image) / 255;
biColour = (normImage > 0.04) - (normImage > 0.2); %0.25 ->
biColourClean = bwareaopen(biColour, 1000);
occupancyGrid = imresize(biColourClean, 1/5);
idisp(occupancyGrid)

figure
% create enlarged version of occupancy grid for navigation
thickenOperations = 5;
occupancyFilled = bwmorph(occupancyGrid, 'fill');
occupancyNav = bwmorph(occupancyFilled, 'thicken', thickenOperations);
occupancyNav = bwmorph(occupancyNav, 'close');
occupancyNav(:, 1) = 1; occupancyNav(1, :) = 1; occupancyNav(end, :) = 1; occupancyNav(:, end) = 1; 
idisp(occupancyNav)
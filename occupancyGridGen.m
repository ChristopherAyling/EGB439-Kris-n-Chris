Pb = PiBot('172.19.232.173', '172.19.232.12', 32);

image = getLocalizerImage(Pb);
normImage = double(image) / 255;
biColour = (normImage > 0.9) - (normImage > 0.15);
biColourClean = bwareaopen(biColour, 800);
occupancyGrid = imresize(biColourClean, 1/5);

RGB  = zeros(100, 100, 3);  % RGB Image
R    = RGB(:, :, 1) + occupancyGrid;l
G    = RGB(:, :, 2) + (occupancyGrid).^-1 - occupancyGrid;
B    = RGB(:, :, 3);
colourisedGrid = cat(3, R, G, B);

idisp(colourisedGrid, 'xydata', {[0 2], [0 2]});
xlabel('u (metres)') 
ylabel('v (metres)') 
hold on;
plot(50, 50, 'bp')
pose = Pb.getLocalizerPose();
drawOnlyBot(pose.pose.x, pose.pose.y, pose.pose.theta)
hold off;

function drawOnlyBot(x, y, theta)
    y = 2 - y;
    theta = deg2rad(theta);
    loc = [x y];
    
    LENGTH = 0.15;
    WIDTH = 0.18;
    BAXOFFSET = 0.05; % Bot origin offset from back axle
    
    r = [
        cos(theta) -sin(theta);
        sin(theta) cos(theta);
    ];

    a = [LENGTH-BAXOFFSET 0];
    b = [-BAXOFFSET WIDTH/2];
    c = [-BAXOFFSET -WIDTH/2];
    
    ar = (a*r)+loc;
    br = (b*r)+loc;
    cr = (c*r)+loc;
    
    plot(ar(1), ar(2), 'b*')
    plot(br(1), br(2), 'bo')
    plot(cr(1), cr(2), 'bo')
    
    fill([ar(1), br(1), cr(1)], [ar(2), br(2), cr(2)], 'b');
%     alpha(.5);
end
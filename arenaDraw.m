function arenaDraw(xLoc, yLoc, theta, pathX, pathY)
    arenaSize = [2, 2];
%arenaDraw draws the robot as an isoc. triangle on an arena-like grid
%   xLoc, yLoc, theta
<<<<<<< HEAD
    triangleX = [0, 0.15, 0, 0] - 0.15 + xLoc;
    triangleY = [0, 0.090, 0.18, 0] - 0.00 + yLoc;
=======
    LENGTH = 150;
    WIDTH = 180;
    triangleX = [0, 150, 0, 0] - LENGTH + xLoc;
    triangleY = [0, 90, 180, 0] - (WIDTH/2) + yLoc;
>>>>>>> 5db9de31187c937910e42fc53815b2ae7d563d2d
    
    robot = [triangleX; triangleY];
    
    rotAxisX = triangleX(2) - 0.075;
    rotAxisY = triangleY(2);
    
    center = repmat([rotAxisX; rotAxisY], 1, length(triangleX));
    
    theta = degtorad(theta) + 90;
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    
    s = robot - center;
    so = R*s;
    vo = so + center;
    
    xRotated = vo(1,:);
    yRotated = vo(2,:);

    clf;
    ax = gca;
    ax.YDir = 'reverse';
    axis([0 arenaSize(1) 0 arenaSize(2)])
    
    hold on;
        plot(pathY, pathX, '*-r');
        plot(yRotated, xRotated, '-');
        plot(yRotated(2), xRotated(2), '*o');   
    hold off;

end


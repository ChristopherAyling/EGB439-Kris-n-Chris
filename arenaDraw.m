function arenaDraw(xLoc, yLoc, theta)
    arenaSize = [2000, 2000];
%arenaDraw draws the robot as an isoc. triangle on an arena-like grid
%   xLoc, yLoc, theta
    triangleX = [0, 150, 0, 0] - 150 + xLoc;
    triangleY = [0, 90, 180, 0] - 90 + yLoc;
    
    robot = [triangleX; triangleY];
    
    rotAxisX = triangleX(2) - 75;
    rotAxisY = triangleY(2);
    
    center = repmat([rotAxisX; rotAxisY], 1, length(triangleX));
    
    theta = degtorad(theta);
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
        plot(xRotated, yRotated);
    hold off;

end


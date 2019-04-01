function week6graphics(occupancyGrid, q, plannedPath, actualPath, start, goal)
    clf;
    axis square;
    ARENASIZE = [2, 2];
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
    set(gcf, 'Menubar','none')
    % occupancy grid
    plotOccupancyGrid(occupancyGrid);
    hold on;
    
    % robot
    plotBot(q(1), q(2), q(3))
    
    % planned path
    plotPlannedPath(plannedPath)
    
    % actual path
    plotActualPath(actualPath)
    
    % initial point
    plot(start(1), start(2), 'ko')
    
    % goal point
    plot(goal(1), goal(2), 'kp')
    hold off;
end

function plotOccupancyGrid(occupancyGrid)
    idisp(occupancyGrid, 'xydata', {[0 2], [0 2]}, 'nogui', 'ynormal');
end

function plotPlannedPath(plannedPath)
    pathY = plannedPath(:,1);
    pathX = plannedPath(:,2);
    plot(pathY, pathX, 'k--');
end

function plotActualPath(actualPath)
    pathY = actualPath(:,1);
    pathX = actualPath(:,2);
    plot(pathY, pathX, 'r-');
end

function plotBot(x, y, theta)
    y = y; % might have to be 2-y
    theta = -radtodeg(theta);
    loc = [x y];
    
    LENGTH = 0.15;
    WIDTH = 0.18;
    BAXOFFSET = 0.05; % Bot origin offset from back axle
    
    r = [
        cosd(theta) -sind(theta);
        sind(theta) cosd(theta);
    ];

    a = [LENGTH-BAXOFFSET 0];
    b = [-BAXOFFSET WIDTH/2];
    c = [-BAXOFFSET -WIDTH/2];
    
    ar = (a*r)+loc;
    br = (b*r)+loc;
    cr = (c*r)+loc;
    
    plot(ar(1), ar(2), 'b*') % front
    plot(br(1), br(2), 'bo') % back corner
    plot(cr(1), cr(2), 'bo') % back corner
    
    fill([ar(1), br(1), cr(1)], [ar(2), br(2), cr(2)], 'b');
    plot(loc(1), loc(2), 'kp') % origin
%     alpha(.5);
end
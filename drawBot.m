function drawBot(x, y, theta, pathX, pathY, goalx, goaly)
    loc = [x y];
    
    ARENASIZE = [2, 2];
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
    
    clf;
    axis square;
    ax = gca;
    ax.YDir = 'reverse';
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
    
    hold on;
%     axis([-4 4 -4 4]);
    set(gca, 'color', [0.3 0.6 0.3])
    plot(pathY, pathX, '*-r');
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
    plot(0, 0, 'g*') % arena origin
    plot(x, y, 'k*') % bot origin
    plot(goalx, goaly, 'kp') % goal
    
    plot(ar(1), ar(2), 'b*')
    plot(br(1), br(2), 'bo')
    plot(cr(1), cr(2), 'bo')
    
    fill([ar(1), br(1), cr(1)], [ar(2), br(2), cr(2)], 'b');
    alpha(.5);
    hold off;
end
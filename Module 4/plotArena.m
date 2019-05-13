function plotArena(qs, covs, unloadingAreas, landmarks)
    % setup plot
    clf;
    axis square;
    ARENASIZE = [2, 2];
    axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
    set(gca,'Color',[56, 118, 9]/255)
    hold on
    
    origin = [1, 1, deg2rad(90)];
    nSigma = 3;
    
    % plot all elements
    plotOrigin(origin);
    plotUnloadingAreas(unloadingAreas);
    plotLandmarks(landmarks);
%     plotBot(qs(end, :));
    plotQs(qs(1:end, :));
       
    plotCovs(covs, qs, 3);
    
    hold off
end

function plotBot(q)
    x = q(1);
    y = q(2); % might have to be 2-y
    theta = -radtodeg(q(3));
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

function plotQs(qs)
    
    for i = 1:size(qs, 1)
       q = qs(i,:);
       plotBotFrame(q);
    end
end

function plotOrigin(origin)
    plot(origin(1), origin(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', [207, 226, 243]/255)
    plot(origin(1), origin(2), 'k+', 'MarkerSize', 10)
end

function plotUnloadingAreas(unloadingAreas)
    for i = 1:size(unloadingAreas, 1)
       ua = unloadingAreas(i, :);
       plotUnloadingArea(ua);
    end
end

function plotLandmarks(landmarks)
    for i = 1:length(landmarks)
        lm = landmarks(i, :);
        plot(lm(1), lm(2), 'ko', 'MarkerSize', 15, 'MarkerFaceColor', [255, 217, 102]/255) 
    end
end

function plotBotFrame(q)
    %PLOTBOTFRAME plot a robots coordinate frame
    % q is the robots configuration vector [x, y, theta]
    %   x: x coordinate of the robot in the world frame
    %   y: y coordinate of the robot in the world frame
    %   theta: heading angle in the world frame (in degrees)
    x = q(1);
    y = q(2);
    theta = -rad2deg(q(3)); % in degrees

    loc = [x y];

    r = [
        cosd(theta) -sind(theta);
        sind(theta) cosd(theta);
    ];

    xpointerLength = 0.1;
    ypointerLength = (2/3)*xpointerLength;

    xpointer = [xpointerLength 0];
    ypointer = [0 ypointerLength];

    xpointerR = (xpointer*r)+loc;
    ypointerR = (ypointer*r)+loc;

    % plot x pointer
    plot([x, xpointerR(1)], [y, xpointerR(2)], 'r-', 'LineWidth', 1.5)
    %     % plot y pointer
    plot([x, ypointerR(1)], [y, ypointerR(2)], 'b-', 'LineWidth', 1.5)
    % plot origin
    plot(x, y, 'k.', 'MarkerSize', 12)
end

function plotUnloadingArea(q)
    x = q(1);
    y = q(2);
    theta = -radtodeg(q(3));
    loc = [x y];
    
    r = [
        cosd(theta) -sind(theta);
        sind(theta) cosd(theta);
    ];

    squadius = 0.12;

    fl = [1, 1];
    fr = [-1, 1];
    bl = [-1, -1];
    br = [1, -1];
    
    corners = [
        fl; fr; bl; br;
    ] * squadius;

    rotted = [];
    for i = 1:length(corners)
       corner = corners(i, :);
       rotted = [rotted; (corner*r)+loc];
    end
    
    plot(rotted(:,1), rotted(:, 2), 'k-')
end

function plotCovs(covs, qs, nSigma)
    n = 1;
    for i=1:size(qs, 1)
       cvv = covs(n:n+2, :);
       n = n + 3;
       q = qs(i, :)';
       plot_cov(q, cvv, nSigma);
    end
end

function plot_cov(x,P,nSigma)
    disp("plotting cov")
    P = P(1:2,1:2)
    x = x(1:2)
    if(~any(diag(P)==0))
        disp("plotting cov with diag")
        [V,D] = eig(P);
        y = nSigma*[cos(0:0.1:2*pi);sin(0:0.1:2*pi)];
        el = V*sqrtm(D)*y;
        el = [el el(:,1)]+repmat(x,1,size(el,2)+1);
        line(el(1,:),el(2,:), 'Color', [0.3010 0.7450 0.9330], 'LineStyle', '--', 'LineWidth', 1.5);
    end
end

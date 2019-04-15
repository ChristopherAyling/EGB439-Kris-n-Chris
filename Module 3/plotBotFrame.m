function plotBotFrame(q)
    %PLOTBOTFRAME plot a robots coordinate frame
    % q is the robots configuration vector [x, y, theta]
    %   x: x coordinate of the robot in the world frame
    %   y: y coordinate of the robot in the world frame
    %   theta: heading angle in the world frame (in degrees)
    x = q(1);
    y = q(2);
    theta = -q(3); % in degrees

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
    plot([x, xpointerR(1)], [y, xpointerR(2)], 'b-', 'LineWidth', 1.5)
    %     % plot y pointer
    plot([x, ypointerR(1)], [y, ypointerR(2)], 'r-', 'LineWidth', 1.5)
    % plot origin
    plot(x, y, 'k.', 'MarkerSize', 12)
end


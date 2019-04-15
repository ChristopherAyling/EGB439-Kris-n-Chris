function plotBotFrame(q)
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

    % plot origin
    plot(x, y, 'k*')
    % plot x pointer
    plot([x, xpointerR(1)], [y, xpointerR(2)], 'b-', 'LineWidth', 3)
    %     % plot y pointer
    plot([x, ypointerR(1)], [y, ypointerR(2)], 'r-', 'LineWidth', 3)
end


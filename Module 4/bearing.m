function b = bearing(p1, p2, theta)
    %BEARING
    % theta is in radians
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    
    b = wrapToPi(atan2(y2-y1, x2-x1) - theta);
end

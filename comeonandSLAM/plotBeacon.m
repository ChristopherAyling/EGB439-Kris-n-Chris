function plotBeacon(loc, id)
    %PLOTBEACON plot a beacon (and optionally its id)
    % loc is the beacon's location [x, y]
    % id (optional) is the beacon's id as either an integer or bitstring
    %
    % >> plotBeacon([1, 1], 57); 
    % plots a beacon at point (1, 1) as well as the id 57 and it's
    % bitstring representation 111001
    %
    % >> plotBeacon([1, 1], '111001')
    % does the same as above.

    x = loc(1);
    y = loc(2);
    
    keySet = {'111001','110110','100111','011011', '101101', '011110'};
    valueSet = {'m', 'c', 'r', 'g', 'b', 'y'};
    M = containers.Map(keySet,valueSet);
    
    if nargin > 1
        % if id is bitstring, convert it to number
        if ischar(id) || isstring(id)
           id = bin2dec(id);
        end
        id
        plot(x, y, M(dec2bin(id, 6))+"o", 'MarkerSize', 8, 'LineWidth', 3)
        text(x+0.03, y+0.04, num2str(id), 'fontName','Comic Sans MS')
    else
        plot(x, y, 'ko', 'MarkerSize', 8, 'LineWidth', 3)
    end
end


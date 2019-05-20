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
    
    plot(x, y, 'ko', 'MarkerSize', 6, 'LineWidth', 3)
    
    if nargin > 1
        % if id is bitstring, convert it to number
        if ischar(id) || isstring(id)
           id = bin2dec(id);
        end
        text(x+0.03, y+0.04, num2str(id), 'fontName','Comic Sans MS')
%         text(x+0.03, y-0.04, dec2bin(id), 'fontName','Comic Sans MS')
    end
end


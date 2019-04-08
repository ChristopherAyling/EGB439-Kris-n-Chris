function angleDisp(pb, q)
    x = q(1);
    y = q(2);
    theta = q(3);
    
    if (x > 1) && (y > 1) % Q1
        disp('Q1')
        if (theta <= 90)
            bottomRight(pb)
        elseif (theta <= 180)
            bottomLeft(pb)
        elseif (theta <= 270)
            topLeft(pb)
        else
            topRight(pb)
        end
    elseif (x > 1) && (y < 1) %Q2
        disp('Q2')
        if (theta <= 90)
            bottomRight(pb)
        elseif (theta <= 180)
            bottomLeft(pb)
        elseif (theta <= 270)
            topLeft(pb)
        else
            topRight(pb)
        end
    elseif (x < 1) && (y < 1) %Q3
        disp('Q3')
        if (theta <= 90)
            topLeft(pb)
        elseif (theta <= 180)
            topRight(pb)
        elseif (theta <= 270)
            bottomRight(pb)
        else
            bottomLeft(pb)
        end
    else %Q4
        disp('Q4')
    end
end

function topLeft(pb)
    pb.setLEDArray(bin2dec('1100 1100 0000 0000'))
    pause(0.2)
end

function topRight(pb)
    pb.setLEDArray(bin2dec('0000 0000 1100 1100'))
    pause(0.2)
end

function bottomLeft(pb)
    pb.setLEDArray(bin2dec('0011 0011 0000 0000'))
    pause(0.2)
end

function bottomRight(pb)
    pb.setLEDArray(bin2dec('0000 0000 0011 0011'))
    pause(0.2)
end
function [xt,S] = predictStep(xt,S,d,dth,R)
    x = xt(1);
    y = xt(2);
    theta = xt(3);

    xt = [
        x+(d*cos(theta));
        y+(d*sin(theta));
        wrapToPi(theta+dth);
    ];

    Jx = [
        1 0 -d*sin(theta);
        0 1 d*cos(theta);
        0 0 1;
    ];

    Ju = [
        cos(theta) 0;
        sin(theta) 0;
        0 1;
    ];

    S = Jx*S*Jx' + Ju*R*Ju'; 
end
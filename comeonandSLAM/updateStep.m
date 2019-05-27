function [x,S] = updateStep(map,Z,x,S,Q)
    zks = keys(Z);
    mks = keys(map);
    
    for i=1:length(Z)
        z = Z(zks{i})';
        xr = x(1);
        yr = x(2);
        theta = x(3);
        lm = map(zks{i})';

        r = z(1);
        b = z(2);

        xl = lm(1);
        yl = lm(2);

        G = [
            -(xl-xr)/r, -(yl-yr)/r, 0;
            (yl-yr)/(r*r), -(xl-xr)/(r*r), -1;
        ];

        h = [
            sqrt((xl-xr)^2+(yl-yr)^2)
            wrapToPi(atan2(yl-yr, xl-xr)-theta)
        ];

        K = S*G'*(G*S*G' + Q)^-1;

        err = z(:)-h';
        err = [err(1); wrapToPi(err(2))];
        x = x + K*(err);
        x = [x(1), x(2), wrapToPi(x(3))]';
        S = (eye(length(K)) - K*G)*S;
    end
end
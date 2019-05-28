function [x,S] = updateStepReport(map,z,x,S,Q)
    % For each landmark...
    for i = 1:length(z)
        % separate out variables
        xr = x(1);
        yr = x(2);
        thr = x(3);        
        
        % we just need ri from z (the second index is Bi, but we don't need
        % it nto be separated)
        r = z(i, 1);

        % we'll need the xl and xr vars separated
        xl = map(i, 1);
        yl = map(i, 2);

        % G Jacobians Matrix
        G = [
                -(xl - xr) / r, -(yl - yr) / r, 0;
                (yl - yr) / (r^2), -(xl - xr) / (r^2), -1;
            ];

        % Range and bearing measurement model
        h = [
                sqrt((xl - xr)^2 + (yl - yr)^2)
                wrapToPi(atan2(yl - yr, xl - xr) - thr)
            ];
        
        % K 
        SG = (S * G');
        K = SG * (G * SG + Q)^-1;
        
        % Update ut
        err = (z(i, :) - h')';
        err(2) = wrapToPi(err(2));
        x = x + K * (err);
       
        % Create a correct-length identity matrox and calculate/update
        % sigmaT
        I = eye(length(K));
        S = (I - K * G) * S;
    end
end    
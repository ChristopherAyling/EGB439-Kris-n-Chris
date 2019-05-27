% this function takes:
    %  landmarkID: id of a landmark
    %   zi: the range and nearing to this landmark 
    %   Q: the covariance of the measurements
    %   mu,Sigma: the current estimate of the robot pose and the map.
    %   
    % The function returns mu and Sigma after performing
    % an update step using the sensor readings of
    % the landmark   
    
% Update Space Jam
function [mu, Sigma] = update_slam(landmarkID, zi, Q, mu, Sigma)
    % separate out variables
	xR = mu(1);
    yR = mu(2);
    thR = mu(3);        

    % we just need ri from z (the second index is Bi, but we don't need
    % it nto be separated)
    r = zi(1);

    % we'll need the xl and xr vars separated
    xl = mu(3 + landmarkID * 2 - 1);
    yl = mu(3 + landmarkID * 2);
    
   % Range and bearing measurement model
    h = [
            sqrt((xl - xR)^2 + (yl - yR)^2)
            wrapToPi(atan2(yl - yR, xl - xR) - thR)
        ];
    
    hR = h(1);

    % G Jacobians Matrix
    gTemp = -[
                -(xl - xR) / hR, -(yl - yR) / hR;
                (yl - yR) / (hR^2), -(xl - xR) / (hR^2);
             ];
    gTemp2 = [
                -(xl - xR) / hR, -(yl - yR) / hR, 0;
                (yl - yR) / (hR^2), -(xl - xR) / (hR^2), -1;
             ];
    zeroM = zeros(2, length(Sigma) - 3);
    G = [gTemp2, zeroM(:, 1:landmarkID*2 - 2), gTemp, zeroM(:, landmarkID*2 +1:end)];
    % K 
    SG = (Sigma * G');
    K = SG * (G * SG + Q)^-1;

    % Update ut
    err = (zi - h')';
    err(2) = wrapToPi(err(2));
    mu = mu + K * (err);

    % Create a correct-length identity matrox and calculate/update
    % sigmaT
    I = eye(length(K));
    Sigma = (I - K * G) * Sigma;  
end
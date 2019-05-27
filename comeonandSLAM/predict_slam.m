% This function takes:
%     mu,Sigma: the current estimate of the pose of the robot and the map.
%     as well as the odometry information (d the distance travelled from time step k-1 and k and dth, the change of heading) 
%     and the matrix R (the covariance of the odometry noise). 
%     The function performs a prediction step of the EKF localiser and returns the mean and covariance of the robot pose and the map.   
%     note: although the prediction step does not change the estimation 
%     of the landmarks in the map, this function accepts the full state space
%     and only alter the pose of the robot in it.

% Update Space Jam
function [mu,Sigma] =predict_slam(mu, Sigma, d, dth, R)
     % Seperating out prev. xt's theta (x, y are only used once so no need)
    x = mu(1);
    y = mu(2);
    th = mu (3);

    % New xt/ut
    xt = [
            x + (d * cos(th));
         	y + (d * sin(th));
         	wrapToPi(th + dth);
         ];
    
    mu = [xt; mu(4:end)]; 
     
    % Jacobians Matrix Jx 
    th = xt(3);
    
    jx = [
            1 0 (-d * sin(th));
            0 1 (d * cos(th));
            0 0 1;
         ];
    sigmaL = length(Sigma) - 3;
    lengthS = zeros(3, sigmaL);
    jx = [
            jx lengthS;
            lengthS' eye(sigmaL)
         ];
    
    % Jacobians Matrix Ju
    ju = [
            cos(th) 0;
            sin(th) 0;
            0       1;
         ];
    ju = [
           ju;
           zeros(sigmaL, 2)
         ];
    
    Sigma = jx * Sigma * jx' + ju * (R * ju'); 
end
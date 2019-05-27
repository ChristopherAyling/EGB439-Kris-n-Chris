% We use the sensor readings from the first time step 
% to initialise all the landmarks in the map. 
% this function takes:
%   z : The sensor measurements to all the landmarks 
%        at the current time step.
%   Q: the covariance of the measurements
%   mu,Sigma: the current estimate of the robot pose and the map (the map will be empty so the size of mu is 3x1 and Sigma 3x3).
% The function returns mu and Sigma after initialising (if n is the number of landmarks, the function returns mu of size (3+2n)x1 and Sigma of size (3+2n)x(3+2xn))
% all t he landmarks

% Initiate Space Jam
function [mu, Sigma] = initLandmarksSlam(z, Q, mu, Sigma)
    for i = 1:length(z)
       % separate z into r, B
       r = z(1);
       B = z(2);

       % seperate locs into x, y, z
       x = mu(1);
       y = mu(2);
       thr = mu(3);

       thrBWrapped = wrapToPi(thr + B);
       % calc lNew
       lNew = [
                x + r * cos(thrBWrapped);
                y + r * sin(thrBWrapped)
              ];

       mu = [mu; lNew];
       
       lZ = [
                cos(thrBWrapped), -r * sin(thrBWrapped);
                sin(thrBWrapped), r * cos(thrBWrapped)
            ];
       zeroM = zeros(length(Sigma), 2);
       Sigma = [Sigma,  zeroM; 
                zeroM', (lZ * Q * lZ')];
   end
end
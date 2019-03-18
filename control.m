function vel = control(q, point)
    % vel = control(q, goal) is an application specific function, that 
    % computes the wheel speeds vel (as above) that will move the robot 
    % towards its goal point (2x1 coordinate vector) given an initial 
    % configuration of q.  The aim is to get ever closer to the goal at 
    % each time step, not to reach it in a single timestep.  For this 
    % question we want a controller that will drive the robot towards the 
    % goal point (from any point within the arena which is 2m square) within 
    % 200 time steps with a sample interval of 0.2 seconds.  When the robot
    % is within 10mm of the goal point it should stop. The function must 
    % always return velocities within the range Vl Vr E [-100 ... +100].  
    % This will call vw2wheels().

    % Inputs:   
    % q is the initial configuration vector (x, y, theta) in units of metres and radians
    % point is the vector (x, y) specifying the goal point of the robot
    
    % This bad boy uses a linear controller
    
    % Seperate out our q matrix for that readability
    x = q(1);
    y = q(2);
    theta = q(3);
    % ...and the p matrix
    xGoal = point(1);
    yGoal = point(2);
    
    % Velocity and Angular Gain Respectively
    gainV = 0.5;
    gainTheta = 8;
    
    % diffX and diffY
    xDiff = xGoal - x;
    yDiff = yGoal - y;
    
    % pythagboi
    c = sqrt((xDiff) ^ 2 + (yDiff) ^ 2);
    
    if c >= 0.01
        % Absolute madlad of a velocity formula
        v = gainV * sqrt((xDiff) ^ 2 + (yDiff) ^ 2);

        % Madder lad of a theta formula
        thetaGoal = atan2(yDiff, xDiff);

        % Angular (w)   
        diffTheta = wrapToPi(thetaGoal - theta);
       
        w = gainTheta * diffTheta;

        % return vel VL VR via vw2wheels

        vel = vw2wheels([v w]);
    else
        vel = [0 0];
    end
end
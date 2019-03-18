function qd = qdot(q, vel)
    % qd = qdot(vel) returns the configuration rate of change given the 
    % wheel velocities, as a 1x2 vector vel = [VL VR], where Vl Vr E 
    % [-100 ... +100].    qd should have units of m/s and rad/s. 
    % This will call wheels2vw().

    % Inputs:
    % q is the configuration vector (x, y, theta) in units of metres and radians
    % vel is the velocity vector (vleft, vright) each in the range -100 to +100
    
    % x y theta vars. for readability
    x = q(1);
    y = q(2);
    theta = q(3);
    
    % Wheel Vars.
    wheelDiameter = 0.065;
    lateralWheelSpacing = 0.16;
    
    % Conversion to RPM from VL VR
    wheelVel2RPM = 2;
    rpm = vel / wheelVel2RPM;
    vWheels = pi *  wheelDiameter * rpm * (1/60);
    
    % Difference in Velocity
    vDelta = vWheels(2) - vWheels(1);
    
    % Velocity via formula
    v = 1/2 * (vWheels(1) + vWheels(2));
    
    % x, y, theta change
    xDot = v*cos(theta);
    yDot = v*sin(theta);
    thetaDot = vDelta / lateralWheelSpacing;
    
    % return qdot as vector
    qd = [xDot, yDot, thetaDot];
    
    % Return:
    % qd is the vector (xdot, ydot, thetadot) in units of metres/s and radians/s
end
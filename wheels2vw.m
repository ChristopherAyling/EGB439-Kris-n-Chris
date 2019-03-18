function vw = wheels2vw(wheelVel)
    % vw = wheels2vw(wheelVel) returns the velocity and angular velocity as 
    % a 1x2 vector [v, w] given the wheel velocity vector wheelVel = [VL VR], 
    % where Vl Vr E [-100 ... +100]. 
    % Inputs:
    % wheelVel is the wheel velocity vector (vleft, vright) each in the range -100 to +100
    
    % Wheel Vars.
    wheelDiameter = 0.065;
    lateralWheelSpacing = 0.16;
    
    % Conversion to RPM from VL VR
    wheelVel2RPM = 2;
    rpm = wheelVel / wheelVel2RPM;
    vWheels = pi *  wheelDiameter * rpm * (1/60);
    
    % Difference in Velocity
    vDelta = vWheels(2) - vWheels(1);
    
    % Angle via wheel spacing and difference in velocity
    omega = vDelta / lateralWheelSpacing;
    
    % Velocity via formula
    v = 1/2 * (vWheels(1) + vWheels(2));
    
    % Return:
    % vw is the resulting velocity vector (v, omega) in units of metres/s and radians/s
    vw = [v, omega]; 
end
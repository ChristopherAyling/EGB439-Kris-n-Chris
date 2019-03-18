function qnew = qupdate(q, vel, dt)
    % qnew = qupdate(q, vel, dt) returns the new configuration due to the 
    % robot moving at velocity vel (as above) for a period of dt. You will 
    % convert the velocity vel to the robot's configuration rate q and 
    % integrate using rectangular integration over the time step.  
    % This will call qdot().

    % Inputs:
    % q is the configuration vector (x, y, theta) in units of metres and radians
    % vel is the velocity vector (vleft, vright) each in the range -100 to +100
    % dt is the length of the integration timestep in units of seconds
    
    qd = qdot(q, vel);
    
    % change over time plus start pos
    qnew = (dt*qd) + q;
    
    % Return:
    % qnew is the new configuration vector vector (x, y, theta) in units of metres and radians at the
    % end of the time interval.
end
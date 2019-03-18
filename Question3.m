wheelVel = myFunction('vw2wheels', [0.2 -0.1]);
vw = myFunction('wheels2vw', [30 50]);
q = [1 2 0.5];
qd = myFunction('qdot', q, [30 50]);
qnew = myFunction('qupdate', q, [30 50], 0.2);
vel = myFunction('control', q, [4 5]);
% compute occupancy grid
dx = DXform(flipud(occupancyNav));

pose = Pb.getLocalizerPose();
start = [pose.pose.x, pose.pose.y];

startInPx = ceil(start * 50);
goalInPx = [90 90];

% compute distance transform
dx.plan(goalInPx);

% compute shortest path 
p = dx.query(startInPx);

axis square
axis ij
dx.plot(p)
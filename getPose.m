function q = getPose(Pb)
    pose = Pb.getLocalizerPose();
    while pose.pose.x == 0 && pose.pose.y == 0
            pose = Pb.getLocalizerPose();
    end
    q = [
        pose.pose.x, pose.pose.y, pose.pose.theta
    ];
end


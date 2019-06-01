function q = getPose(Pb)
    % Ensures that the returned pose isn't [0 0 0]
    pose = Pb.getLocalizerPose();
    while pose.pose.x == 0 && pose.pose.y == 0
            pose = Pb.getLocalizerPose();
    end
    q = [
        pose.pose.x, pose.pose.y, deg2rad(pose.pose.theta)
    ];
end

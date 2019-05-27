function points = mu2points(mu)
    % get just landmark data from mu
    landmarks = mu(4:end);
    
    % change shape
    points = reshape(landmarks, 2, length(landmarks)/2)';
end
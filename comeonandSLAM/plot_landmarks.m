function plot_landmarks(mus, Sigma)
    locs = mu2points(mus);
    for i = 1:size(locs, 1)
        loc = locs(i, :)';
        cov = Sigma(i*2-1:2*i, i*2-1:2*i);
        plot_cov(loc, cov, 3)
    end
end
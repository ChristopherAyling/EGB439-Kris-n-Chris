function [mu, Sigma] = initLandmarks(z,Q,xr)
    x = xr(1);
    y = xr(2);
    theta = xr(3);
    
    mu = [];
    Sigma = [];
    
    for i = 1:length(z)
        r = z(i, 1);
        b = z(i, 2);
        
        % init mu
        lnew = [
           x+r*cos(theta+b)
           y+r*sin(theta+b)
        ];
    
        mu = [
           mu;
           lnew;
        ];
    
        % init Sigma
        nrows = size(Sigma, 1);
        ncols = 2;
        zs = zeros(nrows, ncols);
        L = [
            cos(theta+b) -r*sin(theta+b);
            sin(theta+b) r*cos(theta+b);
        ];
        snew = L*Q*L';
        Sigma = [
            Sigma zs;
            zs' snew;
        ];
    end     
end
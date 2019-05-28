function [xt,S] = predictStepReport(xt,S,d,dth,R)
    % Seperating out prev. xt's theta (x, y are only used once so no need)
    th = xt(3);

    % New xt/ut
    xt = [
            xt(1) + (d * cos(th));
         	xt(2) + (d * sin(th));
         	wrapToPi(th + dth);
         ];
    
    % Jacobians Matrix Jx 
    jx = [
            1 0 (-d * sin(th));
            0 1 (d * cos(th));
            0 0 1;
         ];
    
    % Jacobians Matrix Ju
    ju = [
            cos(th) 0;
            sin(th) 0;
            0       1;
         ];

    S = jx * S * jx' + ju * (R * ju'); 
end
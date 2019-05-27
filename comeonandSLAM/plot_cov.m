
function plot_cov(x,P,nSigma)
    disp("plotting cov")
    P = P(1:2,1:2);
    x = x(1:2);
    if(~any(diag(P)==0))
        disp("plotting cov with diag")
        [V,D] = eig(P);
        y = nSigma*[cos(0:0.1:2*pi);sin(0:0.1:2*pi)];
        el = V*sqrtm(D)*y;
        el = [el el(:,1)]+repmat(x,1,size(el,2)+1);
        line(el(1,:),el(2,:), 'Color', [0.3010 0.7450 0.9330], 'LineStyle', '--', 'LineWidth', 1.5);
    end
end
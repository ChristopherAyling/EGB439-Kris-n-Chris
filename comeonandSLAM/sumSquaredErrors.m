function sse = sumSquaredErrors(points, otherPoints)
    sse = sum((points-otherPoints).^2);
end
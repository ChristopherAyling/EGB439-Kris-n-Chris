gx = 1;
gy = 1;

xs = (1:10)*0.1;

figure;

pathX = ones(1, 10000);
pathY = ones(1, 10000);
a = 0;

for x = xs
    a = a + 1;
    pathX(a) = x;
    pathY(a) = x;
    
    drawBot(x, x, -45, pathX(1:a), pathY(1:a), gx, gy);
    pause(0.07);
end
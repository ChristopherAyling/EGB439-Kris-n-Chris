clf
figure(1)
axis square;
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on

q = [0, 0, 0];

plotBeacon([1.5, 1.5])
plotBeacon([1, 1.5])
plotBeacon([0.5, 1.5])

t = 0;
while t < 10
    t = t + 1;
    q = q + 0.1;
    q(3) = q(3)+10;
    plotBotFrame(q)
    pause(0.01)
end

hold off
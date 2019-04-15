clf
figure(1)
axis square;
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on

q = [1, 1, 0];

while true
    q(3) = q(3)+5;
    plotBotFrame(q)
    pause(0.1)
end

hold off
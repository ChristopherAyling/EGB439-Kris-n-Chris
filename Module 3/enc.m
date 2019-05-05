Pb = PiBot('172.19.232.171', '172.19.232.11', 32);
Pb.resetEncoder();

clf
figure(1)
axis square;
grid on
ARENASIZE = [2, 2];
axis([0 ARENASIZE(1) 0 ARENASIZE(2)])
hold on

dt = 0.5;
q = [0, 0, deg2rad(0)];
plotBotFrame(q);

steps = 10;
for i = 1:steps
    ticks = Pb.getEncoder();
    Pb.resetEncoder();
    q = newPose(q, ticks);
    plotBotFrame(q);
    Pb.setVelocity([50 50])
    pause(dt)
end

Pb.stop();
hold off

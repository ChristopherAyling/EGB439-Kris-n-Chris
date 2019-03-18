goal = [1 1];

q = [1.8 1.8 -pi/2];
qo = q;

dt = 0.2;

x = [];
y = [];

% simulate motion
for i=1:500
    vel = myFunction('control', q, goal);
    q = myFunction('qupdate', q, vel, dt);  % Run reference solution.
    % test if distance to goal is always reducing
    d = norm( [q(1) q(2)] - goal);
    x = [x q(1)]; y = [y q(2)];
end

plot(x, y)
xlabel('x'); ylabel('y'); grid on; title('Simulated robot path')
axis([0 2 0 2]);
hold on
plot(goal(1), goal(2), 'pk')
plot(qo(1), qo(2), 'ok')
hold off
legend('path', 'goal', 'start')
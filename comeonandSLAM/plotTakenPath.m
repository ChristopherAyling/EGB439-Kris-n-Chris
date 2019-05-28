function plotTakenPath(takenPath, c)
    for i = 1:size(takenPath, 1)
       x = takenPath(i, 1);
       y = takenPath(i, 2);
       theta = takenPath(i, 3);
       plot(x, y, c+"p", 'MarkerSize', 10)
       plotBotFrame([x, y, theta])
    end
end
test1 = load('images/101.mat');
test2 = load('images/10011.mat');
test3 = load('images/110110.mat');
test4 = load('images/1010100.mat');
test5 = load('images/1010111.mat');
test6 = load('images/1011111.mat');
test7 = load('images/1100001.mat');
test8 = load('images/1100101.mat');
test9 = load('images/1100110.mat');
test10 = load('images/1101100.mat');
test11 = load('images/1110101.mat');
test12 = load('images/1110111.mat');
test13 = load('images/1111010.mat');
tests = [test1; test2; test3; test4; test5;
         test6; test7; test8; test9; test10;
         test11; test12; test13];
     
expectedAns = [27, 45, -1, 39, 30, 27, 30, 27, 45, 27, 27, 30, 39];

sumFailed = 0;
sumPassed = 0;

for i = 1:length(expectedAns)
    disp("====CURRENT======");
    disp(i)   
    currentID = identifyBeaconId(tests(i).photo);
    if currentID == expectedAns(i)
        disp("Pass");
        sumPassed = sumPassed + 1;
    else
        disp("Expected: ");disp(expectedAns(i));
        disp("Got: ");disp(currentID);
        sumFailed = sumFailed + 1;
    end
end

disp("Sum Passed: ");disp(sumPassed);disp("Sum Failed: ");disp(sumFailed);
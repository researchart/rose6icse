% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ht,HA] = rundemo_ha_test

disp(' ')
disp(' This demo requires a number of toolboxes to be installed. ')
disp(' Please review the readme.txt file in the ha_robust_tester folder. ')
disp(' Press any key to continue ... ')
disp(' ')
pause


% initial location
init.loc = 13; 

% Initial (continuous) set = { x \in R^n | init(i,1) <= x(i) <= init(i,1)}
init.cube = [0.2 0.8
    3.2 3.8
    -0.4 0.4
    -0.4 0.4
    ];

% flow in each location
A = [4 2 3 4
    3 6 5 6
    1 2 3 6
    2 2 1 1];       

% unsafe set
unsafe.A = [eye(4); -eye(4)];
unsafe.b = [3.8; 0.8; 0.4; 0.4; -3.2; -0.2; 0.4; 0.4];
unsafe.loc = 4;

% Create hybrid automaton
HA = navbench_hautomaton([1 0 0 2 1 0 0 0 0], init, A, unsafe);

% initial conditions 
h0 = [13 0 0.4 3.4 0 0];

% total simulation time
tot_time = 2;

% Run simulator
ht = hasimulator(HA,h0,tot_time,'ode45',[1,0,0,0]);

hold on
plot(ht(:,3),ht(:,4))

% Run robust tester
[~, ~, ~, ~, ~, ell] = robust_test_ha(h0,HA,tot_time,'ode45');

plot(projection(ell,[1 0 0 0;0 1 0 0]'))

end

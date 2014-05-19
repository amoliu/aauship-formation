%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% parameters for fitting %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Function to fit for propellor %%%
% n,sign(n) .* K_t * rho * D.^4 .* n.^2

%%% Propellor parameters %%%
rho = 1000;
D = 45*10^-3;
n = [100 120 140 160 180 200 220 240 260 280 300];
K_t = 0.16;

%%% Data to be plotted %%%
both_step1 = [100 120 140 160 180 200 220 240 260 280];
both_force1 = [3.6 6.8 10.8 15.5 21.2 26.2 30.25 41 48 50];

both_step2 = [100 120 140 160 180 200 220 240];
both_force2 = [4.6 8 12.1 17 22.5 28.4 33.8 40];

left_step = [100 120 140 160 180 200 220 240 260 280 300];
left_force = [3.1 5.1 8 11.3 14.1 18.2 20.7 25.1 28.7 32.8 36.4];

right_step = [100 120 140 160 180 200 220 240 260 280 300];
right_force = [1.9 3.2 5.1 7.6 9.8 12.5 15.8 18.8 21 23.8 26.4];

both_back_step = [100 120 140 160 180 200 220 240 260 280 300];
both_back_force = [2.4 5.2 9 13 15.8 16 18 20.5 22 25 26];

left_back_step = [100 120 140 160 180 200 220 240 260 280 300];
left_back_force = [1.4 2.9 5 7.4 10.8 13.9 18 20.5 23 26 28];

right_back_step = [100 120 140 160 180 200 220 240 260 280 300];
right_back_force = [1.4 2.8 4.9 7.4 10.8 14 19.4 20.2 24.5 26 30];

forward=figure(1)
plot(both_step1,both_force1,both_step2,both_force2,left_step,left_force,right_step,right_force,left_step,left_force+right_force,n,sign(n) .* K_t * rho * D.^4 .* n.^2,'-*');
xlabel('Motor input')
ylabel('Force [N]')
legend('Both thrusters, 1. test','Both thrusters, 2. test','Left thruster only','Right thruster only','Left and right thruster added','Propellor regression','Location','NorthWest')

rho = 1000;
D = 45*10^-3;
n = [100 120 140 160 180 200 220 240 260 280 300];
K_t = 0.09;

backward=figure(2)
plot(both_back_step,both_back_force,left_back_step,left_back_force,right_back_step,right_back_force,left_back_step,left_back_force+right_back_force,n,sign(n) .* K_t * rho * D.^4 .* n.^2,'-*');
xlabel('Motor input')
ylabel('Force [N]')
legend('Both thrusters','Left thruster only','Right thruster only','Left and right thruster added','Propellor regression','Location','NorthWest')

saveas(forward,'forwardthrust.eps','psc2')
saveas(backward,'backthrust.eps','psc2')

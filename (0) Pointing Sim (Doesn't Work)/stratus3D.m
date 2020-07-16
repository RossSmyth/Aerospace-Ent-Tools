%3D Stratus Pointing Simulation
%Authors: Ross Smyth (crsmyth@mtu.eu)
%Date: 4/14/2018
%This should be able to give fairly accurate results

%{
Pointing Sim - Doesn't work
Copyright (C) 2020 Ross Smyth

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

addpath Objects
addpath Functions

%% -------------------Constants and Parameters-----------------------------
totalTime = 11000; %seconds

%Constructor stuff
inertia = [36231723.22, 1128616.73,  1331747.28;...
           1128616.73,  32290981.68, 5374715.85;...
           1331747.28,  5374715.85,  9506359.96]; %g*mm^2 as of 4/2/2018
inertia = inertia * (1/1000)^3; %kg*m^2

%Generates a random velocity with a magnitude of 4 degree / sec after detumble
detumbledVelocity = 1 + -2.*rand(3, 1);
detumbledMomentum = inertia * (detumbledVelocity / norm(detumbledVelocity) * 4 * pi/180);

%actual class construction
earth   = Earth;
stratus = Satellite(inertia,...
                    [0; 0; 0],... %Initial angles
                    [0; 1; 0],... %Initial unit vector
                    detumbledMomentum,...
                    [0; 0; 0],... %The point of the target
                    [-5.15; -19.32; -2.52] / 1000,... %Center of mass
                    [-.05; -.1; 0]); %Center of Pressure

%Time parameters
stratus.dt   = .01; %seconds The time Delta
stratus.time = 0:stratus.dt:totalTime; %time vector

%% --------------------Position Calculations-------------------------------

%unit vector of orbital inclination
inclinationVector = [cosd(stratus.inclination); 0; cosd(90 - stratus.inclination)];

%rotation matrix along the unit vector. This is painful to write
rotationMatrix = @(angle) [cos(angle) + inclinationVector(1)^2 * (1 - cos(angle)), -inclinationVector(3) * sin(angle), inclinationVector(1)*inclinationVector(3)*(1-cos(angle));...
                           inclinationVector(3) * sin(angle), cos(angle), -inclinationVector(1) * sin(angle);...
                           inclinationVector(1) * inclinationVector(3) * (1-cos(angle)), inclinationVector(1) * sin(angle), cos(angle) + inclinationVector(3)^2 * (1 - cos(angle))];

%initial position of stratus. Not exactly, but it needed to be at a point
%along the y axis to match the orbit
stratus.position = [0; -stratus.radius; 0];

%loops through and calculates Stratus's position every second
angle               = 0; %radians
pastPositions       = zeros(3, totalTime / stratus.dt); %pre-allocates the matrix so it isn't super slow
pastPositions(:, 1) = stratus.position; %all positions each second
pastAngles          = zeros(1, totalTime / stratus.dt);

%Precalculated positions and angles since they take a significant amount of computing
%time and don't change
load('positions.mat')
load('angles.mat')

%% --------------------------Impulse Calculations--------------------------


idealMomentum = stratus.inertia * inclinationVector * stratus.orbitalAngularVelocity;

pointingImpulse = idealMomentum - stratus.momentum;

%Negative because the wheels spin the opposite direction
load('impulses.mat')
pastImpulses(:, 1)       = -pointingImpulse;
pastWheelMomentums       = zeros(3, totalTime / stratus.dt + 1);
pastWheelMomentums(:, 1) = stratus.wheel.momentum - pointingImpulse;

%% ------------------------Saturation Calculations-------------------------
stratus.index = 1;
for i=0:stratus.dt:totalTime
    
    %Checks to see if the reaction wheel is saturated or not
    stratus.wheel.saturated(1) = abs(stratus.wheel.momentum(1)) > stratus.wheel.maxMomentum;
    stratus.wheel.saturated(2) = abs(stratus.wheel.momentum(2)) > stratus.wheel.maxMomentum;
    stratus.wheel.saturated(3) = abs(stratus.wheel.momentum(3)) > stratus.wheel.maxMomentum;
    
    %Inline conditional, looks really bad but works fine
    %This adds the impulses calculated above to the reaction wheel momentums
    %As long as the wheels are not saturated
    stratus.wheel.momentum(1) = stratus.wheel.momentum(1) - ~stratus.wheel.saturated(1) * pastImpulses(1, stratus.index);
    stratus.wheel.momentum(2) = stratus.wheel.momentum(2) - ~stratus.wheel.saturated(2) * pastImpulses(2, stratus.index);
    stratus.wheel.momentum(3) = stratus.wheel.momentum(3) - ~stratus.wheel.saturated(3) * pastImpulses(3, stratus.index);
    
    pastWheelMomentums(:, stratus.index) = stratus.wheel.momentum;
    
    stratus.index = stratus.index + 1;
end

%% ----------------------------Sautration----------------------------------
%Finds where (if they did at all) the wheels saturated
xSaturationTimeIndex = find(abs(pastWheelMomentums(1, :)) >= stratus.wheel.maxMomentum, 1, 'first');
ySaturationTimeIndex = find(abs(pastWheelMomentums(2, :)) >= stratus.wheel.maxMomentum, 1, 'first');
zSaturationTimeIndex = find(abs(pastWheelMomentums(3, :)) >= stratus.wheel.maxMomentum, 1, 'first');

%Finds the time they saturated
xSaturationTime = stratus.time(xSaturationTimeIndex);
ySaturationTime = stratus.time(ySaturationTimeIndex);
zSaturationTime = stratus.time(zSaturationTimeIndex);

%Finds the max for energy calculations later
saturationIndexes = [xSaturationTimeIndex; ySaturationTimeIndex; zSaturationTimeIndex];
saturationIndex   = max(saturationIndexes);

%% ------------------------------Plotting----------------------------------

figure('Name', 'Reaction Wheel Momentums')

totalWheelMomentum = zeros(1, length(pastWheelMomentums));
for i=1:length(pastWheelMomentums)
    totalWheelMomentum(i) = norm(pastWheelMomentums(:, i));
end

subplot(2, 2, 1)
plot(stratus.time, totalWheelMomentum)
xlabel('Time (sec.)')
ylabel('Angular Momentum (N*m*s)')
title('Total Reaction Wheel momentum')
set(gca,'fontSize',14)

subplot(2, 2, 2)
plot(stratus.time, pastWheelMomentums(1, :))
xlabel('Time (sec.)')
ylabel('Angular Momentum (N*m*s)')
title("X Reaction Wheel's Momentum")
set(gca,'fontSize',14)

subplot(2, 2, 3)
plot(stratus.time, pastWheelMomentums(2, :))
xlabel('Time (sec.)')
ylabel('Angular Momentum (N*m*s)')
title("Y Reaction Wheel's Momentum")
set(gca,'fontSize',14)

subplot(2, 2, 4)
plot(stratus.time, pastWheelMomentums(3, :))
xlabel('Time (sec.)')
ylabel('Angular Momentum (N*m*s)')
title("Z Reaction Wheel's Momentum")
set(gca,'fontSize',14)

% power
figure('Name', 'Reaction Wheel Power')

wheelVelocities = pastWheelMomentums / stratus.wheel.inertia; % Rad / sec
wheelVelocities = abs(wheelVelocities * 60 / (2 * pi)); % RPM

% Spline the can interpolate data from the three points in the mobo ICD
powerSpline       = spline([0, 2000, 5000, 7000], [0.015, 0.09, 0.17, 0.215]);
batteryBusVoltage = 8.5; % Volts from motherboard ICD

xWheelPower     = ppval(powerSpline, wheelVelocities(1, :)) * batteryBusVoltage / 3;
yWheelPower     = ppval(powerSpline, wheelVelocities(2, :)) * batteryBusVoltage / 3;
zWheelPower     = ppval(powerSpline, wheelVelocities(3, :)) * batteryBusVoltage / 3;

totalWheelPower = xWheelPower + yWheelPower + zWheelPower;
otherPowers     = 5.15 * 200 / 1000 + 12 * 19 / 1000; % Watts Other powers from the ICD
totalWheelPower = totalWheelPower + otherPowers;

subplot(2, 2, 1)
plot(stratus.time, totalWheelPower)
xlabel('Time (sec.)')
ylabel('Power (Watts)')
title('Total Reaction Wheel Power')
set(gca,'fontSize',14)

subplot(2, 2, 2)
plot(stratus.time, xWheelPower)
xlabel('Time (sec.)')
ylabel('Power (Watts)')
title("X Reaction Wheel's Power")
set(gca,'fontSize',14)

subplot(2, 2, 3)
plot(stratus.time, yWheelPower)
xlabel('Time (sec.)')
ylabel('Power (Watts)')
title("Y Reaction Wheel's Power")
set(gca,'fontSize',14)

subplot(2, 2, 4)
plot(stratus.time, zWheelPower)
xlabel('Time (sec.)')
ylabel('Power (Watts)')
title("Z Reaction Wheel's Power")
set(gca,'fontSize',14)

%% -----------------------Energy Calculations------------------------------
%Finds the total energy used until saturated

totalEnergy  = trapz(stratus.time(1:saturationIndex), totalWheelPower(1:saturationIndex));

fprintf('Total power used by reaction wheels over %g seconds (Joules):\n\n', stratus.time(saturationIndex))
disp(totalEnergy)
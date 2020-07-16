%3D Stratus Pointing Simulation
%Authors: Ross Smyth (crsmyth@mtu.eu)
%Date: 4/10/2018
%Revision 2

%This simulation takes the maximum in which Stratus is able to be
%saturated, and brings is down to zero momentum stored. The assumptions
%made are as follows:
%
%   1: Stratus is already perfectly pointing NADIR (LLA may come later)
%   2: Stratus has the momentum to keep it perfectly pointing NADIR
%   3: The desaturation algorthim can always keep the current in the coils
%      flowing in the direction needed to make the angular momentum
%      approach zero
%   4: Disturbances will not affect desaturation. This one is the most
%      needed to not be assumed because it it flat out wrong.
%{
Desaturation Sim - Doesn't work
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

clear, clc
%This should be able to give fairly accurate results
addpath Objects
addpath Functions

%% -------------------Constants and Parameters-----------------------------
totalTime = 2000; %seconds

%Constructor stuff
inertia = [36231723.22, 1128616.73,  1331747.28;...
           1128616.73,  32290981.68, 5374715.85;...
           1331747.28,  5374715.85,  9506359.96]; %g*mm^2 as of 4/2/2018
inertia = inertia * (1/1000)^3; %kg*m^2

%actual class construction
earth   = Earth;
stratus = Satellite(inertia,...
                    [0; 0; 0],... %Initial angles (Radians)
                    [0; 0; 1],... %Initial unit vector
                    [0; 0; 0],... %Initial momentum (Not important for this file)
                    [0; 0; 0],... %The point of the target (meters)
                    [-5.15; -19.32; -2.52] / 1000,... %Center of mass (meters)
                    [-.05; -.1; 0],... %Center of Pressure (meters)
                    [0.179; 0.21; 0.21]); %Magnetic moment (A*m^2) (assumption #1)

%The maximum momentum the wheels can store
saturatedMomentum = ones(3, 1) * stratus.wheel.maxMomentum;

stratus.wheel.momentum = saturatedMomentum;

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

%Loads 2 orbits (11000 seconds) of ECI orbit positions 
load('positions.mat') % Meters

%I precalculated these because calculating them using the builtin eci2lla()
%funtion take a ridiculous amount of RAM. I saw peaks of 42GB on my
%desktop. But I ran it on Collusus and saved the results.
%The starting time is January 1st 2015, 00:00:00.000 because it lines up
%with the world magnetic model, even though it doesn't have to.
%Approximatly 2 orbits (11000 seconds at .01 seconds)
load('llaPositions.mat') % [Latitude, Longitude, Altitude]


%% --------------------Impulse Calculations--------------------------------

pastWheelMomentums       = zeros(3, totalTime / stratus.dt + 1);
desaturated              = false(3, 1); %Bool
angle                    = 0; %Radians

pastTorques = zeros(3, totalTime / stratus.dt + 1);

%Rotation matrix that can rotate Stratus to keep it pointing NADIR at each
%time interval, this is assumption #1 and #2
orbitalMatrix            = rotationMatrix(-stratus.orbitalAngularVelocity * stratus.dt);

%This loads pre-computed magnetic field values in Teslas. They are fairly
%expensive computationally to compute so I precaluclated them. The domain
%is 11000 seconds at .01 second interval, or approximatly 2 orbits.
load('magneticField.mat') %Teslas

for i=1:totalTime/stratus.dt
    pastWheelMomentums(:, i) = stratus.wheel.momentum;
    
    %Computes the angle of the orbit that Stratus is at
    angle                  = angle + stratus.orbitalAngularVelocity * stratus.dt; %Radians
    
    %Rotates the magnetic moment around to the next time interval pointing
    %NADIR. Assumption #2
    stratus.magneticMoment = orbitalMatrix * stratus.magneticMoment; %A*m^2
    
    %Calculates the torque that the torque coils produce to desaturate
    desaturationTorque  = cross(stratus.magneticMoment, magneticField(:, i)); %N*m
    
    %Rotates the torque back to the inertial frame of the reaction wheels
    %since they don't rotate at all, because if you do that would break
    %desaturation since they are discrete actuators
    desaturationTorque  = rotationMatrix(angle) \ desaturationTorque; %N*m
    
    %Finds the impulse the coils produce
    desaturationImpulse = desaturationTorque * stratus.dt; %N*m*s
    
    %If any of the wheels are already desaturated then it doesn't desaturate them anymore
    desaturationImpulse = desaturationImpulse .* ~desaturated;
    
    %This is assumption #3, it assumes that the torque coils will only ever
    %desaturate, and will never accidentally add momentum to the wheels
    desaturationImpulse = abs(desaturationImpulse);
    
    %Desaturates the reaction wheels
    stratus.wheel.momentum = stratus.wheel.momentum - desaturationImpulse;
    
    desaturated = stratus.wheel.momentum <= 0; %Checks if desaturated
    
    pastTorques(:, i) = desaturationTorque;
    
end


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

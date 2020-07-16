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

clc, clear, close all

load('saturationTimes.mat')

for indexer=1:80
    run('stratus3D')

    xTimes(end + 1) = xSaturationTime;
    zTimes(end + 1) = zSaturationTime;
    
    if isempty(ySaturationTime)
        yTimes(end + 1) = NaN;
    else
        yTimes(end + 1) = ySaturationTime;
    end
    
    power(end + 1)        = max(totalWheelPower);
    totalEnergyStats(end + 1) = totalEnergy;
    
    clearvars -except xTimes yTimes zTimes indexer power totalEnergyStats
end

save('saturationTimes.mat', 'xTimes', 'yTimes', 'zTimes', 'power', 'totalEnergyStats')

%%
figure('Name', 'Saturation Box Plots')

saturationTimes = [xTimes; yTimes; zTimes]';

boxplot(saturationTimes, {'X Wheel', 'yTimes', 'Z Wheel'})
title('Saturation Times (seconds)')
xlabel('Reaction Wheel')
ylabel('Saturation Time')


figure('Name', 'Saturation Histograms')

subplot(3, 1, 1)

hist(xTimes)
title('X Wheel')
xlabel('Saturation Time (seconds)')
ylabel('Number of Apperances')

subplot(3, 1, 2)

hist(yTimes)
title('Y Wheel')
xlabel('Saturation Time (seconds)')
ylabel('Number of Apperances')

subplot(3, 1, 3)

hist(zTimes)
title('z Wheel')
xlabel('Saturation Time (seconds)')
ylabel('Number of Apperances')


figure('Name', 'Power and Energy')

subplot(1, 2, 1)

boxplot(power)
title('Power')
ylabel('Power (Watts)')

subplot(1, 2, 2)

boxplot(totalEnergyStats)
title('Energy')
ylabel('Energy (Joules)')
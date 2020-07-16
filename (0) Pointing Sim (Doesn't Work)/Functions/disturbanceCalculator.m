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

function newImpulses = disturbanceCalculator(impulses, positions, angles, satellite)
%   disturbanceCalculator - Calculates the disturbance impulses for Stratus
%
%   This is made for being a batch worker. It is multicore so it should
%   speed up the calculations compared to before. But it will only speed
%   them up if above a certain amount of time. The overhead for parallel
%   computations slows it down a lot as well.
%
%   Inputs:
%       1 - impulses = An impulse vector to add disturbances to
%       2 - positions = Vector of positions of the satellite along its orbit
%       3 - angles    = Vector of angles that the satellite has rotated
%       4 - satellite = Satellite object
%                       See Also Satellite

    parfor i = 2:satellite.time(end)/satellite.dt
        index = i
        impulses(:, i) = updateRotationParameters(satellite, positions, angles, index)
    end
    newImpulses = impulses;
end
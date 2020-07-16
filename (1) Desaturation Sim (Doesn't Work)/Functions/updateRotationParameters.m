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

function disturbanceImpulse = updateRotationParameters(satellite, positions, angles, index)
%updateRotationParameters - Updates the rotational parameters of the satellite
%
%   It may look like this is satellite neutral, but there are small
%   parameters that must be adjusted in order to make it work for other
%   satellites.
%
%   Inputs:
%       1 - satellite = The satellite class to update
%       2 - positions = Vector holding position values
%       3 - angles    = Vector holding angles the satellite has rotated
%       4 - index     = The current index that is being looked at
%
%   Outputs:
%       dsiturbanceImpulse = The disturbance impulse for that moment in time

    %%
    
    orbitalAngle = angles(index);
    rotationMatrix = rotation([0, 0, orbitalAngle]);
    
    %unitVelocity for the aero torque
    if index ~= 1
        %errors if 1 
        unitVelocity = positions(:, index) - positions(:, index - 1);
        unitVelocity = unitVelocity / norm(unitVelocity);
    else
        %Just makes it zero because it is only for one data point
        unitVelocity = [0; 0; 0];
    end
    
    %disturbanceTorques = aeroTorque(satellite, unitVelocity, rotationMatrix) + gravityTorque(satellite, rotationMatrix) + solarTorque(satellite, rotationMatrix);
    disturbanceImpulse = disturbanceTorques * satellite.dt;
    %}
    %%
    function rotationMatrix = rotation(angles)
        %rotation: Finds a 3D rotation matrix when given Euler angles in radians
        %
        %   Inputs:
        %       angles = Euler angles vector (radians)
        %
        %   Outputs:
        %       rotationMatrix = 3D rotation matrix for those angles
        
        rotationXAxis = [1, 0, 0; 0, cos(angles(1)), -sin(angles(1)); 0, sin(angles(1)), cos(angles(1))];
        rotationYAxis = [cos(angles(2)), 0, sin(angles(2)); 0, 1, 0; -sin(angles(2)), 0, cos(angles(2))];
        rotationZAxis = [cos(angles(3)), -sin(angles(3)), 0; sin(angles(3)), cos(angles(3)), 0; 0, 0, 1];
        
        rotationMatrix = rotationZAxis * rotationYAxis * rotationXAxis;
    end

    %%
    function torque = aeroTorque(satellite, unitVelocity, rotationMatrix)
        %aeroTorque: Calculates the aerodynamic torque according to SMAD
        %
        %   Inputs:
        %       1 - satellite       = Satellite class
        %                             See also Satellite
        %       2 - unitVelocity    = Unit vector in the direction of the velocity
        %       
        %   Outputs:
        %       torque = Aerodynamic torque on the satellite (n*m)
        
        %Finds to atmospheric density
        temperature   = -131.21 + 0.0029 * satellite.altitude + 273.1; % Kelvin
        atmosPressure = 2.488 * (temperature / 216.6)^-11.388;%kpa
        atmosDensity  = atmosPressure / (.2869 * temperature);%kg/m^3
        
        %Vector from center of mass to center of pressure
        massToPressure = satellite.centerPressure - satellite.centerMass;
        massToPressure = rotationMatrix * massToPressure;
        torque = 1/2 * atmosDensity * satellite.linearSpeed^2 * 2.25 * satellite.maxArea * cross(unitVelocity, massToPressure);
    end

    %%
    function torque = gravityTorque(satellite, rotationMatrix)
        %gravityTorque: Calculates the gravity gradient torque according to
        %               SMAD
        %
        %   Inputs:
        %       Satellite = Satellite class
        %                   See also Satellite
        %
        %   Outputs:
        %       torque = Gravity gradient torque (n*m)
        
        earth = Earth;
        
        nadirUnitVector = [0; 0; 0] - satellite.position;
        nadirUnitVector = nadirUnitVector / norm(nadirUnitVector);
        
        inertia = rotationMatrix * satellite.inertia * rotationMatrix';
        
        torque = 3*earth.parameter / satellite.radius^3 * cross(nadirUnitVector, inertia * nadirUnitVector);
    end

    %%
    function torque = solarTorque(satellite, rotationMatrix)
        %solarTorque: Calculates the solar pressure torque according to
        %             SMAD
        %   
        %   This assumes the area of maximum area of Stratus is always 
        %   facing directly at the sun, because it turns out making this 
        %   any better becomes complicated fast and I am already 80% into
        %   OOP hell
        %
        %   Inputs:
        %       satellite = Satellite class
        %                   See also Satellite
        %
        %   Outputs:
        %       torque = Solar pressure torque (n*m)
        
        SolConstant = 4.644e-6; %n/m^2 solar pressure constant 
        sunVector   = [-1; 0; 0]; %unit vector pointing to the sun
        
        %assumes the max area is always facing the sun
        massToArea = [-.05; 0; 0] - satellite.centerMass;
        
        massToArea = rotationMatrix * massToArea;
        
        torque = SolConstant * satellite.maxArea * cross(sunVector + [-2; 0; 0], massToArea);
        
        
    end
end


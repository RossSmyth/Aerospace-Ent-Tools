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

function satellite = desaturate(satellite, magneticField)
%desaturate(satellite, magneticField) Updates and tries to desaturate the
%                                     satellite
%
%   Inputs:
%       1 - satellite     = Initial Satellite class
%                           See also Satellite
%       2 - magneticField = Magnetic field vector affecting satellite (Teslas)
%
%   Outputs:
%       1 - satellite = Updated Satellite class
%                       See also Satellite

    



    function rotationMatrix = rotation(angles)
        %rotation: Finds a 3D rotation matrix when given Euler angles in radians
        %
        %   Inputs:
        %       angles = Angles vector (radians)
        %
        %   Outputs:
        %       rotationMatrix = 3D rotation matrix for those angles
        
        rotationXAxis = [1, 0, 0; 0, cos(angles(1)), -sin(angles(1)); 0, sin(angles(1)), cos(angles(1))];
        rotationYAxis = [cos(angles(2)), 0, sin(angles(2)); 0, 1, 0; -sin(angles(2)), 0, cos(angles(2))];
        rotationZAxis = [cos(angles(3)), -sin(angles(3)), 0; sin(angles(3)), cos(angles(3)), 0; 0, 0, 1];
        
        rotationMatrix = rotationZAxis * rotationYAxis * rotationXAxis;
    end
end


# Pointing_Budget
What I think a pointing budget should look something like. This works well enough as a starting point but is in no way a final or official design.
# Dependencies
* https://www.mathworks.com/matlabcentral/fileexchange/70030-aerospace-blockset-cubesat-simulation-library
# About
This extends the Mathworks CubeSat blockset to something that is actually worth using. It simulates reaction wheels, target satellites, disturbance torques (equations from Space Mission Analysis and Design) and sensor noise.

Sensor noise is one part that I am fairly confident in and proud of, and it calculates each sensor's accuracy standard deviation as well as the total spacecraft attitude determination accuracy along each body axis. All of the math for it is done in the `Pointing_Budget.m` file..

The simulation itself is just generic and __not__ representative of any control system. There are two problems with it:
1. It doesn't mean anything if you are using some other control system
2. It breaks the quaternions into Euler angles.

The first one is because many companies distrubte their controls as just a black box, so you cannot know anything about them.

The second one is because I did not know how to keep it as quaternions throughout. 

# Deprecation
As of the time I am writing this (July 2020) we have deprecated the use of this in the Aerospace Enterprise. This is because we have a Simulation from our supplier that is representative, and the sensor accuracy part can be done in a standalone Excel file. That Excel fiel is included in this repository.
% 08 September 2016
% creates an array of radial lines as an input to
% driverForVMoptimization1line
% Calls XY2radial, which takes the flow.mat data and for a given image set
% and a given number of quadrants extracts the radial lines into a matrix
% called rayOut1_f and rayOut1_b.
% To verify that it is working correctly it converts the matrix of rays
% back to an XY grid using radial2XY().
% Requires mirrorHorz, mirrorVert, XY2radial, and radial2XY.

load('flow_rect20.mat');

imageSet = 1;
numQuads = 4;

rayOut1_f = XY2radial(uv_fm{imageSet},numQuads);
imgOut_f = radial2XY(rayOut1_f,numQuads);

rayOut1_b = XY2radial(uv_b{imageSet},numQuads);
imgOut_b = radial2XY(rayOut1_b,numQuads);
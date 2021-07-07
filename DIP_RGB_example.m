% DIP-RGB :: example
% Drone Image Processing: RGB Composition (DIP_RGB)
% Multiband Images :: Create RGB Compositions from multiband images
% ------------------------------------------------------ %
% Gabriela Rabelo Andrade 
% gabrielarabelo@gmail.com
% ------------------------------------------------------ %

% start fresh (optional)
% clear; close all; clc;

% set parameters:
parameters = struct;
parameters.nband             = 6;
%-% set other parameters (optional)
parameters.camera            = 'altum';
parameters.customRGB         = [4 5 2];
parameters.customMode        = true;


% Call DIP_RGB
% once you have the bands aligned (using DIP_align)
% simply call DIP_RGB to get more RGB compositions
DIP_RGB(parameters);














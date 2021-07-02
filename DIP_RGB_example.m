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
%-% set parameters for alignment (optional):
parameters.InitialRadius     = 0.00015;
parameters.Epsilon           = 1.5 * 10^-6;
parameters.GrowthFactor      = 1.002;
parameters.MaximumIterations = 300;
parameters.imregister_method = 'rigid'; 
parameters.ref_band_align    = 2;


% Call DIP_align to Align Bands
% note: it also allows you to get RGB compositions
% M = DIP_align(parameters);

%
% Call DIP_RGB
% once you have the bands aligned (using DIP_align)
% simply call DIP_RGB to get more RGB compositions
DIP_RGB(parameters);














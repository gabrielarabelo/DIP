% DIP-align :: example
% Drone Image Processing: Align (DIP_align)
% Multiband Images :: Align and create RGB Compositions
% Works with: Altum & RedEdge
% ------------------------------------------------------ %
% Gabriela Rabelo Andrade 
% gabrielarabelo@gmail.com
% ------------------------------------------------------ %
% start fresh
clear; close all; clc;

% set parameters (optional):
parameters = struct;
parameters.camera            = 'altum';
parameters.nband             = 6;
parameters.customRGB         = [4 5 2 ; 5 4 3; 5 2 1; 4 2 1; 5 4 1];
parameters.customMode        = true;
% default parameters:
parameters.InitialRadius     = 0.00015;
parameters.Epsilon           = 1.5 * 10^-6;
parameters.GrowthFactor      = 1.002;
parameters.MaximumIterations = 300;
parameters.imregister_method = 'rigid'; 
%
parameters.ref_band_align    = 2;



% RUN
DIP_align(parameters);















% Drone Image Processing: Align (DIP_align)
% Align and create RGB Compositions from Multispectral Images
% Tested with: Micasense Altum & RedEdge
% ------------------------------------------------------ %
% Gabriela Rabelo Andrade | gabrielarabelo@gmail.com
% Camila Costa de Amorim
% ------------------------------------------------------ %

% start fresh (optional)
clear; close all; clc;

% optional parameters:
parameters = struct;
parameters.nband             = 6;
parameters.camera            = 'altum';
parameters.customRGB         = [4 5 2];
parameters.customMode        = true;
% %-% alignment parameters (optional):
% parameters.InitialRadius     = 0.00015;
% parameters.Epsilon           = 1.5 * 10^-6;
% parameters.GrowthFactor      = 1.002;
% parameters.MaximumIterations = 300;
% parameters.imregister_method = 'rigid'; 
% parameters.ref_band_align    = 2;
% parameters.scale             = 1;
% parameters.haze_adj          = 0.7;
% parameters.haze_adj_method   = 'approxdcp';
% parameters.gamma_adj         = 0.6;
% parameters.skip_bands        = [];

% ------------------------------------------------------ %
% RUN
DIP_align(parameters);
% ------------------------------------------------------ %





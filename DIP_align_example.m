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
P = struct;
P.camera            = 'altum';
P.customRGB         = [4 5 2 ; 4 5 3];
P.customMode        = true;
% default parameters:
P.InitialRadius     = 0.00015;
P.Epsilon           = 1.5 * 10^-6;
P.GrowthFactor      = 1.002;
P.MaximumIterations = 300;
P.imregister_method = 'rigid'; 
%
P.ref_band_align    = 2;



% RUN
DIP_align(P);















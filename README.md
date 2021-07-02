# DIP
Drone Image Processing Toolbox (DIP-Toolbox)

DIP_align & DIP_RGB Tools

This Toolbox can be cited as:
doi:********************

Author:
Gabriela Rabelo Andrade | gabrielarabelo@gmail.com

Contributor:
Camila Costa de Amorim


## Introduction
DIP is a Matlab Toolbox for image processing of Drones.

This document presents the manual of the following tools:
• DIP_align - Tool for band alignment and generation of RGB compositions;
• DIP_RGB - Tool for generating RGB compositions once the bands have been aligned. Note:features DIP_RGB are already included in DIP_align.

These tools were tested on images from the Micasense Altum and Micasense RedEgde cameras. However, the code was designed to work on other models, as long as the files for each band are saved separately, and named according to the standard "<image_prefix>_<band_number>.tif" (example: "IMG_043_1. tif" for Band 1, and "IMG_043_2.tif" for Band 2, and so on).

The DIP_align tool executes the following actions:
• Import all bands;
• intensity-based image registration for all the bands;
• cropping of the areas on the edges of the images where not all bands overlap;
• file saving of aligned bands;
• generation of RGB compositions from selected bands using the encapsulated tool DIP_RGB;
• enhancement of the RGB composition with the use of histogram correction, haze elimination and gamma correction tools;
• saving RGB composition files;

The technique used for image alignment is the Intensity-based image registration (imregister), native to Matlab (introduced in R2012a).
The image enhancement of the RGB compositions is performed using the native tools imreducehaze, imadjust, and stretchlim.

## User Manual
### Function Calling
The DIP_align tool can be used by calling the function DIP_align(). The function has 1 optional input (parameter), which is a struct-type variable and can contain information about the camera, image bands, and optimization parameters for registration alignment and image enhancement.
The DIP_align tool can be used by calling the DIP_align function. This function has 1 optional input (parameters), which is a variable of type struct containing information about the camera, number of image bands, optimization parameters for image registration, and for image enhancement.
DIP_align
DIP_align(parameters)

Note: the program folder contains an example file (DIP_align_example.m) and sample Altum image files (folder: sample).
Input Parameters
The following parameters are accepted in the current version:

• nband
number (double)
Number of bands captured by the camera

• camera
string
Camera model

• band_specs
cell array
Cell array containing the specification of each band of the camera ( automatically generated for Altum and RedEdge)

• RGB_bands
3-column vector or matrix
Band sequence for traditional RGB composition.
Default is 321.

• customRGB
3-column or matrix
Band sequence for RGB prompt compositions that will be generated without user

• customMode
logical
Opens a dialog box so the user can enter custom RGB compositions

• InitialRadius
number (double)
Optimization parameter for image registration (see imregister documentation)

• Epsilon       
number (double)
Optimization parameter for image registration (see imregister documentation)

• GrowthFactor 
number (double)
Optimization parameter for image registration (see imregister documentation)

• MaximumIterations
number (double)
Optimization parameter for image registration (see imregister documentation)

• imregister_method
string
Optimization parameter for image registration (see imregister documentation)

• ref_band_align
number (double)
Band to be taken as reference for the image registration

• scale
number (double)
Factor to scale images (useful for images that are too big or for using orthomosaics)

• haze_adj
number ( double)
Number between 0 and 1 as input for imreducehaze

• haze_adj_method
string
Method for imreducehaze

• gamma_adj
number (double)
Number between 0 and 1 as input for gamma correction using imadjust

• skip_bands
vector (double)
Bands to be ignored during the image alignment (to be used with bands which the size is too different from the other bands)


The input parameters should be declared the variable fields of the struct of type, as follows:

parameters.nband
parameters.camera
parameters.band_specs
parameters.RGB_bands
parameters.customRGB
parameters.customMode
parameters.InitialRadius
parameters.Epsilon
parameters.GrowthFactor
parameters.MaximumIterations
parameters.imregister_method
parameters.ref_band_align
parameters.scale
parameters.haze_adj
parameters.haze_adj_method
parameters.gamma_adj
parameters.skip_bands


### Running the Program
After calling the function DIP_align, the program will start to run.
The user will first be prompted to select one band of the multispectral image to be aligned. Selecting only one band is enough and the program will automatically identify and import the other band files.
The user will then be prompted to select a folder to save the output files.
The user will then be prompted to enter a custom name prefix for the output images that will be exported.
After that, the program will perform the image registration alignment and the program will plot the following:
• RGB image before the image registration;
• Before and After of the bands of the image being aligned;
• RGB image after the image registration;

The program will then plot and save high-resolution images of the RGB Compositions in the following sequence: Regular RGB; Haze & Gamma Adjusted RGB; Stretch Limits Adjusted RGB.
After that, in case the user selected the Custom Mode, the user will be prompted to enter any band combinations to generate other custom RGB compositions.
Finally, all the high-resolution images will be saved in the output folder.

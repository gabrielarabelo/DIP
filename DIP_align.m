function DIP_align(parameters)

% Drone Image Processing: Align (DIP_align) & RGB (DIP-RGB)
% Multiband Images :: Align and create RGB Compositions
% Tested with: Altum & RedEdge
% ------------------------------------------------------ %
% Author:
% Gabriela Rabelo Andrade 
% gabrielarabelo@gmail.com
% ------------------------------------------------------ %
% SIMOA | DESA/UFMG + Instituto Teia
% R&D/P&D ANEEL/Cemig GT-607
% ------------------------------------------------------ %

% % set parameters (example):
% parameters = struct;
% parameters.nband             = 6;
% %-% set other parameters (optional)
% parameters.camera            = 'altum';
% parameters.customRGB         = [4 5 2 ; 5 4 3];
% parameters.customMode        = true;
% %-% set parameters for alignment (optional):
% parameters.InitialRadius     = 0.00015;
% parameters.Epsilon           = 1.5 * 10^-6;
% parameters.GrowthFactor      = 1.002;
% parameters.MaximumIterations = 300;
% parameters.imregister_method = 'rigid'; 
% parameters.ref_band_align    = 2;


close all; clc
disp('DIP-align :: ')
disp('ready to start!')

if (nargin==1); P = parameters;
    try nband = P.nband;
    catch; nband = []; disp('[nband] not set');
    end
else; P = struct;
    nband = [];
end


% ------------------------------------------------------ %
% Start GUI
% ------------------------------------------------------ %
% select file
msg = 'Select File (only one band required)';
clc; disp(msg);
[file,path] = uigetfile('*.*', msg);
% Find Image Type
ftype = extractAfter(file,'.');
% select export folder
msg = 'Select Export Folder';
clc; disp(msg);
usavepath = uigetdir(path,msg);
usavepath_proc = [usavepath '/' 'process'] ;
mkdir(usavepath_proc)
% usavepath_lowr = [usavepath '/' 'low-res'] ;
% mkdir(usavepath_lowr)
% custom export file name
msg = 'Create a Custom Prefix for the File Name';
clc; disp(msg);
prompt = ['Custom File Name Prefix: [' path file ']'];
answer = inputdlg(prompt,'s');
if isempty(answer{1}); answer{1} = 'IMG'; end


% ------------------------------------------------------ %
% Import Images
% ------------------------------------------------------ %
% FIND MULTIBAND FILE PREFIX:
file_path = path;

try file_name = extractBefore(file,['_1.' ftype]);catch
    
    for i = 1:50
        try file_name = extractBefore(file,['_' num2str(i) '.' ftype]);
        catch; disp('other bands could not be found.')
        end
    end
    
end
adj_filename = erase(file_name,'_');

% IMPORT BAND IMAGES
disp('importing images...');
B = cell(2,1);
search_bands = true;
if isempty(nband)
   nband = 0;
    try
        while search_bands
            nband = nband+1; disp(['nband = ' num2str(nband)])
            i = nband;
            try B{i} = imread([file_path  [file_name '_' num2str(i) '.' ftype] ]);
            catch
                nband = nband-1;
                search_bands = false;
            end
        end
    catch
    end
else
    B = cell(nband,1);
    for i = 1:nband
        B{i} = imread([file_path  [file_name '_' num2str(i) '.' ftype] ]);
    end
end

try scale = P.scale;
catch; scale = 1; disp('[scale] set to default')
end

try haze_adj = P.haze_adj;
catch; haze_adj = 0.7; disp('[haze_adj] set to default')
end

try haze_adj_method = P.haze_adj_method;
catch; haze_adj_method = 'approxdcp';
end

try gamma_adj = P.gamma_adj;
catch; gamma_adj = 0.6;
end

try ndvi_calc = P.ndvi;
    ndvi_colormap = make_ndvi_colormap();
    try ndvi_bands = P.ndvi_bands;
    catch; ndvi_bands = [4 3];
    end
    ndvi_colormap = make_ndvi_colormap();
catch; ndvi_calc = false;
    ndvi_bands = [4 3];
end

try InitialRadius = P.InitialRadius;
catch; InitialRadius = 0.0002; disp('[InitialRadius] set to default')
end

try Epsilon = P.Epsilon;
catch; Epsilon = 1.5 * 10^-6; disp('[Epsilon] set to default')
end

try GrowthFactor = P.GrowthFactor;
catch; GrowthFactor = 1.002; disp('[GrowthFactor] set to default')
end

try MaximumIterations = P.MaximumIterations;
catch; MaximumIterations = 500; disp('[MaximumIterations] set to default')
end

try TransformType = P.TransformType;
catch; TransformType = 'rigid';  disp('[imregister_method] set to default')
end

try ref_band_align = P.ref_band_align;
catch; ref_band_align = 2; disp('[ref_band_align] set to default')
end

try customRGB = P.customRGB;
catch; customRGB = [];
end

try customMode = P.customMode;
catch; customMode = true;
end

try RGB_bands = P.RGB_bands;
catch; RGB_bands = [3 2 1];
end

try skip_bands = P.skip_bands;
catch; skip_bands = [];
end

try camera = P.camera;
    if     strcmp(P.camera,'Altum');    camera = 'altum';
    elseif strcmp(P.camera,'altum');    camera = 'altum';
    elseif strcmp(P.camera,'RedEdge');  camera = 'rededge';
    elseif strcmp(P.camera,'rededge');  camera = 'rededge';
    elseif strcmp(P.camera,'Red Edge'); camera = 'rededge';
    elseif strcmp(P.camera,'red edge'); camera = 'rededge';
    end
catch
    camera = ' ';
end

try band_specs = P.band_specs;
catch
    if strcmp(camera,'altum')
        band_specs  = {'Blue (475nm 32nm)'; ...
            'Green (560nm 27nm)';...
            'Red (668nm 14nm)';...
            'Near-IR (842nm 57nm)';...
            'Red Edge (717nm 12nm)';...
            'LWIR Thermal IR (8-14um)' ...
            };
        % skip band 6 on altum
        if isempty(skip_bands)
            skip_bands = 6;
        elseif ~ismember(6, skip_bands) 
            try skip_bands = [skip_bands 6]; catch; skip_bands = [skip_bands ; 6]; end
        end
        
    elseif strcmp(camera,'rededge')
        band_specs  = {'Blue (475nm 32nm)'; ...
            'Green (560nm 27nm)';...
            'Red (668nm 14nm)';...
            'Near-IR (842nm 57nm)';...
            'Red Edge (717nm 12nm)';...
            };
    else
        band_specs = cell(nband,1);
        for i = 1:nband; band_specs{i} = []; end
    end
 
end


% % Optimizer Presets
% opt_preset = cell(2,1);
% % Preset 1
% opt_preset{1}.InitialRadius     = 0.0002;
% opt_preset{1}.Epsilon           = 1.5 * 10^-6;
% opt_preset{1}.GrowthFactor      = 1.002;
% opt_preset{1}.MaximumIterations = 300;
% opt_preset{1}.imregister_method = 'rigid'; 
% 
% % Preset 2
% opt_preset{2}.InitialRadius     = 0.0001;
% opt_preset{2}.Epsilon           = 1.5 * 10^-6;
% opt_preset{2}.GrowthFactor      = 1.002;
% opt_preset{2}.MaximumIterations = 300;
% opt_preset{2}.imregister_method = 'rigid'; 



% INIT SOME STUFF
% Generate random id to label files (just to avoid replacing images)
id_rand = round(now*1000);
% Setup Image Align Optimizer
[optimizer, metric]     = imregconfig('multimodal');
optimizer.InitialRadius = InitialRadius;
optimizer.Epsilon       = Epsilon;
optimizer.GrowthFactor  = GrowthFactor;
optimizer.MaximumIterations = MaximumIterations;


% Resize some bands if they are smaller than the others
img_sz = size(B{1});
for i = 1:nband
    if size(B{i}) ~= img_sz
        B{i} = imresize(B{i},'OutputSize',[img_sz(1) img_sz(2)]);
    end
end
disp('done.');


ALLBAND = zeros(img_sz(1),img_sz(2),nband);
for i = 1:nband
    ALLBAND(:,:,i) = B{i};
end

% get file info (date and hour the picture was taken)
fileInfo = dir([file_path  [file_name '_1' '.' ftype] ]);
[fY, fM, fD, fH, fMN, fS] = datevec(fileInfo.datenum);
% create file name and title prefix
name_prefix  = [answer{1,1} '-' num2str(fY) '-' num2str(fM) '-' num2str(fD) ...
           ' - ' adj_filename];



% Apply Scale Factor
disp('resizing image...')
A0 = imresize(ALLBAND,scale);
disp('done.');

A = uint16(A0);

% Read Image Mode Info
try (sum(class(A)=='uint8')); img_bit = 8;
catch; try (sum(class(A)== 'uint16')); img_bit = 16; catch; end
end


figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);

for i = 1:min(6,nband)
    subplot(2,3,i)
    imshow(B{i}); title(['B' num2str(i) ' - ' band_specs{i}])
end

% Save figure
foldername = usavepath_proc;
filename = [name_prefix '_' num2str(id_rand) '_bands'];
saveas(gcf,[foldername '/' filename '.png'])
pause(2)

% Plot RGB - before alignment (for comparison)
RGB = A(:,:,1:3);
RGB(:,:,1) = A(:,:,RGB_bands(1));
RGB(:,:,2) = A(:,:,RGB_bands(2));
RGB(:,:,3) = A(:,:,RGB_bands(3));
RGB_before = RGB;

figure; imshow(RGB);
title([name_prefix ' (before alignment)' ])
pause(2)

% save figure
foldername = usavepath_proc;
filename = [name_prefix '_' num2str(id_rand) '_RGB-321_before_align'];
saveas(gcf,[foldername '/' filename '.png'])

% FIX REGISTRY
A1 = A;
fixed = A(:,:,ref_band_align);

for i = 1:nband 
    if ref_band_align ~= i && ~ismember(i, skip_bands)
        disp([num2str(ref_band_align) ' & ' num2str(i)]); % display progress
        moving = A(:,:,i);

        % plot full screen
        figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
        imshowpair(fixed,moving);
        title(['Default registration [' num2str(ref_band_align) ' & ' num2str(i) ']' ]);
        pause(1)

        % plot comparison
        figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
        subplot(121); imshowpair(fixed,moving);
        title(['Default registration [' num2str(ref_band_align) ' & ' num2str(i) ']' ]);
        hold on
        pause(0.2)
        
        subplot(122);
        text(0.5,0.5,{'calculating...';'please wait.'}); axis off
        pause(0.2)
        
        % adjust registry
        movingRegistered = imregister(moving, fixed, TransformType, optimizer, metric);
        A1(:,:,i) = movingRegistered;

        subplot(122); imshowpair(fixed, movingRegistered,'Scaling','joint');
        title(['Adjusted registration [' num2str(ref_band_align) ' & ' num2str(i) ']' ]);
        pause(2)

        % plot result full screen
        figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
        imshowpair(fixed, movingRegistered,'Scaling','joint');
        title(['Adjusted registration [' num2str(ref_band_align) ' & ' num2str(i) ']' ]);
        hold on
        pause(2)
    end
end
disp('done.');


% Crop Edges
mcrop.top    = 1;
mcrop.bottom = size(A1,1);
mcrop.left   = 1;
mcrop.right  = size(A1,2);

min_val     = 0.2;
safe_margin = 10;
rth_val = round(size(A1,1)*min_val);
cth_val = round(size(A1,2)*min_val);

for i = 1:5
    mb1  = A1(:,:,i);  mb1 = mb1>0;  
    srow = sum(mb1.'); srow1 = srow>=rth_val;
    scol = sum(mb1);   scol1 = scol>=cth_val;
    
    r1 = find(srow1,1,'first');
    re = find(srow1,1,'last');
    c1 = find(scol1,1,'first');
    ce = find(scol1,1,'last');
    
    if r1>mcrop.top;    mcrop.top    = r1; end
    if re<mcrop.bottom; mcrop.bottom = re; end
    if c1>mcrop.left;   mcrop.left   = c1; end
    if ce<mcrop.right;  mcrop.right  = ce; end
end

mcrop.top    = mcrop.top    + safe_margin;
mcrop.bottom = mcrop.bottom - safe_margin;
mcrop.left   = mcrop.left   + safe_margin;
mcrop.right  = mcrop.right  - safe_margin;

% Crop Matrix
A2  = A1(mcrop.top:mcrop.bottom,mcrop.left:mcrop.right,:);

% Assign OUTPUT
multiband = A2; M = multiband;
foldername = usavepath_proc;
filename = [name_prefix '_' num2str(id_rand) '_multiband'];
save([foldername '/' filename '.mat'], 'multiband','-v7.3') % Save Multiband
% Export Band Files
for i = 1:nband
    band = A2(:,:,i);
    filename   = [name_prefix '_' num2str(id_rand) '_' num2str(i)];
    imwrite(band,[foldername '/' filename '.tif'])
end

% Plot RGB - after alignment (for comparison)
RGB = A2(:,:,1:3);
RGB(:,:,1) = A2(:,:,RGB_bands(1));
RGB(:,:,2) = A2(:,:,RGB_bands(2));
RGB(:,:,3) = A2(:,:,RGB_bands(3));

% plot
combo_seq = erase(num2str(RGB_bands),' ');
figure; imshow(RGB); pause(2)
title([name_prefix ' (original)' ])
% save figure
foldername = usavepath;
filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq '_original'];
imwrite(RGB,[foldername '/' filename '.tif'])
% saveas(gcf,[foldername '/' filename '.png'])

% plot comparison
close all; 
figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
subplot(121); imshow(RGB_before); title('Before')
subplot(122); imshow(RGB); title('After')
pause(2)

%-% Haze & Gamma Adjust
J = RGB;
J = imreducehaze(J,haze_adj,'method',haze_adj_method);
J = imadjust(J,[],[],gamma_adj);
% plot
figure; imshow(J);
title([name_prefix ' RGB (Haze & Gamma adj.)' ])
% save figure
foldername = usavepath;
filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq];
imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
% saveas(gcf,[foldername '/' filename '.png'])

%-% Stretch Limits Adjustment
J = RGB;
J = imadjust(J,stretchlim(J));
% plot
figure; imshow(J);
title([name_prefix ' ' combo_seq ' (Auto adj.)' ])
% save figure
foldername = usavepath;
filename = [name_prefix '_' num2str(id_rand) '_AutoAdj_RGB-' combo_seq];
imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
% saveas(gcf,[foldername '/' filename '.png'])

% ------------------------------%
% Custom RGB combinations
% ------------------------------%
if ~isempty(customRGB)
    for i = 1:size(customRGB,1)
        %
        band_combo = customRGB(i,:);
        combo_seq = num2str(band_combo); combo_seq = erase(combo_seq,' ');
        %
        RGB_custom = A2(:,:,1:3);
        RGB_custom(:,:,1) = A2(:,:,band_combo(1));
        RGB_custom(:,:,2) = A2(:,:,band_combo(2));
        RGB_custom(:,:,3) = A2(:,:,band_combo(3));
        % plot
        figure; imshow(RGB_custom); pause(2)
        title([name_prefix ' ' combo_seq ' (original)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq '_original'];
        imwrite(RGB_custom,[foldername '/' filename '.tif']) % Save High Resolution Tif
        %    saveas(gcf,[foldername '/' filename '.png'])
        %-% Stretch Limits Adjustment
        J = RGB_custom;
        J = imadjust(J,stretchlim(J));
        % plot
        figure; imshow(J); pause(2)
        title([name_prefix ' ' combo_seq ' (Auto adj.)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq];
        imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
        %     saveas(gcf,[foldername '/' filename '.png'])
        %     %-% Haze & Gamma Adjust
        %     J = RGB_custom;
        %     J = imreducehaze(J,haze_adj,'method',haze_adj_method);
        %     J = imadjust(J,[],[],gamma_adj);
        
        close all;
    end
end

disp('done.');
disp(['check your files on: ' usavepath])


if  ndvi_calc
    nir = double(multiband(:,:,ndvi_bands(1)))/2^img_bit;
    red = double(multiband(:,:,ndvi_bands(2)))/2^img_bit;
    ndvi = (nir-red) ./ (nir+red);
    
    % plot with pseudo-color
    caxislim = [-1 1];
    ndvi = ndvi.'; ndvi  = imrotate(ndvi,90); % rotate to plot like imshow
    figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
    J = pcolor(ndvi);
    % tightfig;
    axis equal
    shading interp
    colormap(ndvi_colormap)
    colorbar
    caxis([caxislim(1) caxislim(2)])
    pause(2)
    title([name_prefix ' ' 'NDVI' ])
    % save figure
    foldername = usavepath;
    filename = [name_prefix '_' num2str(id_rand) '_NDVI'];
    imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
end

%%
% ---------------------------------------- %
% Custom Mode :: Custom Input Combinations
% ---------------------------------------- %
if    customMode
      cmON = true;
      cmtic = 0;
else; cmON = false;
end


if customMode
    
    while cmON == true
        close all
        figure('Units','normalized','Position',[0.02 0.05 0.95 0.85]);
        for i = 1:min(6,nband)
            subplot(2,3,i)
            imshow(B{i}); title(['B' num2str(i) ' - ' band_specs{1}])
        end
        % update count
        cmtic = cmtic+1;
        % custom export file name
        msg = 'Enter 3 Bands for Custom RGB Composition';
        clc; disp(msg);
        prompt = ['Enter 3 Bands for RGB Composition: [1 to ' num2str(nband) '] example: 321'];
        answer = inputdlg(prompt);
        try aw = answer{1}; catch; return; end
        aw   = erase(aw,' '); aw = erase(aw,','); aw = erase(aw,'-');
        
        band_combo    = zeros(3,1);
        band_combo(1) = str2double(aw(1));
        band_combo(2) = str2double(aw(2));
        band_combo(3) = str2double(aw(3));
        combo_seq     = aw;
        %
        RGB_custom = A2(:,:,1:3);
        RGB_custom(:,:,1) = A2(:,:,band_combo(1));
        RGB_custom(:,:,2) = A2(:,:,band_combo(2));
        RGB_custom(:,:,3) = A2(:,:,band_combo(3));
        % plot
        figure; imshow(RGB_custom); pause(2)
        title([name_prefix ' ' combo_seq ' (original)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '-' num2str(cmtic) '_RGB-' combo_seq '_original'];
        imwrite(RGB_custom,[foldername '/' filename '.png']) % Save High Resolution Tif
%         saveas(gcf,[foldername '/' filename '.png'])    
        
        %-% Stretch Limit Adjust
        J = RGB_custom;
        J = imadjust(J,stretchlim(J));
        % plot
        figure; imshow(J); pause(2)
        title([name_prefix ' ' combo_seq ' (StretchLim adj.)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq];
        imwrite(J,[foldername '/' filename '.png']) % Save High Resolution Tif
%         saveas(gcf,[foldername '/' filename '.png'])
        
        % plot
        figure; imshow(RGB_custom); pause(2)
        title([name_prefix ' ' combo_seq ' (original)' ])
        
        % check if the user wants to continue
        msg = 'Would you like to Continue?';
        clc; disp(msg);
        answer = questdlg('Would you like to Continue?');
        switch answer
            case 'Continue'
                cmON = true;
            case 'No'
                cmON = false;
        end
    end
end
% ---------------------------------------- %
close all
disp('all done.');
disp(['check your files on: ' usavepath])
close all;


% nested functions
    function ndvi_colormap = make_ndvi_colormap()
        % make_ndvi_colormap.m - create NDVI colormap and demonstrate lookup conversion from grayscale to RGB
        % HJSIII, 19.10.25
        ndvi_map_r = [ (33:80)  80*ones(1,79)  (80:-1:0)  zeros(1,48) ]' /80;  % red
        ndvi_map_g = flipud( ndvi_map_r );                                     % green
        ndvi_map_b = zeros( size( ndvi_map_r ) );                              % blue
        ndvi_colormap = [ ndvi_map_r  ndvi_map_g  ndvi_map_b ];
    end


end


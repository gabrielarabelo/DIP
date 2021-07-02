function DIP_RGB(parameters)

close all; clc
disp('DIP-RGB :: ')
disp('ready to start!')


P = parameters;
% GUI % select file
msg = 'Select Multiband File (.mat) or Band File';
clc; disp(msg);
disp('Valid inputs are:')
disp('--------------------------------------------------------')
disp('a multiband .tif, or')
disp('the first band of an already aligned multispectral image.')
disp('--------------------------------------------------------')
disp('If you do not have any of these, use [DIP_align] first')
disp('--------------------------------------------------------')

[file,path] = uigetfile('*.*', msg);
I = imread([path '/' file ]);

if size(I,3)==1
    % FIND MULTIBAND FILE PREFIX:
    file_path = path;
    try file_name = extractBefore(file,'_1.tif');catch
        try file_name = extractBefore(file,'_2.tif'); catch
            try file_name = extractBefore(file,'_3.tif'); catch
                try file_name = extractBefore(file,'_4.tif'); catch
                    try file_name = extractBefore(file,'_5.tif'); catch
                        try file_name = extractBefore(file,'_6.tif'); catch
                        end
                    end
                end
            end
        end
    end
    adj_filename = erase(file_name,'_');
    
    
else
    
end


M = I;

nband = size(M,3);

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

try customRGB = P.customRGB;
catch; customRGB = [];
end

try customMode = P.customMode;
catch; customMode = true;
end

try RGB_bands = P.RGB_bands;
catch; RGB_bands = [3 2 1];
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
    disp('-----------------------------');
end

try band_specs = P.band_specs;
catch
    if strcmp(camera,'altum')
        band_specs  = {'Blue (475nm 32nm)'; ...
            'Green (560nm 27nm)';...
            'Red (668nm 14nm)';...
            'Red Edge (717nm 12nm)';...
            'Near-IR (842nm 57nm)';...
            'LWIR Thermal IR (8-14um)' ...
            };
    elseif strcmp(camera,'rededge')
        band_specs  = {'Blue (475nm 32nm)'; ...
            'Green (560nm 27nm)';...
            'Red (668nm 14nm)';...
            'Red Edge (717nm 12nm)';...
            'Near-IR (842nm 57nm)';...
            };
    else
        band_specs = cell(nband,1);
        for i = 1:nband; band_specs{i} = []; end
    end
 
end


% ------------------------------------------------------ %
% Start GUI
% ------------------------------------------------------ %

% select export folder
msg = 'Select Export Folder';
clc; disp(msg);
usavepath = uigetdir;
usavepath_proc = [usavepath '/' 'process'] ;
mkdir(usavepath_proc)
% usavepath_lowr = [usavepath '/' 'low-res'] ;
% mkdir(usavepath_lowr)
% custom export file name
msg = 'Create a Custom Prefix for the File Name';
clc; disp(msg);
prompt = ['Custom File Name Prefix:'];
answer = inputdlg(prompt,'s');
if isempty(answer{1}); answer{1} = 'IMG'; end


% INIT SOME STUFF
% Generate random id to label files (just to avoid replacing images)
id_rand = round(now*1000);

% create file name and title prefix
name_prefix  = [answer{1,1}];



% Apply Scale Factor
disp('resizing image...')
A0 = imresize(M,scale);
disp('done.');

% A = uint16(A0);

% % Read Image Mode Info
% try (sum(class(A)=='uint8')); img_bit = 8;
% catch; try (sum(class(A)== 'uint16')); img_bit = 16; catch; end
% end

A2 = A0;


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
saveas(gcf,[foldername '/' filename '.png'])

%-% Haze & Gamma Adjust
J = RGB;
J = imreducehaze(J,haze_adj,'method',haze_adj_method);
J = imadjust(J,[],[],gamma_adj);
% plot
figure; imshow(J);
title([name_prefix ' RGB (Haze & Gamma adj.)' ])
% save figure
foldername = usavepath;
filename = [name_prefix '_' num2str(id_rand) '_H&G_RGB-' combo_seq];
imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
saveas(gcf,[foldername '/' filename '.png'])

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
saveas(gcf,[foldername '/' filename '.png'])

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
        figure; imshow(RGB_custom);
        title([name_prefix ' ' combo_seq ' (original)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq '_original'];
        imwrite(RGB_custom,[foldername '/' filename '.tif']) % Save High Resolution Tif
        saveas(gcf,[foldername '/' filename '.png'])
        %-% Stretch Limits Adjustment
        J = RGB_custom;
        J = imadjust(J,stretchlim(J));
        % plot
        figure; imshow(J);
        title([name_prefix ' ' combo_seq ' (Auto adj.)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq];
        imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
        saveas(gcf,[foldername '/' filename '.png'])
        %-% Haze & Gamma Adjust
        J = RGB_custom;
        J = imreducehaze(J,haze_adj,'method',haze_adj_method);
        J = imadjust(J,[],[],gamma_adj);
        % plot
        figure; imshow(J);
        title([name_prefix ' ' combo_seq ' (Haze&Gamma)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_H&G_RGB-' combo_seq];
        imwrite(J,[foldername '/' filename '.tif']) % Save High Resolution Tif
        saveas(gcf,[foldername '/' filename '.png'])
        close all;
    end
end

disp('done.');
disp(['check your files on: ' usavepath])


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
            imshow(M(:,:,i)); title(['B' num2str(i) ' - ' band_specs{1}])
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
        figure; imshow(RGB_custom);
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
        figure; imshow(J);
        title([name_prefix ' ' combo_seq ' (StretchLim adj.)' ])
        % save figure
        foldername = usavepath;
        filename = [name_prefix '_' num2str(id_rand) '_RGB-' combo_seq];
        imwrite(J,[foldername '/' filename '.png']) % Save High Resolution Tif
%         saveas(gcf,[foldername '/' filename '.png'])
        
        % plot
        figure; imshow(RGB_custom);
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


end


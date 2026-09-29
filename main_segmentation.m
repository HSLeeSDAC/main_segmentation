% =========================================================================
% Supplementary Code: Automated Mg Wire Segmentation and Quantification
%
% Description:
%   Automated image processing script utilizing adaptive thresholding,
%   distance transform-based watershed segmentation, and multi-parametric
%   filtering (Area, Circularity, Mean Intensity) to selectively detect
%   intact Mg wire cross-sections in polymer matrix composites.
%
% Associated Publication:
%   "Mechanical behavior of a partially biodegradable hybrid bone plate 
%    made of magnesium wire/polylactic acid core under bending fatigue 
%    in a simulated physiological environment"
%   Target Journal: Composites Science and Technology
%
% System Requirements:
%   - MATLAB R2020b or later
%   - Image Processing Toolbox
% =========================================================================

clearvars;
close all;

%% 1. File Loading
basename = 'filename'; % Target image filename (without extension)
exts = {'.png','.jpg','.jpeg','.tif','.tiff','.bmp'};
fname = '';

for k = 1:numel(exts)
    targetFile = [basename, exts{k}];
    if exist(targetFile, 'file')
        fname = targetFile;
        break;
    end
end

if isempty(fname)
    error('Error: Input sample image file not found. Please check file path.');
end

I = imread(fname);
if ndims(I) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end
Igray = im2double(Igray);

%% 2. Preprocessing & Adaptive Thresholding
Iadj = imadjust(Igray); 
Iblur = imgaussfilt(Iadj, 1.0); 

% Adaptive thresholding with reduced sensitivity to suppress background noise
sensitivity = 0.45; 
T = adaptthresh(Iblur, sensitivity, 'ForegroundPolarity', 'bright');
BW = imbinarize(Iblur, T);

% Global intensity cutoff to prevent over-segmentation in dark epoxy regions
BW = BW & (Iblur > 0.5); 

%% 3. Morphological Processing & Distance-based Watershed
BW = imfill(BW, 'holes'); 
BW = bwareaopen(BW, 5000); % Initial noise suppression

D = -bwdist(~BW);
h_value = 0.5; 
D_mod = imhmin(D, h_value);
D_mod(~BW) = -Inf;

L_wash = watershed(D_mod);
BW_separated = BW;
BW_separated(L_wash == 0) = 0; 

%% 4. Morphometric & Intensity Filtering
CC = bwconncomp(BW_separated);
% Pass grayscale image (Igray) to extract MeanIntensity of each region
props = regionprops(CC, Igray, 'Area', 'Perimeter', 'Centroid', 'BoundingBox', 'MeanIntensity');

validIdx = [];
for k = 1:numel(props)
    area = props(k).Area;
    perim = props(k).Perimeter;
    meanInt = props(k).MeanIntensity;
    
    circularity = (4 * pi * area) / (perim^2);
    
    % Selective Multi-Parametric Criteria:
    if area >= 23000 && area <= 45000 && circularity >= 0.65 && meanInt >= 0.70
        validIdx = [validIdx, k];
    end
end

% Extract verified Mg wire properties
props_filtered = props(validIdx);
nRegions = numel(props_filtered);

%% 5. Visualization & Plotting
figure('Color', 'w', 'Position', [100 100 1200 550]);

subplot(1,2,1);
imshow(I);
title('Original Input Image');

subplot(1,2,2);
lblMap = zeros(size(BW_separated));
for k = 1:nRegions
    lblMap(CC.PixelIdxList{validIdx(k)}) = k;
end

imshow(label2rgb(lblMap, 'jet', 'k', 'shuffle')); 
hold on;

for k = 1:nRegions
    bb = props_filtered(k).BoundingBox;
    centroid = props_filtered(k).Centroid;
    area = props_filtered(k).Area;
    
    rectangle('Position', bb, 'EdgeColor', 'w', 'LineWidth', 1.5);
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 6, 'LineWidth', 1.5);
    
    txt = sprintf('ID:%d\n%.0f', k, area);
    text(centroid(1), centroid(2), txt, ...
        'Color', 'y', ...
        'FontSize', 8, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0 0 0 0.6]); 
end
hold off;
title(sprintf('Filtered Mg Wires (Count: %d)', nRegions));
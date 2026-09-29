========================================================================
Supplementary Code for:
"Mechanical behavior of a partially biodegradable hybrid bone plate 
 made of magnesium wire/polylactic acid core under bending fatigue 
 in a simulated physiological environment"
========================================================================

1. OVERVIEW
------------------------------------------------------------------------
This package provides the MATLAB script used for automated cross-sectional 
image segmentation, distance transform-based watershed separation, and 
multi-parametric morphometric analysis (Area, Circularity, Mean Intensity) 
of Mg wires embedded in a polymer matrix core.

2. SOFTWARE & TOOLBOX REQUIREMENTS
------------------------------------------------------------------------
- MATLAB R2020b or later
- Image Processing Toolbox

3. FILE CONTENTS
------------------------------------------------------------------------
- main_segmentation.m : Main execution script for image segmentation.
- filename.jpg         : Representative cross-sectional sample image.
- LICENSE.txt          : MIT License agreement file.
- README.txt           : Documentation and execution guidelines.

4. INSTRUCTIONS TO RUN
------------------------------------------------------------------------
1. Place 'main_segmentation.m', 'filename.jpg', 'LICENSE.txt', and 
   'README.txt' in the same working directory in MATLAB.
2. Open and run 'main_segmentation.m'.
3. The script automatically loads 'filename.jpg', performs adaptive 
   thresholding, watershed separation, and morphometric filtering, and 
   displays the quantified Mg wire cross-sections in a dual-panel figure.

5. KEY PARAMETERS
------------------------------------------------------------------------
- 'sensitivity'    (Line 43) : Adaptive thresholding sensitivity (default: 0.45).
- Global Cutoff    (Line 48) : Intensity threshold for epoxy noise removal (> 0.50).
- Morphometric Filters (Lines 72-74):
  * Area           : 23,000 - 45,000 pixels
  * Circularity    : >= 0.65
  * Mean Intensity : >= 0.70
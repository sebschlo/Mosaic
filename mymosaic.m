function [ img_mosaic ] = mymosaic( img_input )
%MYMOSAIC Summary of this function goes here
%   This function will stitch images together into a panorama or mosaic.
%   It assumes img_input contains color images that are in the right order,
%   whether it is from left to right or vice versa. This code was adapted
%   from the MathWorks tutorial on Feature Based Panoramic Image Stitching.


%% Variables
thresh = 1;
anmsPoints = 200;
numImgs = numel(img_input);


%% Register features for image 1 and initialize transformations

%  Read the first image
I = cell2mat(img_input(1));

%  Find features for I
grayIm = im2double(rgb2gray(I));

% Corner Detection
%  Preliminary Harris corner detection produces matrix of values indicating
%  strength of corner at that pixel location.
C1 = cornermetric(grayIm);

% Adaptive Non-Maximum Suppression
%  Uses corner values and applies non-maximum suppression to filter results
%  into a more valuable set of corners.
[yPts, xPts, ~] = anms(C1,anmsPoints);

% Extract Feature Descriptors
%  the p arrays contain the feature descriptor associated to the corners 
%  in the y and x arrays
p = feat_desc(grayIm, yPts, xPts);

% Initialize all the transforms to the identity matrix.
tforms(numImgs) = projective2d(eye(3));

%% Iterate over remaining image pairs
for n = 2:numImgs
    % Store previous points and features
    prevX = xPts;
    prevY = yPts;
    prevP = p;
    prevI = I;
    
    % Read next image and repeat the process
    I = cell2mat(img_input(n));
    
    % Detect and extract features
    grayIm = im2double(rgb2gray(I));
    C1 = cornermetric(grayIm);
    [yPts, xPts, ~] = anms(C1,anmsPoints);
    p = feat_desc(grayIm, yPts, xPts);
    
    % Find correspondences between I(n) and I(n-1)
    m = feat_match( prevP, p );

    % Reshuffle second set of points so that each index is a match
    matchedX2 = -1*ones(anmsPoints,1);
    matchedY2 = -1*ones(anmsPoints,1);
    for i=1:anmsPoints
        if m(i) >= 0
            matchedX2(i) = xPts(m(i));
            matchedY2(i) = yPts(m(i));
        end
    end

    % Eliminate outliers
    inlierIndexes = matchedX2 >= 0;
    ilx1 = prevX(inlierIndexes);
    ilx2 = matchedX2(inlierIndexes);
    ily1 = prevY(inlierIndexes);
    ily2 = matchedY2(inlierIndexes);
    
    % Filter further with RANSAC and obtain H matrix
    [H, ransacIdx] = ransac_est_homography(ily1, ilx1, ily2, ilx2, thresh);
    
    % Save the transformation between I(n) and I(n-1)
    tforms(n) = projective2d(H');

    % Compute aggregate T
    tforms(n).T = tforms(n-1).T * tforms(n).T;
    
    % Plot each point correspondances result
%     plotter(prevX, prevY, xPts, yPts, prevI, I, ...
%             ilx1, ily1, ilx2, ily2, ransacIdx); 
end

%% Compute the transformation to the middle image

% Find size of final image
for i = 1:numImgs
    imageSize = size(cell2mat(img_input(i)));       
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)],...
        [1 imageSize(1)]);    
end

% Apply the center image's inverse transform to all others
centerIdx = floor((numImgs+1)/2);
Tinv = invert(tforms(centerIdx));
for i = 1:numImgs
    tforms(i).T = Tinv.T * tforms(i).T;
end

%% Initialize Mosaicing

for i = 1:numImgs
    imageSize = size(cell2mat(img_input(i))); 
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)],...
        [1 imageSize(1)]);
end

% Find the min and max output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Widtha nd height of pano
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the empty panorama
panorama = zeros([height width 3], 'like', I);

%% Fill in the Mosaic
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% create 2d spatial reference object
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);


% create the panorama
for i = 1:numImgs
    I = cell2mat(img_input(i));
    
    % Transform I into the pano
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
    
    % Create a mask for the overlay operation
    warpedMask = imwarp(ones(size(I(:,:,1))), tforms(i), ...
        'OutputView', panoramaView);
    
    % Clean up edge artifacts in the mask and convert to binary im
    warpedMask = warpedMask >= 1;
    
    % Overlay the warpedImage onto the pano
    panorama = step(blender, panorama, warpedImage, warpedMask);
end

figure
imshow(panorama)
    

end
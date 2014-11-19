%% IMAGE STITCHING BY SEBASTIAN SCHLOESSER
%  This test script will call all the necessary functions
%  in order to stitch 2 pictures together. 
clear

% Enables plotting of intermediate steps
plot = 1;

%% Load images to be stitched
%  Place the desired picture names in here
originalIm1 = imread('21.jpg');
originalIm2 = imread('22.jpg');
im1  = im2double(rgb2gray(originalIm1));
im2  = im2double(rgb2gray(originalIm2));


%% Corner Detection
%  Preliminary Harris corner detection produces matrix of values indicating
%  strength of corner at that pixel location.
C1 = cornermetric(im1);
C2 = cornermetric(im2);


%% Adaptive Non-Maximum Suppression
%  Uses corner values and applies non-maximum suppression to filter results
%  into a more valuable set of corners.
[y1, x1, rmax1] = anms(C1,100);
[y2, x2, rmax2] = anms(C2,100);


%% Extrac Feature Descriptors
%  the p arrays contain the feature descriptor associated to the corners 
%  in the y and x arrays
p1 = feat_desc(im1, y1, x1);
p2 = feat_desc(im2, y2, x2);


%% Descriptor Matching
%  Match the corners from the p's. y1 and x1 remain the same, but the 
%  second set of points needs to be reshuffled to match the indeces in m. 
m = feat_match( p1, p2 );

n = size(x1,1);
matchedX2 = zeros(n,1);
matchedY2 = zeros(n,1);
for i=1:n
    matchedX2(i) = x2(m(i));
    matchedY2(i) = y2(m(i));
end

%% RANSAC
[H, inlier_ind] = ransac_est_homography(y1,x1,matchedY2,matchedX2,thresh);
ranX1 = x1(inlier_ind);
ranY1 = y1(inlier_ind);
ranX2 = matchedX2(inlier_ind);
ranY2 = matchedY2(inlier_ind);


%% Plotting

if plot
    % Original Images and detected edges
    subplot(2,2,1);
    imshow(originalIm1);
    hold on
    scatter(x1, y1, 'ro');
    title('Original Image 1');
    
    subplot(2,2,2);
    imshow(originalIm2);
    hold on
    scatter(x2, y2, 'ro');
    title('Original Image 2');
    
    % Now plot the RANSAC and feat_match results
    [h1, w1, ~] = size(originalIm1);
    [h2, w2, ~] = size(originalIm2);
    combinedImage = uint8(zeros(max(h1, h2), w1+w2, 3));
    combinedImage(1:h1,1:w1,:) = originalIm1;
    combinedImage(1:h2,w1+1:end,:) = originalIm2;
    subplot(2,2,3:4);
    imshow(combinedImage);
    title('RANSAC and feature match results');
    
    hold on
    line(reshape([ranX1'; ranX2'],1,[]),reshape([ranY1'; ranY2'],1,[]));
end
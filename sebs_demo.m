%% IMAGE STITCHING BY SEBASTIAN SCHLOESSER
%  This test script will call all the necessary functions
%  in order to stitch a few pictures together. 



%% Load images to be stitched
im1  = rgb2gray(im2double(imread('21.jpg')));
im2  = rgb2gray(im2double(imread('22.jpg')));

%% Corner Detection
% subplot(1,3,1);
imshow(im1);
title('Original Image');

C = cornermetric(im1);
% subplot(1,3,2);
% imshow(C);
title('Harris Corner Detection');

%% Adaptive Non-Maximum Suppression

[y, x, rmax] = anms(C,100);
hold on
scatter(x, y, 'ro');

%% Extrac Feature Descriptors

p = feat_desc(im1g, y, x);

%% Descriptor Matching

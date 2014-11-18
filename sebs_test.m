%% IMAGE STITCHING BY SEBASTIAN SCHLOESSER
%  This test script will call all the necessary functions
%  in order to stitch a few pictures together. 



%% Load images to be stitched
im1 = imread('21.jpg');
im2 = imread('22.jpg');

%% Corner Detection
% subplot(1,3,1);
imshow(uint8(im1));
title('Original Image');

C = cornermetric(rgb2gray(im1));
% subplot(1,3,2);
% imshow(C);
title('Harris Corner Detection');

%% Adaptive Non-Maximum Suppression

[y, x, rmax] = anms(C,100);
hold on
scatter(x, y, 'ro');


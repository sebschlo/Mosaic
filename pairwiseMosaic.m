function [ output_args ] = pairwiseMosaic( im1, im2, anmsPts, ransacThresh)
%PAIRWISEMOSAIC Summary of this function goes here
%   This function stitches two images together

[h1, w1, ~] = size(originalIm1);
[h2, w2, ~] = size(originalIm2);

%% Corner Detection
%  Preliminary Harris corner detection produces matrix of values indicating
%  strength of corner at that pixel location.
C1 = cornermetric(im1);
C2 = cornermetric(im2);


%% Adaptive Non-Maximum Suppression
%  Uses corner values and applies non-maximum suppression to filter results
%  into a more valuable set of corners.
[y1, x1, ~] = anms(C1,anmsPoints);
[y2, x2, ~] = anms(C2,anmsPoints);


%% Extrac Feature Descriptors
%  the p arrays contain the feature descriptor associated to the corners 
%  in the y and x arrays
p1 = feat_desc(im1, y1, x1);
p2 = feat_desc(im2, y2, x2);


%% Descriptor Matching
%  Run feature matching function
m = feat_match( p1, p2 );

%  Reshuffle second set of points so that each index is a matched set of
%  points determined by the m. 
matchedX2 = -1*ones(anmsPoints,1);
matchedY2 = -1*ones(anmsPoints,1);
for i=1:anmsPoints
    if m(i) >= 0
        matchedX2(i) = x2(m(i));
        matchedY2(i) = y2(m(i));
    end
end

%  Eliminate outliers
goodMatches = matchedX2 >= 0;
ilx1 = x1(goodMatches);
ilx2 = matchedX2(goodMatches);
ily1 = y1(goodMatches);
ily2 = matchedY2(goodMatches);

%% RANSAC
[H, inlier_ind] = ...
    ransac_est_homography(ily1, ilx1, ily2, ilx2, ransacThresh);
ranX1 = ilx1(inlier_ind);
ranY1 = ily1(inlier_ind);
ranX2 = ilx2(inlier_ind);
ranY2 = ily2(inlier_ind);


%% Perform Stitching


end


%% IMAGE STITCHING BY SEBASTIAN SCHLOESSER
%  This test script will call all the necessary functions
%  in order to stitch 2 pictures together. 
clear

% Enables plotting of intermediate steps
plot = [  1  ;   % Overall plotting
          1  ;   % Initial corner detection and suppression steps
          1  ;   % Feature matching results
          1  ]'; % Ransac results
      
ransacThresh = 1;
anmsPoints = 200;

%% Load images to be stitched
%  Place the desired picture names in here
originalIm1 = imread('11.jpg');
originalIm2 = imread('12.jpg');
im1  = im2double(rgb2gray(originalIm1));
im2  = im2double(rgb2gray(originalIm2));
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
[y1, x1, rmax1] = anms(C1,anmsPoints);
[y2, x2, rmax2] = anms(C2,anmsPoints);


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


%% Plotting

if plot(1)
    
    % Original Images and detected edges
    if plot(2)
        figure
        
        subplot(2,2,1);
        imshow(imregionalmax(C1));

        subplot(2,2,3);
        imshow(imregionalmax(C2));
        
        subplot(2,2,2);
        imshow(originalIm1);
        hold on
        scatter(x1, y1, 'ro');
        title('Original Image 1');

        subplot(2,2,4);
        imshow(originalIm2);
        hold on
        scatter(x2, y2, 'ro');
        title('Original Image 2');
    end
    
    % Plot the RANSAC and/or feat_match results
    if plot(3) || plot(4)
        figure
        combinedImage = uint8(zeros(max(h1, h2), w1+w2, 3));
        combinedImage(1:h1,1:w1,:) = originalIm1;
        combinedImage(1:h2,w1+1:end,:) = originalIm2;
        imshow(combinedImage);
        title('RANSAC and feature match results');
        hold on
        scatter(x1, y1, 'ro');
        scatter(x2+w1, y2, 'ro');
        line([w1 w1],[1 size(combinedImage,1)],'Color','w','LineWidth',4); 
        
        % PLOT feat_match
        if plot(3)
            line([ilx1';(ilx2+w1)'],[ily1';ily2'],...
                'Color','y','LineWidth', 2);
        end
        
        % Plot RANSAC
        if plot(4)
            line([ranX1';(ranX2+w1)'],[ranY1';ranY2'],...
                'Color','g','LineWidth',2);
        end
    end
end
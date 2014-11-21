function plotter( x1, y1, x2, y2, im1, im2, ilx1, ily1, ilx2, ily2, inlier_ind )
%PLOTTER Summary of this function goes here
%   Detailed explanation goes here

ranX1 = ilx1(inlier_ind);
ranY1 = ily1(inlier_ind);
ranX2 = ilx2(inlier_ind);
ranY2 = ily2(inlier_ind);

[h1, w1, ~] = size(im1);
[h2, w2, ~] = size(im2);

figure
combinedImage = uint8(zeros(max(h1, h2), w1+w2, 3));
combinedImage(1:h1,1:w1,:) = im1;
combinedImage(1:h2,w1+1:end,:) = im2;
imshow(combinedImage);
title('RANSAC and feature match results');
hold on
scatter(x1, y1, 'r*');
scatter(x2+w1, y2, 'r*');
line([w1 w1],[1 size(combinedImage,1)],'Color','w','LineWidth',4);

% PLOT feat_match

line([ilx1';(ilx2+w1)'],[ily1';ily2'],...
    'Color','y','LineWidth', 2);


% Plot RANSAC

line([ranX1';(ranX2+w1)'],[ranY1';ranY2'],...
    'Color','g','LineWidth',2);

end


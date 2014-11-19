function [numInliers, X, Y, inlier_ind] =...
                calculateInliers(x1, y1, x2, y2, indexes, thresh)

    % Calculate homography with those 4 points
    H = est_homography(x2(indexes), y2(indexes), x1(indexes), y1(indexes));
    
    % Apply homography to all im1points to obtain allegged im2points X, Y
    [X, Y] = apply_homography(H, x1, y1);
    
    % Compute SSD between alleged im2points X, Y and actual im2points x2,y2
    % Store the amount of inliers found. Eliminate non-inliers from X and Y
    % point arrays
    inlier_ind = sum(([x2 y2] - [X Y]).^2,2) < thresh;
    X = X(inlier_ind);
    Y = Y(inlier_ind);
    numInliers = sum(inlier_ind);    
end


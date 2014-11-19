function [H, inlier_ind] = ransac_est_homography(y1,x1,y2,x2,thresh)
%RANSAC_EST_HOMOGRAPHY Summary of this function goes here


numLoops = 500;

% Set up inlier array
n = length(y1);
inlierAmt = zeros(numLoops,5);


% Perform RANSAC algorithm numLoops times in hopes of finding a good
% homography. 
for i=1:numLoops
    % Craete indexes for 4 random pairs and store them
    randIdx = randperm(n,4);
    inlierAmt(i,2:5) = randIdx;
    
    % Calculate the number of inliers for the resulting homography
    [numInliers,~,~,~] = calculateInliers(x1, y1, x2, y2, randIdx, thresh);
    inlierAmt(i,1) = numInliers;
end

% Find the 4 points that gave the highest amt of inliers
[~, I] = max(inlierAmt(:,1));
goodPts = inlierAmt(I,2:5);

% Recompute H for this set. This process is repeated to avoid saving the
% actual set of inliers for however many numLoops there are.
[~, X, Y, inlier_ind] = calculateInliers(x1, y1, x2, y2, goodPts, thresh); 

% Now compute H with all of these inliers
H = est_homography(x1(inlier_ind), y1(inlier_ind), X, Y);

end


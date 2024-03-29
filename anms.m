function [ y, x, rmax ] = anms( cimg, max_pts )
%ANMS Summary of this function goes here
%   Detailed explanation goes here
%   Adaptive Non-Maximum Suppression

% Remove the least cornery corners
mx = max(max(cimg));
mn = min(min(cimg));
thresh = (mx-mn)*0.00001;
cimg(cimg < thresh) = 0;

% Do regular non-maximum suppression 
cnms = imregionalmax(cimg);
cornerInds = find(cnms == true);
cornerVals = cimg(cornerInds);

% Plot
% subplot(1,3,3);
% imshow(cnms);
% title('adaptive non-max suppression');

% Set up distance matrix
distTable = zeros(length(cornerInds),2);

for i=1:length(cornerInds)
    % First extract the indeces of the current corner
    [yCurr, xCurr] = ind2sub(size(cimg), cornerInds(i));
    
    % Then obtain an array with all the corners that have a larger val
    largers = cornerInds(cornerVals > cornerVals(i));
    
    % Get their indexes
    [Y, X] = ind2sub(size(cimg), largers);

    % Calculate the distance between the current corner and the rest
    % get the smallest one, which is the radius value of the current
    % corner, inside which it is the maximum corner
    dist = pdist2([X Y], [xCurr yCurr], 'euclidean', 'Smallest',1);
    
    % Store this distance value and the current corner index
    distTable(i,:) = [dist cornerInds(i)];
end

% Sort the table of distances and spit out the top max_points
sortDistTable = sortrows(distTable,1);
[y, x] = ind2sub(size(cimg), sortDistTable(end-max_pts+1:end,2));

% Assign the maximum radius for given max_points
rmax = sortDistTable(end-max_pts+1,1);

end


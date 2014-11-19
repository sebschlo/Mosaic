function [ m ] = feat_match( p1, p2 )
%FEAT_MATCH Summary of this function goes here
%   This function matches up descriptors from both images

thresh = .75;

% Prepare output objects
n = size(p1,2);
m = -1*ones(n,1);

% Repeat arrays to calculate SSD
p1rep = kron(p1, ones(1,n));
p2rep = repmat(p2,[1 n]);

% Square and sum columns. Each n col block represents
% a point in p1. SSD should have n^2 columns total
SSD = sum((p1rep-p2rep).^2,1);

% Convert to matrix. Now each row represents the SSD of
% a point in p1 vs all the points in p2. 
SSDmat = vec2mat(SSD, n);
[SSDmat, index] = sort(SSDmat, 2);

% Now calculate the ratio of first and second points
goodPoints = (SSDmat(:,1)./SSDmat(:,2)) < thresh;

% Assign values
m(goodPoints) = index(goodPoints,1);


end


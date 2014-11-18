function [ p ] = feat_desc( im, y, x )
%FEAT_DESC Summary of this function goes here
%   This function will extract the feature descriptors of the imag
%   based on the corners found by the Harris algorithm and filtered
%   by adaptive non-maximum suppression.

% create p: a 64 x n array that contains the descriptors of each
% corner made into a column vector
n = length(y);
p = zeros(64,n);

% Iterate through every point
for i=1:n
    % Sample 40x40 pixel square around point and blur
    try
        square = im(y(i)-19:y(i)+20, x(i)-19:x(i)+20);
    catch
        % If the square results in out of bounds, continue to
        % the next loop iteration to skip this corner. A col
        % of zeros will remain in this corner's place. 
        continue;
    end
    filter = fspecial('gaussian');
    square = imfilter(square, filter, 'symmetric');
    
    % Subsample to reduce to 8x8 pixels
    subSam = square(1:5:end,1:5:end);
    
    % Bias/Gain Normalize
    subSam = double(subSam);
    subSam = subSam - mean2(subSam);
    subSam = subSam / std2(subSam);
    
    % Make into column vector and place in p
    p(:,i) = subSam(:);
end

end
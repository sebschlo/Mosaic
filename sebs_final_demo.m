clear
clc

% img_input = {imread('lib1.jpg'), imread('lib2.jpg'), imread('lib3.jpg'),...
%     imread('lib4.jpg'), imread('lib5.jpg')};

% img_input = {imread('11.jpg'), imread('12.jpg')};
% 
% img_input = {imread('21.jpg'), imread('22.jpg'), imread('23.jpg')};

% img_input = {imread('lib1.jpg'), imread('lib2.jpg'), imread('lib3.jpg')};

img_input = {imread('view1.jpg'), imread('view2.jpg'), imread('view3.jpg'),...
    imread('view4.jpg'), imread('view5.jpg')};

mymosaic(img_input);


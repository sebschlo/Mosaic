clear
clc


%% Museum Stairs
% img_input = {imread('11.jpg'), imread('12.jpg')};


%% Mountains
% img_input = {imread('21.jpg'), imread('22.jpg'), imread('23.jpg')};


%% Library
% img_input = {imread('lib1.jpg'), imread('lib2.jpg'),... 
%     imread('lib3.jpg')};


%% View of the City
img_input = {imread('view1.jpg'), imread('view2.jpg'),...
    imread('view3.jpg'),imread('view4.jpg'), imread('view5.jpg')};

mymosaic(img_input);
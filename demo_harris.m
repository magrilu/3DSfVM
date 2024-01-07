% Harris corner detection algorithm
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.
%
% 3DSfVM
% Politecnico di Milano
%
% Luca Magri
% for comments and suggestions please send an email to luca.magri@polimi.it
%
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.
%%
I = imread('data/road.png');
%I = imread('data/parigi.jpg');
I = rgb2gray(I);

% harris parameter
s = 5; % size of sigma in gaussian

S = fspecial('sobel');
G = fspecial('gaussian',2*ceil(2*s)+1, s);

% directional derivatives
Iu = filter2(S, I, 'same');
Iv = filter2(S',I, 'same');

% convolve with Gaussian
Iuv = filter2(G, Iu.*Iv,'same');
Ivv = filter2(G, Iv.^2, 'same');
Iuu = filter2(G, Iu.^2, 'same');

% trace and determinant
tr = Iuu + Ivv;
dt = Iuu.*Ivv - Iuv.^2;

%C = dt - 0.04 *tr.^2; % H-S version
C = dt./(1+tr);     % Noble version
figure; 
imagesc(C);
colormap('jet');
axis off;
axis square;
axis equal;
colorbar;
%% non maxima suppression
se = strel('square', 11);
dilatedC = imdilate(C, se);
localMaxima = C .* (C == dilatedC);

%% Thresholding
thr = 3e3;
cornes =  localMaxima>thr;
%%
[y,x]= find(cornes);

figure;
imagesc(C);
colormap('jet')
hold on;
plot(x,y,'r*')
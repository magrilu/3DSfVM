% Moravec Corner Detection Algorithm
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.
%
% 3DSfVM
% Politecnico di Milano
%
% Luca Magri
% for comments and suggestions please send an email to luca.magri@polimi.it
%
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.

%% Synthetic image
% You can replace this with actual image processing
I = uint8(zeros(51,51,3));
I(7:40,20,1:3) = 255;
I(40,20:40,1:3) = 255;
%% Read real image
I = imread('data/road.png');
I = imresize(I, 0.2); % Resize for faster computation
if(size(I,3) ==3)
    I = rgb2gray(I);  % Convert to grayscale if it's a color image
end


%% Image preparation
h = size(I,1);
w = size(I,1);

do_rotate = 0;
do_addnoise = 0;

% Apply noise or rotation if set
if(do_rotate)
    I = imrotate(I,200);
end
if(do_addnoise)
    noiseDensity = 0.01;
    temp = imnoise(I(:,:,1), 'gaussian', noiseDensity);
    for i = 1:3
        I(:,:,i) = temp;
    end
end

% Show the initial image
figure; imshow(I);

%% Initialize parameters for Moravec
windowSize = 3;
threshold = 1000;


%% Moravec algorithm
ssd_img = zeros(h,w);
halfSize = floor(windowSize/2);
% Moravec algorithm loop
for x = 2+halfSize:h-halfSize-1
    for y = 2+halfSize:w-halfSize-1
        % Initialize minimum value
        minValue = inf;
        for dx = -1:1
            for dy = -1:1
                if dx == 0 && dy == 0
                    continue;
                end
                % Extracting window and its shifted version
                windowOriginal = I(x-halfSize:x+halfSize, y-halfSize:y+halfSize);
                windowShifted = I(x+dx-halfSize:x+dx+halfSize, y+dy-halfSize:y+dy+halfSize);

                % Compute the Sum of Squared Differences
                SSD = sum(sum((windowOriginal - windowShifted).^2));

                % Update minimum value
                if SSD < minValue
                    minValue = SSD;
                end
            end
        end
        % Assign the minimum SSD value to the corner matrix
        ssd_img(x,y) = minValue;
    end
end

% Visualizing the SSD image
figure;
imagesc(ssd_img); colormap('jet'); colorbar;
title('SSD Image');

% Thresholding the SSD image to get potential corners
ssd_maxima = (ssd_img > threshold);

% Non-Maxima Suppression
se = strel('square', 3);
dilated_ssd_img = imdilate(ssd_img, se);
corners = ssd_maxima & (ssd_img == dilated_ssd_img);
[y, x] = find(corners);

% Displaying the corners on the image
figure; imshow(I); hold on;
plot(x, y, 'r*');
title('Detected Corners');

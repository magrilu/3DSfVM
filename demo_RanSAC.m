% this script demonstrates the use of RanSaC to robustly fit a single
% instance of a circle to noisy data.
% Inshights on MSAC are presented and also on LO-RANSAC 
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.
%
% Image Analysis and Computer Vision
% Politecnico di Milano
%
% Luca Magri
% for comments and suggestions please send an email to luca.magri@polimi.it
%
% .\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.\\°//.
close all;
clear variables;
addpath("helper/model_spec/")
%% create data

% let's create some points on a cirlce
num_inliers = 100;
rho = 2; % radius of the circle
theta = linspace(0,2*pi, num_inliers);
X = [rho*cos(theta); rho*sin(theta)];

figure;
scatter(X(1,:),X(2,:));
axis off;
axis equal;
title('Clean data');
%% add noise
% now let's add some noise
sigma = 0.1;
X = X+sigma*rand(size(X));
% evaluate the gt model on the noisy inliers
model_gt = fit_circle(X);



figure;
hold all;
scatter(X(1,:),X(2,:));
drawCircle(model_gt(1),model_gt(2),model_gt(3),'g');
axis off;
axis equal;
title('Noisy data')
%% add outliers
% now let's add some outlier: uniform points in a bounding box
num_outliers = 2*num_inliers;

% define a bounding box around the data
minx = 2*min(X(1,:));
maxx = max(X(1,:));
miny = min(X(2,:));
maxy = max(X(2,:));
 
Y = [(maxx -minx).*rand(1,num_outliers) + minx; (maxy-miny)*rand(1,num_outliers) + miny];
X = [X,Y];

figure;
hold all;
scatter(X(1,:),X(2,:));
drawCircle(model_gt(1),model_gt(2),model_gt(3),'r');
axis off;
axis equal;
title('Data corrupted with outliers')
%% perform RANSAC to estimate a circle

do_show = 1; % to plot intermediate iterations
do_msac = 0;


modelfit = @fit_circle;
modeldist = @dist_circle;
p = 3;        % cardinality of the minimum sample set

n = size(X,2); % Number of points
alpha = 0.99;  % Desired probability of success = extracting a pure mss
f = 0.1 ;      % Pessimistic estimate of inliers fraction

t = 0.05;  % Inlier threhshold

MaxIterations = 10000; % Max number of iterations
MinIterations = 1000;  % Min number of iterations
maxcost = -Inf;
mincost = Inf;

i = 0;
while  i < max(ceil(log(1-alpha)/log(1-f^p)), MinIterations)
    % Generate p random indicies in the range 1..n
    mss = randsample(n, p);
    % Fit model to this minimal sample set.
    model = modelfit(X(:,mss));

    % Evaluate distances between points and model
    sqres = modeldist(model, X).^2;
    inliers = sqres < (t^2);


    % compute score
    if(do_msac)
          % Compute MSAc score
        cost = (sum(sqres(inliers)) + (n -sum(inliers)) * t^2);
    else
          % Compute RANSAC score
         cost = sum(inliers);
    end
   

    if (cost > maxcost) %(cost < mincost) %(cost > maxcost) %
        %mincost = cost;
        maxcost = cost;

        % PRO-TIP: LORANSAC- re-estimate the model on the inliers
        % to improove the efficiency
        model = modelfit(X(:,inliers));
        sqres = modeldist(model, X).^2;
        inliers = sqres < (t^2);
        
        bestinliers = inliers;
        bestmodel = model;

        %PRO-TIP Update the estimate of inliers fraction
        f = sum(bestinliers)/n;

        if(do_show)
            figure(99)
            clf;
            hold all;
            displayAnularBand(X,model, t,[0,0,1]); % inlier band
            drawCircle( model(1),model(2),model(3)); % model parameters
            scatter(X(1,:),X(2,:),'k.');
            scatter(X(1,inliers),X(2,inliers),'c.');
            plot(X(1,mss),X(2,mss),'b+','MarkerSize',20,'LineWidth',2); % mss
            axis equal;
            title(["iter: ", num2str(i)," cost:", num2str(maxcost)]);
            xlim([minx-0.1,maxx+0.1])
            ylim([miny-0.1,maxy+0.1])
            axis off;
            pause
        end
    end
    i = i + 1;
    if (i > MaxIterations)
        break;
    end
end




%% Visualize the solution

figure
hold all;
%displayAnularBand(X,bestmodel, t,[0,0,1]);
drawCircle( bestmodel(1),bestmodel(2),bestmodel(3),'b');
drawCircle( model_gt(1),model_gt(2),model_gt(3),'r');

scatter(X(1,:),X(2,:),'k.');
title(['Number of iterations ', num2str(i)]);
legend('estimated model', 'gt model');
axis equal;

%% compare the solution with respect to the ground truth
sqres_gt = modeldist(model_gt, X).^2;
inliers_gt = sqres < (t^2);
cost_gt = sum(inliers_gt)
maxcost

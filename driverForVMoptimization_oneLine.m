% This is the general purpose driver that I used for creating the plots in
% my dissertation paper using real flow data for 10mm increments and no
% delta Z
% version 24 October 2014
%
% Uses optical flow stored in 'flow_rect20.mat'
% Uses calibration from 2016/7/16
% Calls radial2XYdriver, which c

tic
%params.columns = 400;          
load('flow_rect20.mat');    % This is flow taken with 20 mm X translation.  Distortion has been removed.
                            % Source images were taken on 2016_07_25
                            % Distortion was removed on 2016_08_25
                            % This flow file comes from the 2016_08_25
                            % directory

params.pixelDim = .006;     % pixel width and height
params.b = 143.251;         % might be slightly inaccurate, may want to measure again.
params.b = 136.251;

fl_b = 989.31982*.006;       % from calibration done on 2016/7/16
fl_f = 1307.53356*.006;      % from calibration done on 2016/7/16


params.fl_f = fl_f;          % These come from the camera calibration
params.fl_b = fl_b;
params.alpha0 = 0.01;
params.alpha1 = 0.01;
params.iterations0 = 1;    
params.iterations1 = 1; 
params.lambda0 = 8e10;
params.lambda1 = 1e8;
params.limitLo = 200;  % pixels that RMS error is taken over e.g. 1:limitLo
params.limitHi = 200;
params.startSeq = 1;
params.deltaX = 1.25;
params.deltaZ = 5;
params.dataSet = 'X = 10; Z = 1.25';
rayAngle = 0;
saveOn = 0;     % save the flow plot


radial2XYdriver;    % Converts the flow field to a matrix of radial lines. 361X320
                    % don't need to run every time, it leaves its data on
                    % the workspace


%figure
%display horizontal line
%plot(rayOut1_f(1,:))
%hold all
%plot(rayOut1_b(1,:))

for i = 1:length(rayOut1_f)
    [z0_est(i,:), deltaX] = initialEstimate(rayOut1_f(i,:)*params.pixelDim, rayOut1_b(i,:)*params.pixelDim, params);
    for j = 1:length(z0_est(i,:))
        if z0_est(i,j) > 3000
            z0_est(i,j) = 3000;
        end
        
        if z0_est(i,j) < 600
            z0_est(i,j) = 600;
        end
    end
end

disp(strcat('deltaX:',num2str(deltaX)))

iterations = 25;
h = waitbar(0, 'Descending the gradient')
for j = 1:iterations
    for i = 1
        [z0_est(i,:), rms_flow_error(i)] = gradientDescentGraphics(rayOut1_f(i,:)*params.pixelDim, rayOut1_b(i,:)*params.pixelDim, z0_est(i,:), params);

        for k = 1:length(z0_est(i,:))
            if z0_est(i,k) > 3000
                z0_est(i,k) = 3000;
            end

            if z0_est(i,k) < 600
                z0_est(i,k) = 600;
            end
        end
    end
    waitbar(j/iterations)
end

disp(strcat('RMS flow error:',num2str(rms_flow_error(1))))


toc
%[z0_est, out] = imr1(rayOut1_f(1,:)*params.pixelDim, rayOut1_b(1,:)*params.pixelDim, params );


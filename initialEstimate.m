function [ z0_est, deltaX0 ] = initialEstimate(w_f0, w_b0, params)
% This version implements c' correctly and was used to create the plots for
% my dissertation paper for real data.  It is called by
% driverForPaperPlots and is in the October 24, 2015 experiments directory.

% Version: 10/24/2014

    % get the flow along the radial line given by ray angle
    %w_f0 = front flow along radial line at time 0
    %w_f1 = front flow along radial line at time 1
    %w_b0 = back flow along radial line at time 0
    %w_b1 = back flow along radial line at time 1
    %[w_f0, w_b0, filename ] = extractRay( uv_fm, uv_b, startSeq, rayAngle, saveOn );
    %[w_f1, w_b1, filename ] = extractRay( uv_fm, uv_b, startSeq+1, rayAngle, saveOn );
    
    columns = length(w_f0);
    kernelWidthF = 6;       % for front camera
    kernelWidthB = 6;       % for back camera

    u = 0:1:columns-1;
    b = params.b;               %base line
    fl_f = [ params.fl_f, params.fl_f  ];  % for front camera use y
    fl_b = [ params.fl_b, params.fl_b   ];   % for back camera use x
    
    % Add padding of one smoothing kernel width
    w_f0 = [ones(1,kernelWidthF)*w_f0(1),w_f0,ones(1,kernelWidthF)*w_f0(end)];
    w_b0 = [ones(1,kernelWidthB)*w_b0(1),w_b0,ones(1,kernelWidthB)*w_b0(end)];
    
    %smooth
%     w_f0=conv(w_f0,kernel_F,'same'); 
%     w_b0=conv(w_b0,kernel_B,'same'); 
    
    %remove padding
    w_f0 = w_f0(kernelWidthF+1:end-kernelWidthF);
    w_b0 = w_b0(kernelWidthB+1:end-kernelWidthB);
    
    % generate initial z estimate from flow ratio at center pixel
    z0_est(1) = b/((w_f0(1)/w_b0(1))*fl_b(1)/fl_f(2)-1);                    % this is off by deltaZ because this is where pixel ends up (off axis)
    deltaX0 = z0_est(1)*w_f0(1)/fl_f(2);
    z0_est = fl_f(2)*deltaX0./w_f0;
end


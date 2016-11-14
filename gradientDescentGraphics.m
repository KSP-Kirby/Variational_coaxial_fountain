function [z0_est, rms_flow_error] = gradientDescentGraphics(w_f0, w_b0, z0_est, params )
% This version implements c' correctly and was used to create the plots for
% my dissertation paper for real data.  It is called by
% driverForPaperPlots and is in the October 24, 2015 experiments directory.

% Version: 10/24/2014

    saveOn = 0;

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
    m0_k = (z0_est./(z0_est+b))*fl_b(1)/fl_f(2);
    
    c0 = 1; % because first flow image doesn't contain any Z
    
    rms1_min = inf;
    rms1_inner_min = inf;
    flow_min = inf;
    
    for i = 1:columns
        % find flow in back camera at i minus hk(i)

        % See page 53 of lab book for details
        % optimization:
        % (m*frontFlow-c*backFlow)
        % u0_um =   backFlow interprolated onto grid on frontFlow based
        %           on current value of m.  
        try
            % this makes sure that m0_k*u is monitonically increasing,
            % make need to add something to make sure it isn't flat
%                 if i > 1
%                     if m0_k(i)*u(i) < m0_k(i-1)*u(i-1)
%                         m0_k(i) = m0_k(i-1)*u(i-1)/u(i);
%                     end
%                     if m1_k(i)*u(i) < m1_k(i-1)*u(i-1)
%                         m1_k(i) = m1_k(i-1)*u(i-1)/u(i);
%                     end
%                 end
            w0_um(i) = interpolateY(w_b0, u(i)*m0_k(i)+1);   % find the backflow at u*m, the plus 1 is because the pixel at 0 is in array cell 1
           % w1_um(i) = interpolateY(w_b1, u(i)*m1_k(i)+1);   % find the backflow at u*m    
        catch
            disp(strcat('Interpolate failed at i=',num2str(i)))
            pause;
        end            
    end
        I0z = m0_k.*w_f0-c0.*w0_um;                   % this is the error that I'm trying to minimize

        dz_m0_k = (fl_b(1)/fl_f(2))*(b./((z0_est+b).*(z0_est+b)));
        t01 = dz_m0_k.*w_f0*params.pixelDim;
        t02 = (m0_k.*w_f0./z0_est)*params.pixelDim;
        t03 = c0.*w0_um.*dz_m0_k.*u*params.pixelDim*params.pixelDim./z0_est;

        I0zx = -t01 + t02 - t03;  

        % find laplacian of z
        z0_estP = [z0_est(3),z0_est(2),z0_est,z0_est(end-2),z0_est(end-3)];  % pad
        dxx_z0 = conv(z0_estP,0.5*[1 -2 1],'same');                          % 2nd derivative
        dxx_z0 = dxx_z0(3:end-2);                                           % remove padding

        z0_est = z0_est - params.lambda0*I0z.*I0zx + params.alpha0^2*dxx_z0;

        %update m
        m0_k = (z0_est./(z0_est+b))*fl_b(1)/fl_f(2);
        c0 = 1;

%             rms0_z = sqrt(mean((z0_est-z_f0).*conj(z0_est-z_f0)));
%             rms0_z_percent = rms0_z*100/mean(z_f0);
        rms_flow_error = sqrt(mean((I0z).*conj(I0z)));

%             subplot(2,3,1)
%             plot(u, w0_um./m0_k)
%             hold all
%             plot(u, w_f0)
%             hold off
%             title({'Shifted Wb vs. Wf: t = 0',strcat('Iterations:',num2str(j),' of:',num2str(params.iterations))})
%             legend('Wb', 'Wf') 
        %axis([0,240,10,20])

        subplot(2,3,1)
        plot(u, w0_um./m0_k)
        hold all
        plot(u, w_f0)
        hold off
        title({'Flow Matching',strcat('Iterations:',num2str(j),' of:',num2str(params.iterations0))})
        legend('wb', 'wf')  
        %axis([0,400,.2,1.2])


        subplot(2,3,2)
        plot(I0z)
        %hold all
        %plot(w_f1)
        %hold off
        %title({'I0z',strcat('RMS Flow Error:',num2str(rms_flow_error),' pixels')})
        title({'I0z'})
        %legend('Wb', 'Wf') 
        %axis([0,240,10,20])

%             subplot(2,3,3)
%             plot(I0z)
%             axis([0,400,-.02, .02])
%             title('Flow Error t = 0') 
%             ylabel('Pixels')
%             xlabel('Pixels from center')

        subplot(2,3,4)
        plot(-params.lambda0*I0z.*(-t01))
        hold all
        plot(- params.lambda0*I0z.*(t02))
        plot(- params.lambda0*I0z.*(-t03))
        plot(params.alpha0^2*dxx_z0)
        title('Components of EL')
        legend('T1','T2','T3','Smooth')
        hold off

        subplot(2,3,3)
        plot(m0_k)
        %axis([0,400,-.02,.02])
        title({'m';strcat('Alpha:',num2str(params.alpha0),' lambda:',num2str(params.lambda0))}) 
        %ylabel('Pixels')
        %xlabel('Pixels from center')

%             subplot(2,3,5)
%             plot(z0_est)
%             hold all
%             plot(z_f0)
%             hold off
%             title({'Z at t=0';strcat('RMS Error: ',num2str(rms0_z_percent),'%')})
%             %axis([0,240,0,1400])

        subplot(2,3,6)
        plot(z0_est)
%             hold all
%             plot(z_f0)
%             hold off
        %title({'Z at t=1';strcat('RMS Error: ',num2str(rms1_min),'%; j=',num2str(rms1_itr))})
        %title({'Z0 Estimate vs. Z0 Actual';strcat('RMS Error: ',num2str(rms0_z_percent),'%')})
        title({'Z0 Estimate'})
        %axis([0,240,0,1400])

        subplot(2,3,5)
        plot(params.lambda0*I0z.*I0zx + params.alpha0^2*dxx_z0)
        %title({'Z at t=1';strcat('RMS Inner Error: ',num2str(rms0_inner_min),'% j=',num2str(rms0_itr_inner))})
        title({'Gradient Descent Update'})

    %pause
    out.pix = flow_min;
    %out.pixItr = flow_itr;
    out.error = rms1_min;
    %out.errorItr = rms1_itr;
    out.errorIn = rms1_inner_min;
    %out.errorInItr = rms1_itr_inner;
    
end








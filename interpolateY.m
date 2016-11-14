function y = interpolateY(XYdata, x)

    try
        if x - floor(x) == 0
            y = XYdata(x);
        elseif x > length(XYdata)
            y = XYdata(end);
        else 
            y=(XYdata(ceil(x))-XYdata(floor(x)))*(x-floor(x))/(ceil(x)-floor(x))+XYdata(floor(x)); 
        end
    catch err
        disp(err.message)
    end
end


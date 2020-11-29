function [xr, yr] = randWithinCircle(x,y,radius,n)
[xr,yr] = createTooMuchRandomSamples(radius,n);
if length(xr) < n
    [xr2,yr2] = createTooMuchRandomSamples(radius,n);
    xr = [xr; xr2];
    yr = [yr; yr2];
end
xr = x + xr(1:n);
yr = y + yr(1:n);

    function [xr,yr] = createTooMuchRandomSamples(radius,n)
        xr = randWithinBounds(-radius,radius,2*n,1);
        yr = randWithinBounds(-radius,radius,2*n,1);
        idx2Remove = sqrt(xr.^2+yr.^2) > radius;
        xr(idx2Remove) = [];
        yr(idx2Remove) = [];
    end
end

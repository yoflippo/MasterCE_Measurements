function value = addGaussianVariationToValue(value,divfactor)
if not(exist('divfactor','var'))
    divfactor = 1;
end
value = value + (value * (randn/divfactor));
end
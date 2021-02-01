function [outsignal, outvar] = addVarianceToSignal(signal, var)
noise = randn(size(signal))*sqrt(var);
outsignal = signal + noise;
outvar = var;
end
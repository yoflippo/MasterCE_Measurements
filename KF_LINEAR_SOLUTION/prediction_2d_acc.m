function [X, P] = prediction_2d(X, P, Q, F)
X = F*X;
P = F*P*F' + Q;
end
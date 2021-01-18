function [X, P] = init_kalman_2d_acc(y)
X(1:2) = y(1:2);
X(3) = 0; 
X(4:5) = y(3:4);
X(6) = 0;
P = eye(numel(X)).*ones(1,numel(X))*5;
X = X';
end
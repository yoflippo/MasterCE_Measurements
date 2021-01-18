function [X, P] = update_2d_acc(X, P, y, R, H)
Inn = y - H*X;
S = H*P*H' + R;
K = P*H'*inv(S);

X = X + K*Inn;
% P = P - K*H*P;
%% joseph equation: for non-optimal Kalman Gain
A = eye(size(P))-K*H;
P = A*P*A' + K*R*K'; 
end
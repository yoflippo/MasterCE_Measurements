function [x, P, K, Pp] = rts_smooth(Xs, Ps, F, Q)
x = Xs;
P = Ps;
Pp = Ps;
for k = length(Xs)-1:-1:1
    Pp(k).M = F * P(k).M * F' + Q;
    K(k).M = P(k).M * F' * inv(Pp(k).M);
    x(k,:) = x(k,:) + (K(k).M * (x(k+1,:) - (F*x(k,:)')')')';
    P(k).M = P(k).M + (K(k).M * (P(k+1).M - Pp(k).M) * K(k).M');
end
end
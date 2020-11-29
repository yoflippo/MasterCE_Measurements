function r = randWithinBounds(lb,ub,r,c)
r = (ub-lb).*rand(r,c) + lb;
end
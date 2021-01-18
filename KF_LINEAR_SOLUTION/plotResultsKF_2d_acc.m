function plotResultsKF_2d_acc(t,clean,signals,X_arr,velocity,add2title)
if not(exist('add2title','var'))
    add2title = '';
else
    add2title = [add2title ': '];
end

subplot(3,2,[1 2]);
plot(signals(1).sig.x, signals(1).sig.y,'r', 'LineWidth', 2,'LineStyle','--','DisplayName','disturbed signal');hold on;
plot(clean.position.x, clean.position.y,'g', 'LineWidth', 2,'DisplayName','clean signal');
plot(X_arr(:, 1), X_arr(:, 4),'Color',[0 0 1],'LineWidth', 2,'DisplayName','KF result');
grid on; grid minor; legend
percentageImprovement = (rmse(signals(1).sig.x-clean.position.x)+rmse(signals(1).sig.y-clean.position.y))/ ...
    (rmse(X_arr(:,1)-clean.position.x)+rmse(X_arr(:,4)-clean.position.y));
kfImprovement = num2str(round(rmse(X_arr(:,1)-clean.position.x) + rmse(X_arr(:,4)-clean.position.y),3));
title([add2title  ': xy, RMSE improvement '  num2str(round(percentageImprovement,3)) ' KF rmse: ' kfImprovement])
axis equal;

subplot(3,2,3);
plot(t, signals(1).sig.x,'r','LineWidth', 2,'DisplayName','disturbed x','LineStyle','--'); hold on;
plot(t, clean(1).position.x,'g','LineWidth', 2,'DisplayName','clean x'); hold on;
plot(t,  X_arr(:, 1),'Color',[0 0 1], 'LineWidth', 2,'DisplayName','KF result x');
grid on; grid minor; legend
percentageImprovement = rmse_improvement(clean.position.x,signals(1).sig.x,X_arr(:,1));
title([add2title ': x, RMSE improvement ' num2str(round(percentageImprovement,3))])

subplot(3,2,4);
plot(t, signals(1).sig.y,'r','LineWidth', 2,'LineStyle','--','DisplayName','disturbed y'); hold on;
plot(t, clean(1).position.y,'g','LineWidth', 2,'DisplayName','clean y'); hold on;
plot(t, X_arr(:, 4),'Color',[0 0 1], 'LineWidth', 2,'DisplayName','KF result y');
grid on; grid minor; legend
percentageImprovement = rmse_improvement(clean.position.y,signals(1).sig.y,X_arr(:,4));
title([add2title ': y, RMSE improvement ' num2str(round(percentageImprovement,3))])

subplot(3,2,5);
plot(t, velocity.sig.x,'r','LineWidth', 2,'DisplayName','disturbed vel x','LineStyle','--'); hold on;
plot(t, clean.velocity.x,'g','LineWidth', 2,'DisplayName','clean velx'); hold on;
plot(t,  X_arr(:, 2),'Color',[0 0 1], 'LineWidth', 2,'DisplayName','KF result velx');
grid on; grid minor; legend
percentageImprovement = rmse_improvement(clean.velocity.x,velocity.sig.x,X_arr(:,2));
title([add2title ': x vel, RMSE improvement ' num2str(round(percentageImprovement,3))])

subplot(3,2,6);
plot(t, velocity.sig.y,'r','LineWidth', 2,'DisplayName','disturbed vel y','LineStyle','--'); hold on;
plot(t, clean.velocity.y,'g','LineWidth', 2,'DisplayName','clean vel y'); hold on;
plot(t,  X_arr(:, 5),'Color',[0 0 1], 'LineWidth', 2,'DisplayName','KF result vel y');
grid on; grid minor; legend
percentageImprovement = rmse_improvement(clean.velocity.y,velocity.sig.y,X_arr(:,5));
title([add2title ': y vel, RMSE improvement ' num2str(round(percentageImprovement,3))])
end
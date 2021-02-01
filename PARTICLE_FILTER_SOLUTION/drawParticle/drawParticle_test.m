function drawParticle_test()
close all; 
figure; plot(10*randn(1,1000),10*randn(1,1000)); hold on;
% drawParticle(1,1,180,'red')
hold on;
% drawParticle(-3,4,70,'red')
drawParticle(0,0,45,'red')
drawParticle(50,50,270,'g')
axis equal
end


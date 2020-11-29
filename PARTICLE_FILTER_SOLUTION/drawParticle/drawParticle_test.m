function drawParticle_test()
close all; 
figure; plot(randn(1,1000),randn(1,1000)); hold on;
drawParticle(1,1,180,'red')
hold on;
drawParticle(-3,4,70,'red')
axis equal
end


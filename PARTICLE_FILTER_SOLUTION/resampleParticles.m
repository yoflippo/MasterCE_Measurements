function particles = resampleParticles(particles)
numberOfParticles = length(particles.x);
weightsTotal = getTotalWeight(particles);
figure; plot(weightsTotal);

    function weightsTotal = getTotalWeight(particles)
            weightsTotal = particles.weights.angularRate + ...
                particles.weights.range + ...
                particles.weights.velocity;
            weightsTotal = normalize_pdf(weightsTotal);
    end
% weightsCumSum = cumsum(weightsTotal);

[sortedWeights,idx] = sort(weightsTotal,'ascend');
figure; plot(sortedWeights);
N = round(numberOfParticles/50);
segments = 1:N:numberOfParticles;

indicesToRemove = [];
for i = 1:length(segments)-1
   randIdx = randi(N,1)-1; 
   indicesToRemove = [indicesToRemove segments(i)+randIdx];
end
% def systematic_resample(weights):
%     N = len(weights)
% 
%     # make N subdivisions, choose positions 
%     # with a consistent random offset
%     positions = (np.arange(N) + random()) / N
% 
%     indexes = np.zeros(N, 'i')
%     cumulative_sum = np.cumsum(weights)
%     i, j = 0, 0
%     while i < N:
%         if positions[i] < cumulative_sum[j]:
%             indexes[i] = j
%             i += 1
%         else:
%             j += 1
%     return indexes
end
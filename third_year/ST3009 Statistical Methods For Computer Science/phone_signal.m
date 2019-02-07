location_prob = [0.05, 0.1, 0.05, 0.05;
                0.05, 0.1, 0.05, 0.05;
                0.05, 0.05, 0.1, 0.05;
                0.05, 0.05, 0.1, 0.05];
signal_location_prob = [0.75, 0.95, 0.75, 0.005;
                        0.05, 0.75, 0.95, 0.75;
                        0.01, 0.05, 0.75, 0.95;
                        0.01, 0.01, 0.05, 0.75];
                    
location_signal_prob = zeros(4, 4);          
                    
signal_prob = 0;
for i = 1:numel(location_prob)
    signal_prob =  signal_prob + location_prob(i) * signal_location_prob(i);
end

for i = 1:numel(location_signal_prob)
   location_signal_prob(i) = signal_location_prob(i)*location_prob(i) / signal_prob;
end

disp(location_signal_prob);
%Probability of being in each location, same as the left grid
location_prob = [0.05, 0.1, 0.05, 0.05;
                0.05, 0.1, 0.05, 0.05;
                0.05, 0.05, 0.1, 0.05;
                0.05, 0.05, 0.1, 0.05];
            
%Probability of having signal, given our position, same as the right grid            
signal_location_prob = [0.75, 0.95, 0.75, 0.005; 
                        0.05, 0.75, 0.95, 0.75;         
                        0.01, 0.05, 0.75, 0.95;
                        0.01, 0.01, 0.05, 0.75]; 
                    
%Instantiate a all zero matrix for the probability of being in a location given having signal                    
location_signal_prob = zeros(4, 4);          
                    
%Computing the probability of having signal using marginalisation
signal_prob = 0;
for i = 1:numel(location_prob)
    signal_prob =  signal_prob + location_prob(i) * signal_location_prob(i);
end

%Computing the probabilities of being in a location given having signal
%using Bayes rule:
%
%P(Location|Observe two bars of signal) =
%P(Signal|Location)P(Location)/P(Signal)
for i = 1:numel(location_signal_prob)
   location_signal_prob(i) = signal_location_prob(i)*location_prob(i) / signal_prob;
end

disp(location_signal_prob);
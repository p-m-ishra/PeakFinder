data = csvread("c1278-rest-pump-on.csv");
REQUIREMENTFORLOCALMAX = 0.00059;
USERESTIMATEFORMAXIMA = 21;

[peakVal, peakLoc] = findpeaks(data,"DoubleSided", "MinPeakDistance", 3);
LocalMaxInterval = [];
localmaxintervalcount = 1;
for i = 1:length(peakLoc)
  if(peakVal(i) > REQUIREMENTFORLOCALMAX)
    LocalMaxInterval(localmaxintervalcount) = peakLoc(i);
    localmaxintervalcount = localmaxintervalcount + 1;
  end
end
interval = [];
index = 1;
LocalMinima = [];
LocalMaxima = [];
LocalMaximaPeakLoc = [];
LocalMinimaPeakLoc = [];
localmaximacount = 1;
localminimacount =1;
iterator = 1;
lowerbound = 0;
upperbound = 0;
while(!(upperbound>length(data)) && !(iterator>length(LocalMaxInterval)))
  lowerbound = LocalMaxInterval(iterator)-0; # CHANGE to -10 IF LOCAL MINIMA OCCURS BEFORE LOCAL MAXIMA
  upperbound = LocalMaxInterval(iterator) +10;
  if(upperbound >length(data))
    upperbound = length(data);
  end
  fprintf("lowerbound: %d\t upperbound: %d\n", lowerbound, upperbound);
  for i = lowerbound:upperbound
      interval(index) = data(i);
      index = index +1;
  end
  LocalMinima(localminimacount) = min(interval);
  LocalMaxima(localmaximacount) = max(interval);
  for i = lowerbound: upperbound
    if(data(i) == LocalMinima(localminimacount))
      LocalMinimaPeakLoc(localminimacount) = i;
    elseif(data(i) == LocalMaxima(localmaximacount))
      LocalMaximaPeakLoc(localmaximacount) = i;
    end
  end
  localmaximacount = localmaximacount + 1;
  localminimacount = localminimacount + 1;

  index = 1;
  interval = [];
  iterator = iterator +1;
endwhile
disp("RESULTS\n\n");
for i = 1: length(LocalMaxima)
  fprintf("Local Maxima Number: %i\t\tLocal Maxima Value: %d\t\t Local Maxima Pos: %d\n", i, LocalMaxima(i), LocalMaximaPeakLoc(i));
end  
fprintf("Local Maxima Average: %d\n", mean(LocalMaxima));
fprintf("Local Maxima Standard Deviation: %d\n\n", std(LocalMaxima));

for i = 1: length(LocalMinima)
  fprintf("Local Minima Number: %i\t\tLocal Minima Value: %d\t\t Local Minima Pos: %d\n", i, LocalMinima(i), LocalMinimaPeakLoc(i));
end  
fprintf("Local Minima Average: %d\n", mean(LocalMinima));
fprintf("Local Minima Standard Deviation: %d\n\n", std(LocalMinima));
if(USERESTIMATEFORMAXIMA == length(LocalMaxima))
  fprintf("Software estimate was CORRECT according to the user estimate\n")
else
  fprintf("Software estimate was INCORRECT according to the user estimate, please manually check the data.\n")
end
plot(data);
hold on
for i = 1:length(LocalMinima)
  scatter(LocalMinimaPeakLoc(i), LocalMinima(i), 280);
end
for i =1:length(LocalMaxima)
  scatter(LocalMaximaPeakLoc(i), LocalMaxima(i), 280);
end
hold off
%}


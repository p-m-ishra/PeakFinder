REQUIREMENTFORLOCALMAX = 0.0004; #how high must a peak be to be a local max
USERESTIMATEFORMAXIMA = 21; #how many maxima (software check)
INTERVALCHECKRIGHT = 20; #how far right of the maxima should the algorithm check for minima
INTERVALCHECKLEFT = 0; #how far left to check(usually 0)
HOWFARAPART = 65;
FILENAMEP0 = "c1278P0.csv";
FILENAMEP1 = "c1278P1.csv";
FILENAMEOFFP0 = "c1278P0off.csv";
FILENAMEOFFP1 = "c1278P1off.csv";

dataP0 = csvread(FILENAMEP0);
dataP1 = csvread(FILENAMEP1);
dataOffP0 = csvread(FILENAMEOFFP0);
dataOffP1 = csvread(FILENAMEOFFP1);
dataOffP0 = sort(dataOffP0);
dataOffP1 = sort(dataOffP1);
dataOffFilteredP0 = [];
dataOffFilteredP1 = [];

for i = 100:(length(dataOffP0)-100)
  dataOffFilteredP0(i-99) = dataOffP0(i);
end
dataOffFilteredAvgP0 = mean(dataOffFilteredP0);
for i = 1:length(dataP0)
    dataP0(i) = dataP0(i) - dataOffFilteredAvgP0;
end

for i = 100:(length(dataOffP1) - 100)
  dataOffFilteredP1(i-99) = dataOffP1(i);
end
dataOffFilteredAvgP1 = mean(dataOffFilteredP1);
for i = 1:length(dataP1)
    dataP1(i) = dataP1(i) - dataOffFilteredAvgP1;
end

[peakVal, peakLoc] = findpeaks(dataP0,"DoubleSided", "MinPeakDistance", 3);
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
while(!(upperbound>length(dataP0)) && !(iterator>length(LocalMaxInterval)))
  lowerbound = LocalMaxInterval(iterator)-INTERVALCHECKLEFT;
  upperbound = LocalMaxInterval(iterator) +INTERVALCHECKRIGHT;
  if(upperbound >length(dataP0))
    upperbound = length(dataP0);
  end
  fprintf("lowerbound: %d\t upperbound: %d\n", lowerbound, upperbound);
  for i = lowerbound:upperbound
      interval(index) = dataP0(i);
      index = index +1;
  end
  TempMinimum = min(interval);
  TempMaximum = max(interval);
  for i = lowerbound: upperbound
    if(dataP0(i) == TempMinimum)
      if(localminimacount > 1)
        if(abs(i-LocalMinimaPeakLoc(localminimacount-1)) > HOWFARAPART)
          LocalMinima(localminimacount) = min(interval);
          LocalMinimaPeakLoc(localminimacount) = i;
          localminimacount = localminimacount + 1;
        end
      else
        LocalMinima(localminimacount) = min(interval);
        LocalMinimaPeakLoc(localminimacount) = i;
        localminimacount = localminimacount +1;
      end
    elseif(dataP0(i) == TempMaximum)
      if(localmaximacount > 1)
        if(abs(i - LocalMaximaPeakLoc(localmaximacount-1)) > HOWFARAPART)
          LocalMaxima(localmaximacount) = max(interval);
          LocalMaximaPeakLoc(localmaximacount) = i;
          localmaximacount = localmaximacount + 1;
        end
      else
        LocalMaxima(localmaximacount) = max(interval);
        LocalMaximaPeakLoc(localmaximacount) = i;
        localmaximacount = localmaximacount + 1;
      end
    end
  end

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
plot(dataP0);
hold on
for i = 1:length(LocalMinima)
  scatter(LocalMinimaPeakLoc(i), LocalMinima(i), 280);
end
for i =1:length(LocalMaxima)
  scatter(LocalMaximaPeakLoc(i), LocalMaxima(i), 280);
end
hold off  
LocalMinimaStats = [mean(LocalMinima) std(LocalMinima)];
LocalMaximaStats = [mean(LocalMaxima) std(LocalMaxima)];

dlmwrite("Results.csv", "LocalMinimaList, Avg,and Standard Deviation <-- in that order");
dlmwrite("Results.csv", LocalMinima, '-append');
dlmwrite("Results.csv", LocalMinimaStats, '-append');
dlmwrite("Results.csv", "LocalMaximaList, Avg,and Standard Deviation <-- in that order", '-append');
dlmwrite("Results.csv", LocalMaxima, '-append');
dlmwrite("Results.csv", LocalMaximaStats, '-append');

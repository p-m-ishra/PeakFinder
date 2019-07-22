REQUIREMENTFORLOCALMAX = 20; #how high must a peak be to be a local max
USERESTIMATEFORMAXIMA = 20; #how many maxima (software check)
INTERVALTOCHECKFORMINIMA = 10; #how far right of the maxima should the algorithm check for minima
FILENAMEOFF = "c1278-rest-pump-on.csv";
FILENAMEP0 = "exerciseP0.csv";
FILENAMEP1 = "exerciseP1.csv"
dataP1 = csvread(FILENAMEP1);
dataP0 = csvread(FILENAMEP0);
dataOff = csvread(FILENAMEOFF);
dataOff = sort(dataOff);
finalData = [];
for i = 100:(length(dataOff)-100)
  dataOffFiltered(i-99) = dataOff(i);
end
dataOffFilteredAvg = mean(dataOffFiltered);
for i = 1:length(dataP1)
    dataP1(i) = dataP1(i) - dataOffFilteredAvg;
end
for i = 1:length(dataP0)
    dataP0(i) = dataP0(i) - dataOffFilteredAvg;
end
if(mean(dataP0) > mean(dataP1))
  for i = 1:length(dataP0)
    finalData(i) = dataP0(i) - dataP1(i);
  end
else
  for i = 1:length(dataP0)
    finalData(i) = dataP1(i) - dataP0(i);
  end
end
[peakVal, peakLoc] = findpeaks(finalData,"DoubleSided", "MinPeakDistance", 3);
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
while(!(upperbound>length(finalData)) && !(iterator>length(LocalMaxInterval)))
  lowerbound = LocalMaxInterval(iterator)-0;
  upperbound = LocalMaxInterval(iterator) +INTERVALTOCHECKFORMINIMA;
  if(upperbound >length(finalData))
    upperbound = length(finalData);
  end
  fprintf("lowerbound: %d\t upperbound: %d\n", lowerbound, upperbound);
  for i = lowerbound:upperbound
      interval(index) = finalData(i);
      index = index +1;
  end
  TempMinimum = min(interval);
  TempMaximum = max(interval);
  for i = lowerbound: upperbound
    if(finalData(i) == TempMinimum)
      if(localminimacount > 1)
        if(abs(i-LocalMinimaPeakLoc(localminimacount-1)) > 60)
          LocalMinima(localminimacount) = min(interval);
          LocalMinimaPeakLoc(localminimacount) = i;
          localminimacount = localminimacount + 1;
        end
      else
        LocalMinima(localminimacount) = min(interval);
        LocalMinimaPeakLoc(localminimacount) = i;
        localminimacount = localminimacount +1;
      end
    elseif(finalData(i) == TempMaximum)
      if(localmaximacount > 1)
        if(abs(i - LocalMaximaPeakLoc(localmaximacount-1)) > 60)
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
plot(finalData);
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

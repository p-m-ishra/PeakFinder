  #Use Figure 1 for P0 and Figure 2 for P1
  fflush(stdout);
  
  #Follow along in the comments for a test run
  disp("Press Ctrl-C to Quit and then type PeakFinder and press enter to restart\n");
  FILENAMEON = input("Type exact filename for pump on: ", "s"); #c1278 rest pump on.xlsx
  FILENAMEOFF = input("Type exact filename for pump off: ", "s");#c1278 rest pump off.xlsx
  LASTROWNUMBER = input("Last row number in pump on: "); #1421
  LASTROWNUMBEROFF = input("Last row number in pump off: "); #1271

  REQUIREMENTFORLOCALMAXP0 = input("Requirement for Local Max P0 (how high peak must be to be local max): "); #0.0004
  USERESTIMATEFORMAXIMAP0 = input("How many maxima are there (software check) in P0: "); #20
  INTERVALCHECKRIGHTP0 = input("How far right of maxima should algorithm check for minima in P0: "); #15
  INTERVALCHECKLEFTP0 = 0;
  HOWFARAPARTP0 = input("How far apart are maxima approximately? (Round down) in P0: "); #65
  
  REQUIREMENTFORLOCALMAXP1 = input("Requirement for Local Max P1 (how high peak must be to be local max): "); #0.00027
  USERESTIMATEFORMAXIMAP1 = input("How many maxima are there in P1(software check): "); #20
  INTERVALCHECKRIGHTP1 = input("How far right of maxima should algorithm check for minima in P1: "); #15
  INTERVALCHECKLEFTP1 = 0;
  HOWFARAPARTP1 = input("How far apart are maxima approximately in P1? (Round down): "); #65

#^^^^^^ User Input ^^^^^^

#dataP0 = csvread(FILENAMEP0);
#dataP1 = csvread(FILENAMEP1);
#dataOffP0 = csvread(FILENAMEOFFP0);
#dataOffP1 = csvread(FILENAMEOFFP1);
range1 = strcat("A2:A",mat2str(LASTROWNUMBER));  
range2 = strcat("B2:B",mat2str(LASTROWNUMBER));
range3 = strcat("A2:A",mat2str(LASTROWNUMBEROFF));
range4 = strcat("B2:B",mat2str(LASTROWNUMBEROFF));
dataP0 = xlsread(FILENAMEON, 'sheet1', range1);
dataP1 = xlsread(FILENAMEON, 'sheet1', range2);
dataOffP0 = xlsread(FILENAMEOFF, 'sheet1',  range3);
dataOffP1 = xlsread(FILENAMEOFF, 'sheet1', range4);

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

    function[Minima,Maxima] = ExtremaFinder(dataa, reqlocalmax, userestimatemaxima,intervalcheckright, intervalcheckleft, howfarapart)
      [peakVal, peakLoc] = findpeaks(dataa,"DoubleSided", "MinPeakDistance", 3);
      LocalMaxInterval = [];
      localmaxintervalcount = 1;
      for i = 1:length(peakLoc)
        if(peakVal(i) > reqlocalmax)
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
      while(!(upperbound>length(dataa)) && !(iterator>length(LocalMaxInterval)))
        lowerbound = LocalMaxInterval(iterator)-intervalcheckleft;
        upperbound = LocalMaxInterval(iterator) +intervalcheckright;
        if(upperbound >length(dataa))
          upperbound = length(dataa);
        end
        for i = lowerbound:upperbound
            interval(index) = dataa(i);
            index = index +1;
        end
        TempMinimum = min(interval);
        TempMaximum = max(interval);
        for i = lowerbound: upperbound
          if(dataa(i) == TempMinimum)
            if(localminimacount > 1)
              if(abs(i-LocalMinimaPeakLoc(localminimacount-1)) > howfarapart)
                LocalMinima(localminimacount) = min(interval);
                LocalMinimaPeakLoc(localminimacount) = i;
                localminimacount = localminimacount + 1;
              end
            else
              LocalMinima(localminimacount) = min(interval);
              LocalMinimaPeakLoc(localminimacount) = i;
              localminimacount = localminimacount +1;
            end
          elseif(dataa(i) == TempMaximum)
            if(localmaximacount > 1)
              if(abs(i - LocalMaximaPeakLoc(localmaximacount-1)) > howfarapart)
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
      Minima = LocalMinima;
      Maxima = LocalMaxima;
      plot(dataa);
      hold on
      for i = 1:length(LocalMinima)
        scatter(LocalMinimaPeakLoc(i), LocalMinima(i), 280);
      end
      for i =1:length(LocalMaxima)
        scatter(LocalMaximaPeakLoc(i), LocalMaxima(i), 280);
      end
      hold off
    end
figure(1);
[MinimaP0, MaximaP0] = ExtremaFinder(dataP0, REQUIREMENTFORLOCALMAXP0, USERESTIMATEFORMAXIMAP0, INTERVALCHECKRIGHTP0, INTERVALCHECKLEFTP0,HOWFARAPARTP0);
figure(2);
[MinimaP1, MaximaP1] = ExtremaFinder(dataP1, REQUIREMENTFORLOCALMAXP1, USERESTIMATEFORMAXIMAP1, INTERVALCHECKRIGHTP1, INTERVALCHECKLEFTP1, HOWFARAPARTP1);

FinalMinima = [];
FinalMaxima = [];
for i = 1:length(MinimaP0)
  FinalMinima(i) = abs(MinimaP1(i) - MinimaP0(i));
  FinalMaxima(i) = abs(MaximaP1(i) - MaximaP0(i));
endfor
FinalMinimaAvg = mean(FinalMinima);
FinalMaximaAvg = mean(FinalMaxima);
FinalMinimaStd = std(FinalMinima);
FinalMaximaStd = std(FinalMaxima);
disp("RESULTS: Mean subtracted from each data value and then Maxima and Minima of P0 and P1 subtracted\n");
disp("LOCAL MINIMA DIFFERENCES, avg, and stdev <-- in that order\n");
fprintf('%d\n', FinalMinima);
fprintf('%s\n%d\n', "Average", FinalMinimaAvg);
fprintf('%s\n%d\n', "Standard Deviation", FinalMinimaStd);
disp("LOCAL MAXIMA DIFFERENCES, avg, and stdev <-- in that order\n");
fprintf('%d\n', FinalMaxima);
fprintf('%s\n%d\n', "Average", FinalMaximaAvg);
fprintf('%s\n%d\n', "Standard Deviation", FinalMaximaStd);
if(USERESTIMATEFORMAXIMAP0 == length(FinalMaxima) && USERESTIMATEFORMAXIMAP1 == length(FinalMaxima))
  fprintf("\n\n%s\n", "CORRECT SOFTWARE\n");
else
  fprintf("\n\n%s\n", "INCORRECT SOFTWARE\n ");
end

dlmwrite("Results.csv", "LocalMinimaDifferences");
dlmwrite("Results.csv", FinalMinima, '-append');
dlmwrite("Results.csv", FinalMinimaAvg, '-append');
dlmwrite("Results.csv", FinalMinimaStd, '-append');
dlmwrite("Results.csv", "LocalMaximaDifferences", '-append');
dlmwrite("Results.csv", FinalMaxima, '-append');
dlmwrite("Results.csv", FinalMaximaAvg, '-append');
dlmwrite("Results.csv", FinalMaximaStd, '-append');

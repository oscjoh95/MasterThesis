%%
%Authors:
%Lucas Wass�nius
%Oscar Johansson
%
%Script for data analysis in positioning
%%

function analysisStationaryDualTag(measurements,truePos,trueOrientation,anchorPos)

    %Store first row as true position
    trueX = truePos(1);
    trueY = truePos(2);

    %Anchor positions[A0, A1, A2]
    anchorX = anchorPos(1,:);
    anchorY = anchorPos(2,:);

    %Fetch unfiltered measurements
    posFrontTag = measurements(:,1:2);
    posBackTag = measurements(:,3:4);

    %Fetch Filtered filtered measurements
    posFrontTagFiltered = measurements(:,5:6);
    posBackTagFiltered = measurements(:,7:8);

    %Timers
    cumTime = measurements(:,9)./1000;
    for i = 1 : length(cumTime)-1
        deltaTime(i) = cumTime(i+1)-cumTime(i);
    end

    %Orientation
    trueOrientationVec = trueOrientation.*ones(1,length(cumTime));
    
    orientation = atan2((posFrontTag(:,2)-posBackTag(:,2)),(posFrontTag(:,1)-posBackTag(:,1)));
    orientationFiltered = atan2((posFrontTagFiltered(:,2)-posBackTagFiltered(:,2)),(posFrontTagFiltered(:,1)-posBackTagFiltered(:,1)));
    
    %% Mean Error

    %Calculate mean positions
    meanX = mean(posFrontTag(:,1));
    meanY = mean(posFrontTag(:,2));
    meanXFiltered = mean(posFrontTagFiltered(:,1));
    meanYFiltered = mean(posFrontTagFiltered(:,2));
    meanOrient = mean(orientation);
    meanOrientFiltered = mean (orientationFiltered);

    %Errors between measured position and true position(and true orientation and calculated orientation)
    errorX = trueX - posFrontTag(:,1);
    errorY = trueY - posFrontTag(:,2);
    errorXFiltered = trueX - posFrontTagFiltered(:,1);
    errorYFiltered = trueY - posFrontTagFiltered(:,2);
    absoluteErrorOrient = abs(trueOrientation - orientation);
    absoluteErrorOrientFiltered = abs(trueOrientation - orientationFiltered);
    
    %Mean Errors X,Y
    meanErrorX = mean(errorX);
    meanErrorY = mean(errorY);
    meanErrorXFiltered = mean(errorXFiltered);
    meanErrorYFiltered = mean(errorYFiltered);
    
    %Mean Position Error
    meanPositionError = sqrt(meanErrorX.^2 + meanErrorY.^2);
    meanPositionErrorFiltered = sqrt(meanErrorXFiltered.^2 + meanErrorYFiltered.^2);
    
    %Distance Error between measured position and true position
    distanceError = sqrt(errorX.^2 + errorY.^2);
    distanceErrorFiltered = sqrt(errorXFiltered.^2 + errorYFiltered.^2);

    %Mean Error in distance and orientation
    meanDistanceError = mean(distanceError);
    meanDistanceErrorFiltered = mean(distanceErrorFiltered);
    meanOrientError = mean(absoluteErrorOrient);
    meanOrientErrorFiltered = mean(absoluteErrorOrientFiltered);
    
    %Standard Deviation in X/Y direction
    positionSTDX = sqrt(sum((posFrontTag(:,1)-meanX).^2)/(length(posFrontTag(:,1))-1));
    positionSTDY = sqrt(sum((posFrontTag(:,2)-meanY).^2)/(length(posFrontTag(:,2))-1));
    positionSTDXFiltered =sqrt(sum((posFrontTagFiltered(:,1)-meanXFiltered).^2)/(length(posFrontTagFiltered(:,1))-1));
    positionSTDYFiltered =sqrt(sum((posFrontTagFiltered(:,2)-meanYFiltered).^2)/(length(posFrontTagFiltered(:,2))-1));

    %Standard Deviation in distance
    positionSTD = sqrt(positionSTDX.^2 + positionSTDY.^2);
    positionSTDFiltered = sqrt(positionSTDXFiltered.^2 + positionSTDYFiltered.^2);

    %Standard Deviation in Orientation
    orientSTD = sqrt(sum((orientation-meanOrient).^2)/(length(orientation)-1));
    orientSTDFiltered = sqrt(sum((orientationFiltered-meanOrientFiltered).^2)/(length(orientationFiltered)-1));
    
    %MSE Distance
    pathMSE = sum(distanceError.^2)/length(distanceError);
    pathMSEFiltered = sum(distanceErrorFiltered.^2)/length(distanceErrorFiltered);
    
    %MSE Orientation
    orientMSE = sum(orientationError.^2)/length(orientationError);
    orientMSEFiltered = sum(orientationErrorFiltered.^2)/length(orientationErrorFiltered);
    
    %%Table of values
    ColumnNames = {'Mean Distance Error';'Mean Position Error';'STD Position';'MSE Distance';'Absolute Mean Orient. Error';'MSE Orient.'};
    Method = {'Unfiltered';'Filtered'};
    Mean_Distance_Error =[meanDistanceError;meanDistanceErrorFiltered];
    Mean_Position_Error =[meanPositionError;meanPositionErrorFiltered];
    STD = [positionSTD;positionSTDFiltered];
    MSE = [pathMSE;pathMSEFiltered];
    MSEOrient = [orientMSE;orientMSEFiltered];
    Abolute_Mean_Orient = [meanOrientError;meanOrientErrorFiltered];
    
    %STD_Orient = [orientSTD;orientSTDFiltered];
    
    T = table(Mean_Distance_Error,Mean_Position_Error,STD,MSE,Abolute_Mean_Orient,MSEOrient,'RowNames',Method);

    uitable('Data',T{:,:},'ColumnName',ColumnNames,...
        'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1],...
        'FontSize',16);



    set(gcf, 'Position',  [200, 1000, 600, 200])

     %%  Plotting Orientation
     
     orientationFig = figure();
     hold on;
     plot(cumTime,orientation,'color',[0 0 1])
     plot(cumTime,orientationFiltered,'color',[1 102/255 0])
     plot(cumTime,trueOrientationVec,'black')
     legend('Orientation ','Filtered Orientation','True Orientation');
     set(orientationFig, 'Position',  [200, 200, 600, 500]);
     set(orientationFig, 'Color',  [102/255 204/255 255/255], 'name', 'Orientation Plot');
     
     axis([-0.5 max(cumTime)+0.5 -pi-0.5 pi+0.5]);
     xlabel('Time[s]');
     ylabel('Orientation[rad]');
     yticks([-pi -pi/2 0 pi/2 pi]);
     yticklabels({'-\pi',join(['-\pi','/2']),'0',join(['\pi','/2']),'\pi'})
     
     
  %%  Plotting the stationary data
    figure();
    hold on;

    frontTagPlot = scatter(posFrontTag(:,1), posFrontTag(:,2),30,'filled');
    backTagPlot = scatter(posBackTag(:,1), posBackTag(:,2),30,'filled');
    frontTagFilteredPlot= scatter(posFrontTagFiltered(:,1), posFrontTagFiltered(:,2),30,'filled');
    backTagFilteredPlot= scatter(posBackTagFiltered(:,1), posBackTagFiltered(:,2),30,'filled');
    
    anchorPlot = scatter(anchorX, anchorY,60,'s');
    truePlot = scatter(trueX, trueY,20,'s');

    axis([-0.5 anchorX(2)+0.5 -0.5 anchorY(3)+0.5])
    
    
    frontTagPlot.MarkerFaceColor = [0 0 1];
    frontTagPlot.MarkerEdgeColor = [0 0 1];
    backTagPlot.MarkerFaceColor =  [0 102/255 1];
    backTagPlot.MarkerEdgeColor =  [0 102/255 1];
    
    frontTagFilteredPlot.MarkerFaceColor = [1 102/255 0];
    frontTagFilteredPlot.MarkerEdgeColor = [1 102/255 0];
    backTagFilteredPlot.MarkerFaceColor =  [1 153/255 1/255];
    backTagFilteredPlot.MarkerEdgeColor =  [1 102/255 1/255];
    
    anchorPlot.MarkerFaceColor = 'red';
    anchorPlot.MarkerEdgeColor = 'red';
    truePlot.MarkerFaceColor = 'black';
    truePlot.MarkerEdgeColor = 'black';

    
    set(gcf, 'Position',  [1000, 800, 1000, 500])
    set(gcf, 'Color',  [102/255 204/255 255/255], 'name', 'Live Graph')
    legend('Front Tag Positions','Back Tag Positions', 'Front Tag Filtered Positions','Back Tag Filtered Positions' , 'Anchor Positions','True Position');
    xlabel('x[m]');
    ylabel('y[m]');

 %%  Plotting the stationary data LIVE
    dataFig = figure();
    hold on;

    frontTagPlot = scatter(posFrontTag(1,1), posFrontTag(1,2),30,'filled');
    backTagPlot = scatter(posBackTag(1,1), posBackTag(1,1),30,'filled');
    frontTagFilteredPlot= scatter(posFrontTagFiltered(1,1), posFrontTagFiltered(1,2),30,'filled');
    backTagFilteredPlot= scatter(posBackTagFiltered(1,1), posBackTagFiltered(1,2),30,'filled');
    
    anchorPlot = scatter(anchorX, anchorY,60,'s');
    truePlot = scatter(trueX, trueY,20,'s');

    axis([-0.5 anchorX(2)+0.5 -0.5 anchorY(3)+0.5])

    frontTagPlot.MarkerFaceColor = [0 0 1];
    frontTagPlot.MarkerEdgeColor = [0 0 1];
    backTagPlot.MarkerFaceColor =  [0 102/255 1];
    backTagPlot.MarkerEdgeColor =  [0 102/255 1];
    
    frontTagFilteredPlot.MarkerFaceColor = [1 102/255 0];
    frontTagFilteredPlot.MarkerEdgeColor = [1 102/255 0];
    backTagFilteredPlot.MarkerFaceColor =  [1 153/255 1/255];
    backTagFilteredPlot.MarkerEdgeColor =  [1 102/255 1/255];
    
    anchorPlot.MarkerFaceColor = 'red';
    anchorPlot.MarkerEdgeColor = 'red';
    truePlot.MarkerFaceColor = 'black';
    truePlot.MarkerEdgeColor = 'black';

    
    set(gcf, 'Position',  [1000, 200, 1000, 500])
    set(gcf, 'Color',  [102/255 204/255 255/255], 'name', 'Live Graph')
    legend('Front Tag Positions','Back Tag Positions', 'Front Tag Filtered Positions','Back Tag Filtered Positions' , 'Anchor Positions','True Position');
    xlabel('x[m]');
    ylabel('y[m]');
    
    for i = 2:(length(deltaTime))
        if ~ishghandle(dataFig)
            break
        end
        set(frontTagPlot,'XData',posFrontTag(i,1),'YData',posFrontTag(i,2)) ;
        set(backTagPlot,'XData',posBackTag(i,1),'YData',posBackTag(i,2)) ;
        set(frontTagFilteredPlot,'XData',posFrontTagFiltered(i,1),'YData',posFrontTagFiltered(i,2));
        set(backTagFilteredPlot,'XData',posBackTagFiltered(i,1),'YData',posBackTagFiltered(i,2));
        drawnow
        pause(deltaTime(i))
    end
    
end


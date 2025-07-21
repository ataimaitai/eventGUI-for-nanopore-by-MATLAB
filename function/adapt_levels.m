%%  Non-public function used by event_detection.m

function event = adapt_levels(event, numberLevels, baseSign,i)
j=1;
 while(j<numberLevels+1)   
    if(abs(event.Levels(j,3)-mean(baseSign))<std(baseSign))
    %fprintf('Levels inside 1*sigma detected for event %i, level %i, total number of levels is %i\n',i,j,event.NumberOfLevels);

flag=1;
if(j==1)
event.StartAndEndPoint(1)=event.StartAndEndPoint(1)+event.ChangePoints(2)-event.ChangePoints(1);
event.AllLevelFits=event.AllLevelFits(event.ChangePoints(2)-event.ChangePoints(1)+1:end);
event.ChangePoints=event.ChangePoints(2:end);
event.NumberOfLevels=event.NumberOfLevels-1;
event.Levels=event.Levels(2:end,:);
event.Levels(:,1)=event.Levels(:,1)-1;
flag=0;
end

if(j==length(event.ChangePoints)-1 && flag)
event.StartAndEndPoint(2)=event.StartAndEndPoint(1)+event.ChangePoints(end-1)-event.ChangePoints(1);
event.AllLevelFits=event.AllLevelFits(1:event.ChangePoints(end-1)-event.ChangePoints(1)+1);
event.ChangePoints=event.ChangePoints(1:end-1);
event.NumberOfLevels=event.NumberOfLevels-1;
event.Levels=event.Levels(1:end-1,:);
end

numberLevels=numberLevels-1;
end
j=j+1;

end
end

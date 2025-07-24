%% LevelInfo function:
% This function creates the field LevelInfo of the EventDatabase.
% LevelInfo will be a table in the following format: 
% [LevelNumber Rel.Fit Abs.Fit Start End Length of Level] 
% Start and end points are in reference to RawSignal

function [LevelInfo]=get_level_info(mc,krmv,BaselinePart,StartEvent)
LevelInfo=[];
for i=1:length(krmv)-1
Start=krmv(i);
End=krmv(i+1);
LengthOfLevel=End-Start;
AbsFit=mc(round((Start+End)/2));
RelFit=abs(mc(round((Start+End)/2))-mean(BaselinePart));
LevelNumber=i;
LevelInfo=[LevelInfo; LevelNumber RelFit AbsFit Start-krmv(1)+StartEvent End-krmv(1)+StartEvent LengthOfLevel];
end
end

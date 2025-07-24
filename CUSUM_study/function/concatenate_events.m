%%
%%  This function concatenates events. 
%
%   In order to execute it you need an EventDatabase and the raw signal used
%   for analysis. The variable IncludedBaseline is the number of samples
%   you want to include before and after the event.The function has three
%   outputs: The concatenated events/fits and a new EventDatabase
%   containing the coordinates of the events in reference to the
%   concatenated signal.
%
%   Use: 
%   [ConcatenatedEvents ConcatenatedFits newEventDatabase]=concatenate_events(RawSignal,EventDatabase,IncludedBaseline)

function [ConcatenatedEvents ConcatenatedFits events]=concatenate_events(RawSignal,event,IncludedBaseline,Normalize)

ConcatenatedEvents=[];
ConcatenatedFits=[];
for i=1:length(event)
    event{i}.ConcatenatedStartCoordinates=length(ConcatenatedEvents)+IncludedBaseline;
if(Normalize)
    ConcatenatedEvents=[ConcatenatedEvents; (RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(2)+IncludedBaseline))-mean(RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(1)))];
    ConcatenatedFits=[ConcatenatedFits ones(1,IncludedBaseline)*mean(RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(1))-mean(RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(1)))) event{i}.AllLevelFits ones(1,IncludedBaseline)*mean(RawSignal(event{i}.StartAndEndPoint(2)+1:event{i}.StartAndEndPoint(2)+IncludedBaseline)-mean(RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(1))))];
else
  ConcatenatedEvents=[ConcatenatedEvents; (RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(2)+IncludedBaseline))];
  ConcatenatedFits=[ConcatenatedFits ones(1,IncludedBaseline)*mean(RawSignal(event{i}.StartAndEndPoint(1)-IncludedBaseline:event{i}.StartAndEndPoint(1))) event{i}.AllLevelFits ones(1,IncludedBaseline)*mean(RawSignal(event{i}.StartAndEndPoint(2)+1:event{i}.StartAndEndPoint(2)+IncludedBaseline))];  
end
events(i)=orderfields(event{i});
end
ConcatenatedFits=ConcatenatedFits';
end

%% Event Detection
% This function is called by main.m and does the main analysis steps.  
function [event]=event_detection_v2(RawSignal,CusumParameters,RoughEventLocations)

%% CUSUM input parameters
% Parameters set by the user
delta=CusumParameters(1);              % smallest current drop to be detected
sigma=CusumParameters(2);           % standard deviation
Normalize=CusumParameters(3);           % h from the CUSUM tables
ImpulsionLimit=CusumParameters(4);  % dwell times smaller than this value are considered delta being impulses
hBook=CusumParameters(8);
h=hBook*delta/sigma;                   % Calculation of the effective h
BaselineLength=CusumParameters(5);  % Length before and after an event
sd=CusumParameters(9);

[NumberOfEvents ~]=size(RoughEventLocations);

%Initializing the event array
event=cell(1,NumberOfEvents);

%%  Looping all the events detected by the low-pass filter
event_counter=1;
% for i=18
for i=1:NumberOfEvents
    
    %%  Zero of the CUSUM fit is CusumReferenceStartPoint in the original signal
    BaselineLength=500;
%     CusumReferencedEndPoint=RoughEventLocations(i,2)+BaselineLength;
%     CusumReferencedStartPoint=RoughEventLocations(i,1)-BaselineLength;
    if (i>1 && RoughEventLocations(i,1)-RoughEventLocations(i-1,2)<BaselineLength)
        if RoughEventLocations(i,1)-RoughEventLocations(i-1,2)<250
            continue;
        else
            BaselineLength=RoughEventLocations(i,1)-RoughEventLocations(i-1,2);
        end
    end

    CusumReferencedStartPoint=RoughEventLocations(i,1)-BaselineLength;
    CusumReferencedEndPoint=RoughEventLocations(i,2)+BaselineLength;
%     CusumReferencedEndPoint=RoughEventLocations(i,2);


    if(CusumReferencedStartPoint<=0)
        continue
    end
    
    if(CusumReferencedEndPoint>length(RawSignal))
        continue
    end

    %Structure-element to stock informations about an event
    event{event_counter}=struct();
    ARL0=RoughEventLocations(i,3)+2*BaselineLength;
    [h hBook]=SetCusum2ARL0(50,sigma,ARL0);

    
    %%  Main CUSUM
    [mc,~,krmv]=cusum_v2(RawSignal(CusumReferencedStartPoint:CusumReferencedEndPoint),delta,h,sd);

    %%  Decisions on the type of the event
    EventType='Standard Event';
    
%     %If CUSUM is too sensitive
%     if(numel(krmv)-1>10 && CusumParameters(6)==1)
%     EventType='Too many levels';
%     end
    
    %Impulsion start and end detected by the CUSUM  
    if((krmv(end)-krmv(1))<ImpulsionLimit)
    EventType='Impulsion_old';                   
    end
    
    %Impulsion end not detected by CUSUM
    if(length(krmv)==1 || krmv(end)-krmv(1)<ImpulsionLimit)
    EventType='Impulsion';
    end


%%  Treatment of the different types of event
switch EventType
%     case 'Too many levels'     
%         % In case the CUSUM has detected too many levels in one
%         % event we reset the fits with bigger input parameters.
%         % This is likely to happen in very long events.
%         h_modified=h; 
%         j=0;
%         while numel(krmv)-1>8 || j<10
%             j=j+1;
%             h_modified=1.5*h_modified;  
%             [mc,~,krmv]=cusum_v2(RawSignal(CusumReferencedStartPoint:CusumReferencedEndPoint),delta,sigma,h_modified,sd);
%         end
        
    case 'Impulsion_old'
        mc=[mean(RawSignal(CusumReferencedStartPoint:CusumReferencedStartPoint+krmv(1)))*ones(1,krmv(1)+1) min(RawSignal(CusumReferencedStartPoint+krmv(1)+1:CusumReferencedStartPoint+krmv(2)))*ones(1,krmv(2)-krmv(1)) mean(RawSignal(CusumReferencedStartPoint+krmv(2)+1:CusumReferencedEndPoint))*ones(1,length(RawSignal(CusumReferencedStartPoint+krmv(2)+1:CusumReferencedEndPoint)))];
       
        
    case 'Impulsion'
        [event{event_counter} mc krmv]=adjust_impulsions(event{event_counter},RoughEventLocations, RawSignal,i,CusumParameters);
        
end

event{event_counter}.EventType=EventType;
event{event_counter}.BaselineLength=BaselineLength;

if(strcmp(event{event_counter}.EventType, 'Impulsion')==0)%strcmp(s1,s2),return 1 if s1==s2,return 0 if s1~=s2
event{event_counter}.StartAndEndPoint=[CusumReferencedStartPoint+krmv(1) CusumReferencedStartPoint+krmv(end)]; %in Reference to RawSignal
end
BaselinePart=RawSignal(event{event_counter}.StartAndEndPoint(1)-CusumParameters(7):event{event_counter}.StartAndEndPoint(1));

%%  Function which generates the level informations of an event!
[LevelInfo]=get_level_info(mc,krmv,BaselinePart,event{event_counter}.StartAndEndPoint(1));

%%  Stock the infos in the event structure
event{event_counter}.Levels=LevelInfo;
event{event_counter}.NumberOfLevels=length(krmv)-1;
if(Normalize)
event{event_counter}.AllLevelFits=mc(krmv(1):krmv(end))-mean(BaselinePart);
else
event{event_counter}.AllLevelFits=mc(krmv(1):krmv(end));
end

event{event_counter}.ChangePoints=krmv+CusumReferencedStartPoint;

%% Adapt for levels inside 1*sigma
[numberLevels ~]=size(event{event_counter}.Levels);
event{event_counter}=adapt_levels(event{event_counter}, numberLevels, BaselinePart, i);

if(event{event_counter}.NumberOfLevels~=0)
    event{event_counter}=rmfield(event{event_counter},'ChangePoints');
    event_counter=event_counter+1;
end

end
event(event_counter:end)=[];
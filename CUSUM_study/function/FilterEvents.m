%% Gives a filtered event-database!
% This function returns a structure containing sub-databases for all
% possible filtering criterium, i.e. per event type and event length.
% 
% Use:
% EventDatabase_Filtered=FilterEvents, The script prompts you to choose an event
% database automatically.

function EventDatabase_Filtered=FilterEvents(varargin)

%% IMPORT
if(nargin==0)
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select event database...');
a=load([PathName FileName]);
if(~isfield(a, 'EventDatabase'))
    errordlg('Please specify a .mat file containing an event database','Error')
    return
end
EventDatabase=a.EventDatabase;
else
    EventDatabase=varargin{1};
end
%%



AllPossibleEventTypes=cellstr(char('Standard Event','Too many levels','Impulsion','Impulsion not detected by CUSUM'));

for j=1:length(AllPossibleEventTypes)
EventType=AllPossibleEventTypes{j};
varname=genvarname(EventType);
indices.(varname)=[];
EventDatabase_Filtered.(varname)=[];
for i=1:length(EventDatabase)
    if(strcmp(EventDatabase(i).EventType, EventType))
        indices.(varname)=[indices.(varname) i];
        EventDatabase(i).OriginalEventNumber=i;
        EventDatabase_Filtered.(varname)=[EventDatabase_Filtered.(varname) EventDatabase(i)];
    end
end
if(isempty(EventDatabase_Filtered.(varname)))
    EventDatabase_Filtered=rmfield(EventDatabase_Filtered, varname);
end
end


%% Search for events with x-levels

max_levels=max(cell2mat({EventDatabase(:).NumberOfLevels}));

for j=0:max_levels
varname=genvarname(['event_has_' int2str(j) '_levels']);
indices.(varname)=[];
EventDatabase_Filtered.(varname)=[];
for i=1:length(EventDatabase)
    if(EventDatabase(i).NumberOfLevels==j)
        EventDatabase(i).OriginalEventNumber=i;
        indices.(varname)=[indices.(varname) i];
        EventDatabase_Filtered.(varname)=[EventDatabase_Filtered.(varname) EventDatabase(i)];
    end
end
if(isempty(indices.(varname)))
    indices=rmfield(indices, varname);
end

if(isempty(EventDatabase_Filtered.(varname)))
    EventDatabase_Filtered=rmfield(EventDatabase_Filtered, varname);
end
end
end
%%  Creates a string with general information about your signal after analysis
%   Input is an EventDatabase (filtered or not), output is a string.
%   Use: output_string=AnalysisInfos(EventDatabase);


function string=AnalysisInfos(events)
filtered=FilterEvents(events);
length_db=length(events);
fields=fieldnames(filtered);

level_infos=[];
s=sprintf('The signal has a total of %i events:\n',length_db);
for i=0:max(cell2mat({events(:).NumberOfLevels}))
varname=['event_has_' int2str(i) '_levels'];
if(isfield(filtered,varname))
s=[s sprintf('%i\t(%1.1f%%)\t%i-level events.\n',length(filtered.(varname)),length(filtered.(varname))/length_db*100,i)];
end
end

string=s;
end

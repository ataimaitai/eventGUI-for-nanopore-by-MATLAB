%%  Non-public function used by event_detection.m

function newED=getArea(ExperimentTitle)

a=load([ExperimentTitle filesep 'ExperimentData.mat']);

ConcatenatedEvents=a.ConcatenatedEvents;
newED=a.EventDatabase;
SamplingFrequency=a.SamplingFrequency;
time_units=a.time_units;
current_units=a.current_units;

units_c=1e-9;
switch current_units
    case 'nA'
        units_c=1e-9;
    case 'pA'
        units_c=1e-12;
end

conversion=units_c;


for i=1:length(newED)
    s=newED(i).ConcatenatedStartCoordinates;
    e=(newED(i).ConcatenatedStartCoordinates+length(newED(i).AllLevelFits)-1);
    x=1:length(newED(i).AllLevelFits);
    if(length(newED(i).AllLevelFits)>1)
    int=trapz((x)./SamplingFrequency,ConcatenatedEvents(s:e));
    newED(i).AreaCoulomb=abs(int*conversion);
    else
    newED(i).AreaCoulomb=0;
    end
end

end
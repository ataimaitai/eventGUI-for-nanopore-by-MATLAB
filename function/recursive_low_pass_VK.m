function [RoughEventLocations]=recursive_low_pass_VK(RawSignal,StartCoeff,EndCoeff,FilterCoeff)
 
%% The current signal length
Ni=length(RawSignal);       %signal size
RoughEventLocations=zeros(1e5,3);
%% The algorithm parameters
%filter coefficient
a=FilterCoeff;
%thresholds
S=StartCoeff; E=EndCoeff;%for event start and end thresholds

%% The recursive algorithm
%loop init
ml=zeros(1,Ni);
vl=zeros(1,Ni);
ml(1)=mean(RawSignal);  %local mean init
vl(1)=var(RawSignal);   %local variance init
i=1;                    %sample counter
NumberOfEvents=0;       %number of detected events

%main loop
while i<(Ni-1)
    i=i+1;
    %local mean low pass filtering
    ml(i)=a*ml(i-1)+(1-a)*RawSignal(i);
    %local variance low pass filtering
    vl(i)=a*vl(i-1)+(1-a)*(RawSignal(i)-ml(i))^2;
    %local threshold to detect event start
    Sl=ml(i)-S*sqrt(vl(i));
    %test to detect event start: if the current is lower than Sl
    if(RawSignal(i+1)<=Sl)
        %fprintf('Entered neg. jump');
        %increase the number of detected events
        NumberOfEvents=NumberOfEvents+1;
        start=i+1;
        %local threshold to detect event end
        El=ml(i)-E*sqrt(vl(i));
        Mm=ml(i);Vv=vl(i);%save local mean and variance
        %test to detect event end: when the current is higher than El
        %while en backward : i=i-1;
        while RawSignal(i+1)<El && i<(Ni-1)
            i=i+1;
        end
        %%  Searching for Event Start and Stop coordinates
        RoughEventLocations(NumberOfEvents,3)=i+1-start;
        RoughEventLocations(NumberOfEvents,1)=start;
        RoughEventLocations(NumberOfEvents,2)=i+1;
        ml(i)=Mm;vl(i)=Vv;%use previous local mean and variance as init
    end
end

RoughEventLocations(NumberOfEvents+1:end,:)=[];

end
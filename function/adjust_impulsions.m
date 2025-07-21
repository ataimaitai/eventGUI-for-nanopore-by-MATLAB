%%  Non-public function used by event_detection.m

function [event mc krmv]=adjust_impulsions(event,RoughEventLocations, RawSignal,k, CusumParameters)
        middle=RoughEventLocations(k,1);
        sigma_before=std(RawSignal(middle-CusumParameters(7):middle));
        mean_before=mean(RawSignal(middle-CusumParameters(7):middle));
        
        %%  Check when the signal returns to baseline. Startpoints are in the middle of an impulsion normally
        %find start
        j=middle;
        while(abs(RawSignal(j)-mean_before)>sigma_before && j>1)
            j=j-1;
        end
        RoughEventLocations(k,1)=j;
        
        %find end
        j=middle;
        while(abs(RawSignal(j)-mean_before)>sigma_before && j<length(RawSignal))
            j=j+1;
        end
        
        RoughEventLocations(k,2)=j;
        RoughEventLocations(k,3)=RoughEventLocations(k,2)-RoughEventLocations(k,1);


        event.StartAndEndPoint=[RoughEventLocations(k,1) RoughEventLocations(k,2)];
        krmv(1)=1; krmv(2)=RoughEventLocations(k,3)+1;
        
        mc=min(RawSignal(RoughEventLocations(k,1):RoughEventLocations(k,2)))*ones(1,RoughEventLocations(k,3)+1);



end
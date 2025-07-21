function [eventMessage]=extractEvent(signal,start,end_)
    eventMessage=struct();
    eventNum=length(start);
    if eventNum
        for i=1:eventNum
            eventMessage.data{i}=signal(start(i):end_(i));
            eventMessage.idx{i}=(start(i):end_(i))';
            eventMessage.dwellPoint(i)=length(eventMessage.idx{i});
            eventMessage.min(i)=min(eventMessage.data{i});
            eventMessage.mean(i)=mean(eventMessage.data{i});
            eventMessage.dwelldeepth(i)=eventMessage.data{i}(1)-eventMessage.mean(i);
        end
    end
end
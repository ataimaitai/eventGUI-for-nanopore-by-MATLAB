Init__();
[filename,fileroad,fileNamePath,fileSum]=importFile();
for fileidx=1:fileSum
    close all;
    S=5;                        % S Coefficient for recursive low pass filter=> threshold S*sigma  
    E=0;                        % E Coefficient for recursive low pass filter
    delta=33;                  % most likely and smallest current drop/最可能和最小的电流降
    sigma=0.04;                 % standard deviation of the baseline (can use the MATLAB fonction std)
    Normalize=1;                % Normalizes the baseline to 0 for the plots. Choose from Yes=1, No=0
    ImpulsionLimit=100;          % Every event smaller than this amount of samples is considered to be an impulsion
    IncludedBaseline=100;       % Number of baseline points included for the CUSUM fit
    TooMuchLevels=10;           % You can turn off the small while loop by putting a zero here!
    IncludedBaselinePlots=500;   % Number of baseline points inlcuded for plotting events
    priority=-1;
    filePath = fullfile(fileNamePath{fileidx});
    RAW = load(filePath);
    RawSignal = RAW.MATdata.*1e12;
    fs=RAW.outputsamplerate;
    sigma=std(RawSignal);
    [RoughEventLocations]=recursive_low_pass(RawSignal,S,E,0.999);
    CusumParameters=[delta sigma Normalize ImpulsionLimit IncludedBaseline TooMuchLevels IncludedBaselinePlots 1];
    [EventDatabase]=event_detection(RawSignal, CusumParameters, RoughEventLocations);
    [ConcatenatedEvents, ConcatenatedFits, event]=concatenate_events(RawSignal, EventDatabase, IncludedBaselinePlots,Normalize);
    EventDatabase=event;
    % figure('WindowState','maximized');
    % plot(ConcatenatedEvents);hold on;
    % plot(ConcatenatedFits);
    f=figure('WindowState','maximized');
    
    sgtitle(filename{fileidx},'Interpreter','none');
    try
    for i=1:length(EventDatabase)
        subplot(4,4,i);hold on;
        idx=i;
        eventLength = length(EventDatabase(idx).StartAndEndPoint(1) : EventDatabase(idx).StartAndEndPoint(2));
        begin = EventDatabase(idx).ConcatenatedStartCoordinates;
        over = EventDatabase(idx).ConcatenatedStartCoordinates + eventLength;
        start = EventDatabase(idx).ConcatenatedStartCoordinates - IncludedBaselinePlots + 1;
        end_ = EventDatabase(idx).ConcatenatedStartCoordinates + over - begin + IncludedBaselinePlots;
        plot(start:end_,ConcatenatedEvents(start:end_).*priority);grid on;axis tight;
        plot(start:end_,ConcatenatedFits(start:end_).*priority,'LineWidth',2,'Color','r', 'LineStyle', ':');
        % yline(mean(ConcatenatedEvents(start:begin)).*priority,'g','LineWidth',2);
        % yline(mean(ConcatenatedEvents(begin:over)).*priority,'y','LineWidth',2);
        % yline(min(ConcatenatedEvents(begin:over)).*priority,'b','LineWidth',2);
    
        % xline(begin,'k-.');
        % xline(over,'k-.');
    
        x1=begin;
        x2=over;
        y1=mean(ConcatenatedEvents(start:begin)).*priority;
        %y2=mean(ConcatenatedEvents(begin:over)).*priority;
        [~,ttt]=max(EventDatabase(idx).Levels(:,6));
        y2=EventDatabase(idx).Levels(ttt,2);
        %y3=min(ConcatenatedEvents(begin:over)).*priority;
        [y3,y3idx]=max(EventDatabase(idx).Levels(:,2));
        wwiidd = EventDatabase(idx).Levels(y3idx,6)*1e6/fs;
        width=abs(x1-x2);
        length1=abs(y1-y2);
        length2=abs(y2-y3);
        rectangle('Position',[x1,y1,width,length1],'EdgeColor','g','LineWidth',2,'LineStyle','-.');
        if wwiidd<=60 && abs(y2-y3)>=abs(y2-y1)
            rectangle('Position',[x1,y2,width,length2],'EdgeColor','k','LineWidth',2,'LineStyle','-.');
            title(sprintf('subH:%g pA，subT:%g us',abs(y2-y3),wwiidd));%次级阻塞深度、次级阻塞时间
        end
        ylabel(sprintf('%s',EventDatabase(idx).EventType));%事件类型
        xlabel(sprintf('H:%g pA，T:%g us',abs(y2-y1),abs(x1-x2)*1e6/fs));%一级阻塞深度、一级阻塞时间
    end
    catch
        saveas(f,sprintf('%s.jpg',filename{fileidx}));
        continue;
    end
    saveas(f,sprintf('%s.jpg',filename{fileidx}));
end
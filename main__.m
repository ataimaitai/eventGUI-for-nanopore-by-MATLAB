Init__();
clear;clc;
window = 10000;
poly1 = 2;
poly2 = 5;
cutoff = 10000;
pole = 8;
startCoeff = 4;
endCoeff = 0.1;
filterCoeff = 0.999;
timeThreshold = [600,10000];
deepthThreshold = [0,10000];
[fileName,filePath,fileNamePath,fileSum]=importFile();
scatterData = zeros(0,2);
for fileIdx = 1:fileSum
    [dataMessage]=readFileData(fileNamePath{fileIdx});
    originalSignal = dataMessage.signalData;
    N = dataMessage.signalPointNum;
    fs = dataMessage.sampleRate;
    t = dataMessage.sampleInterval;
    tIdx = dataMessage.timeIdx;
    [pretreatSignal, ~] = polynomial_baseline_correction(originalSignal,window,poly1,poly2);
    stagingSignal = butterfilt(pretreatSignal,cutoff,pole,fs,'type','low');
    dealSignal = stagingSignal;
    [~, baseline] = polynomial_baseline_correction(stagingSignal,window,poly1,poly2);
    [RoughEventLocations]=recursive_low_pass_VK(dealSignal,startCoeff,endCoeff,filterCoeff);
    [eventMessage]=extractEvent(dealSignal,baseline,RoughEventLocations);
    eventTime = 1e6*eventMessage.dwellPoint/fs;
    eventDeepth = eventMessage.dwelldeepth;
    pickTime = find(eventTime >= timeThreshold(1) & eventTime <= timeThreshold(2));
    pickDeepth = find(eventDeepth >= deepthThreshold(1) & eventDeepth <= deepthThreshold(2));
    pickIdx = pickTime(ismember(pickTime, pickDeepth));
    eventNum = length(pickIdx);
    fprintf('%d/%d-%d\n',fileIdx,fileSum,eventNum);
    if eventNum
        pickEventTime = eventTime(pickIdx);
        pickEventDeepth = eventDeepth(pickIdx);
        pickEventData = eventMessage.data{pickIdx};
        pickEventIdx = eventMessage.idx{pickIdx};
        scatterData(end+1 : end+eventNum,:) = [pickEventTime;pickEventDeepth]';
    end
end
%figure('WindowState','maximized');
hold on;
scatter(scatterData(:,1),scatterData(:,2),'filled');
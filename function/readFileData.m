function [dataMessage]=readFileData(filePath)
    dataMessage=struct();
    [dataMessage.fileProfile, dataMessage.fileName, dataMessage.fileFormat] = fileparts(filePath);
    if strcmp(dataMessage.fileFormat, '.abf')
        [dataMessage.signalData,dataMessage.sampleInterval,~] = abfload(filePath);
        dataMessage.signalData=dataMessage.signalData(:,1);
        dataMessage.sampleRate=1e6/dataMessage.sampleInterval;
    elseif strcmp(dataMessage.fileFormat, '.mat')
        a = load(filePath);
        dataMessage.signalData=a.MATdata;
        dataMessage.sampleRate = a.outputsamplerate;
        dataMessage.sampleInterval=1e6/dataMessage.sampleRate;
    end
    dataMessage.signalPointNum = length(dataMessage.signalData);
    dataMessage.signalTime = dataMessage.signalPointNum/dataMessage.sampleRate;
    dataMessage.timeIdx=(1/dataMessage.sampleRate:1/dataMessage.sampleRate:dataMessage.signalTime)';
    dataMessage.freq=dataMessage.sampleRate*(1:ceil(dataMessage.signalPointNum/2+1))/dataMessage.signalPointNum;
end
close all;clear;clc;
timeThreshold = [600,10000];
deepthThreshold = [0,10000];
eventTime = [100,300,400,600,800,100,1000,4000];
eventDeepth=[10,-10,20000,10,200,10,11,12];
pickTime = find(eventTime >= timeThreshold(1) & eventTime <= timeThreshold(2));
pickDeepth = find(eventDeepth >= deepthThreshold(1) & eventDeepth <= deepthThreshold(2));
commonIndices = pickTime(ismember(pickTime, pickDeepth));
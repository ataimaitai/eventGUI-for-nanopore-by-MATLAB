% Two-sided cusum algo, change in the mean of a white gaussian signal
% Setting the detection threshold h
% through the mean time between false detections ARL0

function [hopt hbook]=SetCusum2ARL0(deltax,sigmax,varargin)
%% General parameters
%varargin: ARL0_2, h0min, h0max

%default
if(nargin==2)
h0min=0.1;h0max=10; %detection threshold interval
ARL0_2=1000;
elseif(nargin==3)
    h0min=0.1;h0max=10; %detection threshold interval
    ARL0_2=varargin{1};
elseif(nargin==4)
    errordlg('Please provide both h0min and h0max','Error');
    return
elseif(nargin<2)
    errordlg('Not enough input arguments','Error')
    return
else
    h0min=varargin{2};h0max=varargin{3}; %detection threshold interval
    ARL0_2=varargin{1}; 
end


%% Optimal threshold determination
% Desired ARL0 "ARL0_2"

ARL0=2*ARL0_2;      %for two-sided algo
% Optimization on h "hopt"
change=0;
mu=deltax*(change-deltax/2)/sigmax^2;
sigma=abs(deltax)/sigmax;
mun=mu/sigma;
f=@(h)(exp(-2*mun*(h/sigma+1.166))-1+2*mun*(h/sigma+1.166))/(2*mun^2)-ARL0;

%plot(f(linspace(h0min,h0max,1000)))

if(f(h0min)*f(h0max)<0)
hopt=fzero(f,[h0min h0max]);
elseif(f(h0min) <0 && f(h0max) <0)
    hopt=h0max;
elseif(f(h0min) >0 && f(h0max) >0)
    hopt=h0min;
end
    
% Obtained ARL1 "ARL1_2"
% ARL1=ARLSiegmund(deltax,sigmax,deltax,hopt);
% ARLm1=ARLSiegmund(deltax,sigmax,-deltax,hopt);
% ARL1_2=ARL1*ARLm1/(ARL1+ARLm1); %for two-sided algo
% 
hbook=sigmax*hopt/deltax;
% % Display results
% display(' ');
% display(sprintf('Two-sided cusum, settings through ARL0:'));
% display(sprintf(' - desired ARL0 = %.2f',ARL0_2));
% display(sprintf(' - optimal detection threshold hopt = %.3f',hopt));
% display(sprintf(' - obtained ARL1 = %.2f',ARL1_2));
end

%               RECURSIVE DOUBLE CUSUM ALGORITHM
% (Detection of abrupt changes in the mean ; optimal for Gaussian signals)
%
%           Inputs :
%             x    : signal samples
%             delta: most likely jump to be detected
%             h    : threshold for the detection test
%             sd   : duration of noise spikes in samples
%
%           Outputs :
%             mc   : piecewise constant segmented signal
%             kd   : detection times (in samples)
%             krmv : estimated change times (in samples)

function [mc,kd,krmv]=cusum_v2(x,delta,h,sd)
%% Algo initialization
Nd=0;           %detection number
kd=length(x);   %detection time (in samples)
krmv=length(x); %estimated change time (in samples)
k0=1;        %initial sample
k=1;         %current sample
m(k0)=x(k0); %mean value estimation
v(k0)=0;     %variance estimation
sp(k0)=0; %instantaneous log-likelihood ratio for positive jumps
Sp(k0)=0; %cumulated sum for positive jumps
gp(k0)=0; %decision function for positive jumps
sn(k0)=0; %instantaneous log-likelihood ratio for negative jumps
Sn(k0)=0; %cumulated sum for negative jumps
gn(k0)=0; %decision function for negative jumps
%% Global Loop
%w = waitbar(0,'Calculating Cumulative Sums, please wait...');
while k<length(x)
    %current sample
    k=k+1;
    %mean and variance estimation (from initial to current sample)
    len=k-k0+1;
    m(k)=(m(k-1)*(len-1)+x(k))/len;
    v(k)=(v(k-1)*(len-1)+(m(k)-x(k))^2)/len;
    %instantaneous log-likelihood ratios
    sp(k)=delta/v(k)*(x(k)-m(k)-delta/2);
    sn(k)=-delta/v(k)*(x(k)-m(k)+delta/2);
    %cumulated sums
    Sp(k)=Sp(k-1)+sp(k);
    Sn(k)=Sn(k-1)+sn(k);
    %decision functions
    gp(k)=max(gp(k-1)+sp(k),0);
    gn(k)=max(gn(k-1)+sn(k),0);
    %abrupt change detection test
    if  (k<=sd && (gp(k)>h || gn(k)>h)) ||...
            (k>sd && ((gp(k-sd)>h && gp(k)>h) || ...
            (gn(k-sd)>h && gn(k)>h))) 
        %detection number and detection time update
        Nd=Nd+1;
        kd(Nd)=k;
        %change time estimation
        [~,kmin]=min(Sn(k0:k));
        krmv(Nd)=kmin+k0-1;
        if  (k<=sd && gp(k)>h) || (k>sd && (gp(k-sd)>h && gp(k)>h))
            [~,kmin]=min(Sp(k0:k));
            krmv(Nd)=kmin+k0-1;
        end
        %algorithm reinitialization
        k0=k;
        m(k0)=x(k0);v(k0)=0;
        sp(k0)=0;Sp(k0)=0;gp(k0)=0;sn(k0)=0;Sn(k0)=0;gn(k0)=0;
    end
end

%% Piecewise constant segmented signal
if Nd==0
    mc=mean(x)*ones(1,k);
elseif Nd==1
    mc=[m(krmv(1))*ones(1,krmv(1)) m(k)*ones(1,k-krmv(1))];
else
    mc=m(krmv(1))*ones(1,krmv(1));
    for ii=2:Nd
        mc=[mc m(krmv(ii))*ones(1,krmv(ii)-krmv(ii-1))];
    end
    mc=[mc m(k)*ones(1,k-krmv(Nd))];
end

%close (w)

%% Printing CUSUM segmentation results
% figure('Name','CUSUM segmentation results');
% plot(x,'b');
% grid on;hold on;
% plot(mc,'r','LineWidth',2);
% hold off;
% xlabel('sample number');ylabel('current (nA)');
% legend('original signal','segmented signal');
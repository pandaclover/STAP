%{
  ------------------ PSD_Plot ---------------------------------------------
  画出有用信号和干扰信号的功率谱密度

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [] = PSD_Plot(Xs,I_wb)

% 全局变量
global    settings

% FFT点数
nfft     = 1024;

% 加窗
window   = hanning(nfft);

% 重叠数据点数 --- 重叠50%
noverlop = nfft/2;

[Pxs,f]  = pwelch(Xs,window,noverlop,nfft,settings.fs);

f        = -settings.fs/2 + f;

[P1,~]  = pwelch(I_wb(1,:),window,noverlop,nfft,settings.fs);
[P2,~]  = pwelch(I_wb(2,:),window,noverlop,nfft,settings.fs);
[P3,~]  = pwelch(I_wb(3,:),window,noverlop,nfft,settings.fs);

figure(101)
plot(f./1e6,10*log10(fftshift(Pxs)),'LineWidth',1);
grid on
hold on
plot(f./1e6,10*log10(fftshift(P1)),'LineWidth',1);
plot(f./1e6,10*log10(fftshift(P2)),'LineWidth',1);
plot(f./1e6,10*log10(fftshift(P3)),'LineWidth',1);



end
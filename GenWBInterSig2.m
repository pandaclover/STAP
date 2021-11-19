%{
  ---------------------- 产生宽带干扰信号 ---------------------------------
  随机调相信号

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   InterSig = GenWBInterSig2()

% 全局变量
global settings

% 调相系数--- 论文中使用的调相系数是1000
Kpm       = 100;

% 随机序列Un的方差
sigma2    = 0.1;

% 产生随机相位序列
Un    = sqrt(sigma2).*randn(settings.WBInNum, settings.SampleNum);

% 产生载波的相位
Phase = 2*pi.*(settings.WBIF(1:settings.WBInNum).').*settings.ts ...
      .* (0:settings.SampleNum-1) + Kpm.*Un;

InterSig = exp(1i.*Phase);


end
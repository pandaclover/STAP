%{
  ---------------------- 产生宽带干扰信号 ---------------------------------
  3个互不相干的线性跳频信号

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   I_wb = GenWBInterSig()

% 全局变量
global    settings

% 采样时间
t     = (0:settings.SampleNum-1).*settings.ts;
t     = t - settings.T/2;

% 调频相位
Phase = exp(1i*pi*settings.mu.*t.^2);

% 中频载波
Carr  = exp(1i*2*pi.*(settings.WBIF(1:settings.WBInNum).').*t) ...
      .* exp(1i*2*pi*rand(settings.WBInNum,1));

I_wb  = Carr.*Phase;


end
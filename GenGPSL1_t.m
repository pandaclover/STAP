%{
  -------------- 产生GPS L1信号 -------------------------------------------

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Xs = GenGPSL1_t()

% 全局变量
global    settings

t        = (0:settings.SampleNum-1).*settings.ts;

% 产生载波
Carr     = exp(1i*2*pi*settings.IF.*t);

% 产生PRN = 1的伪随机码
CaCode   = generateCAcode(1);

% 码元扩展 --- 暂时没有考虑label超过边界的情
Index    = floor(t./settings.CodeTau) + 1;

Code     = CaCode(Index);

% BPSK调制
Xs       = Code.*Carr;

end
%{
  ------------------- 产生各个频点上的导向矢量 ----------------------------
  ULA

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   Alphaf   = ArraySteerVectorCalculate_ula()

% 全局变量
global    settings;

% 有用信号数
SigNum   = settings.SigNum;

% 干扰信号数
WBINum   = settings.WBInNum;

% 天线阵元数
RecNum   = settings.RecNum;

% 模拟射频频率
f        = -settings.fs/2 + (0:settings.N-1).*(settings.fs/settings.N);
f        = f + settings.fc;

% 有用信号阵列响应
for index = 1:SigNum
    
   theta       = settings.Stheta(index)*pi/180;
   
   % 传播距离差
   deltaD      = settings.d*sin(theta)*(0:RecNum-1).';
   
   % 构建阵列延时矢量
   dtau        = deltaD./settings.c;
   
   % 考虑不同频点上的阵列响应
   [F, dTau]   = meshgrid(f, dtau);
   Alphaf.Xs{index} = exp(-1i*2*pi.*F.*dTau);
    
end % for index = 1:SigNum

%--------------------------------------------------------------------------

% 干扰信号阵列响应
for index = 1:WBINum
    
    theta       = settings.Itheta(index)*pi/180;    
    
    % 传播距离差
    deltaD      = settings.d*sin(theta)*(0:RecNum-1).';
   
    % 构建阵列延时矢量
    dtau        = deltaD./settings.c;
   
    % 考虑不同频点上的阵列响应
    [F, dTau]   = meshgrid(f, dtau);
    Alphaf.WI{index} = exp(-1i*2*pi.*F.*dTau);
    
end % for index = 1:WBINum

end
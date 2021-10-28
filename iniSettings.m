%{
  ------------------- 系统参数设置 ----------------------------------------
  1.有用信号采用中频为10MHz的GPS L1信号
  2.干扰信号采用3个互不相干的宽带线性调频信号

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   settings = iniSettings()

settings.c          = 3e8;                           % 光速

%------------------- 信号参数设置 -----------------------------------------
settings.SigNum     = 1;                             % 有用信号数 
settings.fc         = 1575.42e6;                     % 载波频率 --- 2GHz
settings.lambda     = settings.c/settings.fc;        % 波长
settings.CodeFre    = 1.023e6;                       % 码频率
settings.CodeTau    = 1/settings.CodeFre;            % 码片宽度
settings.CodeLength = 1023;                          % C/A码长 --- 1023
settings.SNR        = -31.37;                        % 输入信噪比 [dB]
settings.Ps         = 1;                             % 输入信号功率 [W]
settings.Stheta     = 0;                             % 期望信号入射方向 [deg]

%--------------------- 接收机参数设置 -------------------------------------
settings.IF         = 10e6;                          % 中频为10MHz
settings.fs         = 60e6;                          % 采样频率60MHz
settings.ts         = 1/settings.fs;                 % 采样周期
settings.SampleNum  = 5000;                          % 接收信号快拍数
settings.orders     = 16;                            % 延迟单元数为16
settings.T          = settings.SampleNum*settings.ts;

%--------------------- 干扰信号参数设置 -----------------------------------
settings.WBInNum    = 3;                             % 干扰信号数
settings.B          = 20e6;                          % 干扰信号带宽
settings.mu         = settings.B/settings.T;         % 调频率
settings.Pi         = 100e3;                         % 干扰信号功率 [W]
settings.WBIF       = ...
    [8e6,10e6,12e6];                                 % 中频间隔2MHz
settings.BT         = settings.B*settings.T;         % 时宽带宽积 --- 1600+？似乎有点高啊
settings.Itheta     = ...                            % 干扰信号入射方向 [deg]
    [-20,30,50];                                   

%--------------------- 接收阵列参数设置 -----------------------------------
settings.RecNum     = 4;                             % 四阵元均匀线列阵
settings.d          = settings.lambda/2;             % 阵元间距为半波长


end
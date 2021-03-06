%{
  ------------------- 无约束条件下的空时自适应处理算法 --------------------
  1.有用信号采用GPS L1信号
  2.干扰信号采用线性调频信号

  -------------------------------------------------------------------------
  [1] 卫星导航定位接收机抗干扰技术研究  

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear variables; close all; clc;

% 全局变量
global    settings

% 仿真参数设置
settings      = iniSettings();

%----------------------- 产生有用信号、干扰信号、噪声 ---------------------
% 产生GPS L1的中频信号
Xs            = GenGPSL1_t();

% 有用信号的幅度 --- 输入信号的功率为1W
Am            = sqrt(settings.Ps);
Xs            = Am.*Xs;

% 产生宽带干扰信号
I_wb          = GenWBInterSig();
Ai            = sqrt(settings.Pi);
I_wb          = Ai.*I_wb;

% 噪声 --- 首先根据信噪比计算噪声功率
Pn            = settings.Ps/(10^(settings.SNR/10));
An            = sqrt(Pn/2);
Noise         = An.*randn(settings.RecNum,settings.SampleNum) ...
              + 1i.*An.*randn(settings.RecNum,settings.SampleNum);

% 画出它们的功率谱密度 --- 但是因为采样点数比较少，所以画出来的图不够准确
% PSD_Plot(Xs,I_wb);

%----------------------- 阵列接收信号建模 ---------------------------------
Alpha_mat     = GenArraySteerVectorMatrix();

% 信号矢量
SigVector     = [Xs;I_wb];

% 阵列接收信号
Yt            = Alpha_mat*SigVector + Noise;

%-------------- 用空时导向矢量来直接产生长度为(M-1)*N的列矢量 -------------
M             = settings.RecNum;
L             = settings.SampleNum/2;
N             = settings.orders;
Xm            = zeros(N*(M-1),L);
S_t           = exp(1i*(2*pi*settings.IF*settings.ts).*(0:N-1).');

% 单独产生第一个通道的信号
X1           = Yt(1,1:L);

%------------------- 手动构造长度为(M-1)*N的Xm矢量 ------------------------   
for RecIndex = 2:settings.RecNum              % 第一个通道不抽头

    for dataIndex = 1:L
        
        % 循环移位
        temValue = circshift(Yt(RecIndex,:),-(dataIndex-1));
        
        Xm((RecIndex-2)*N+1:(RecIndex-1)*N,dataIndex) = temValue(1:N).';

    end % for dataIndex = 1:L

end % for RecIndex = 1:settings.RecNum

%------------------------- 计算加权矢量 -----------------------------------
R_mm      = Xm*Xm'./L;
R_m1      = Xm*X1'./L;
w_opt     = -inv(R_mm)*R_m1;
w_opt     = [1;w_opt];

%------------------- 只画出中频处的阵列响应图 -----------------------------
Theta    = -100:0.5:100;
Value    = zeros(1,length(Theta));
for index = 1:length(Theta)

    theta = Theta(index)*pi/180;
    
    % 当前入射方向的空域导向矢量
    S_s   = exp(1i*(2*pi*settings.d*sin(theta)/settings.lambda) ...
          .*(1:settings.RecNum-1).');

    % 当前角度的空时导向矢量
    S     = kron(S_s,S_t);
    
    % 
    S     = [1;S];
    
    Value(index) = w_opt'*S;

end % for index = 1:length(Theta)

Value_dB = 20*log10(abs(Value));
figure(102)
plot(Theta,Value_dB);
grid on





%{
  ------------------ 含约束条件下的空时自适应处理算法 ---------------------
  1.有用信号采用GPS L1信号
  2.干扰信号采用线性调频信号
  --- LFM信号仍存在问题，考虑使用宽带随机调相信号

  3.考虑宽带信号的建模

  -------------------------------------------------------------------------
  [1] 卫星导航定位接收机抗干扰技术研究，任超

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
% I_wb          = GenWBInterSig();
I_wb          = GenWBInterSig2();
Ai            = sqrt(settings.Pi);
I_wb          = Ai.*I_wb;

% 噪声 --- 首先根据信噪比计算噪声功率
Pn            = settings.Ps/(10^(settings.SNR/10));
An            = sqrt(Pn/2);
Noise         = An.*randn(settings.RecNum,settings.SampleNum) ...
              + 1i.*An.*randn(settings.RecNum,settings.SampleNum);

% 画出它们的功率谱密度
% PSD_Plot(Xs,I_wb);

%----------------------- 阵列接收信号建模 ---------------------------------
[S_in,Wb_in]  = GenArraySignal(Xs,I_wb);

% 阵列接收信号
Yt            = S_in + Wb_in + Noise;

% 输入信号功率
Ps_in         = sum(sum(abs(S_in).^2))/settings.SampleNum/settings.RecNum;
Pi_in         = sum(sum(abs(Wb_in).^2))/settings.SampleNum/settings.RecNum;
Pn_in         = sum(sum(abs(Noise).^2))/settings.SampleNum/settings.RecNum;

% 输入SINR
SINR_in       = 10*log10(Ps_in/(Pi_in + Pn_in));

%----------------------- 用空时导向矢量直接产生Xm -------------------------
M             = settings.RecNum;                        % 阵元数
L             = settings.L;                             % 数据量
N             = settings.orders;                        % 抽头数
Xm            = zeros(N*M,L);                           % Xm向量初始化

%------------------------ 手动构造Xm矢量 ----------------------------------
for RecIndex = 1:M

    for dataIndex = 1:L

        % 循环移位
        temValue = circshift(Yt(RecIndex,:),-(dataIndex-1));

        Xm((RecIndex-1)*N+1:RecIndex*N,dataIndex) = temValue(1:N).';


    end % for dataIndex = 1:L

end % for RecIndex = 1:settings.RecNum

%------------------------ 计算加权矢量 ------------------------------------
% 协方差矩阵
Rx       = Xm*Xm'./L;

% 空域约束
S_s      = exp(-1i*pi*settings.d*sind(settings.Stheta).*(0:M-1).');

S_t      = exp(1i*2*pi*settings.IF*settings.ts.*(0:N-1).');

S        = kron(S_s,S_t);

% % % 功率倒置方法
% S        = zeros(M*N,1);
% S(1)     = 1;

w_opt    = (S'*inv(Rx)*S)^(-1)*inv(Rx)*S;

[Ps_out,Pi_out,Pn_out]    = OutputPowerCalculate(w_opt,S_in,Wb_in,Noise);

% 输出SINR
SINR_out = 10*log10(Ps_out/(Pi_out + Pn_out));

% 干扰抑制度
JRI      = 10*log10(Pi_in/Pi_out); 

%------------------------- 空频二维阵列响应图 -----------------------------
Theta    = -100:0.1:100;
% 模拟域频率
f        = -settings.fs/2 + (0:settings.N-1).*(settings.fs/settings.N);
fc       = f + settings.fc;
Value    = zeros(settings.N,length(Theta));
for thetaIndex = 1:length(Theta)
    
    theta = Theta(thetaIndex)*pi/180;

    for fIndex = 1:settings.N
        
        % 当前入射方向的空域导向矢量
        S_s   = exp(-1i*(2*pi*settings.d*fc(fIndex)*sin(theta)/settings.c) ...
            .*(0:settings.RecNum-1).');
        
        S_t   = exp(1i*2*pi*f(fIndex)*settings.ts.*(0:N-1).');
        
        Value(fIndex,thetaIndex) = w_opt'*kron(S_s,S_t);
        
    end % for fIndex = 1:settings.N

end % for index = 1:length(Theta)

Value_dB = 20*log10(abs(Value));

figure(102)
h1 = surfc(Theta,f./1e6,Value_dB);
h1(2).LevelList = linspace(-90,-40,6);
shading interp;
colormap(jet);
h2 = colorbar;
set(h2,'Fontsize',12);
ylabel('频率 [MHz]');
xlabel('方位角\phi [deg]');
zlabel('阵列增益 [dB]');
axis tight;

%{
  ------------------- 产生空域导向矢量矩阵 --------------------------------
  [1] 卫星导航定位接收机抗干扰技术研究
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   Alpha_mat = GenArraySteerVectorMatrix()

% 全局变量
global    settings

% 阵元数
RecNum      = settings.RecNum;

% 阵元间距
d           = settings.d;

% 入射角集合
theta_set   = [settings.Stheta,settings.Itheta(1:settings.WBInNum)];

% 转换为弧度
theta_set   = theta_set*pi./180;

% 空频 --- [1]中(4.5)式内的omega_s
omega_s     = (2*pi*d/settings.lambda).*sin(theta_set);

Alpha_mat   = exp(1i.*(0:RecNum-1).'*omega_s);

end
%{
  ------------------- 各信号分量抗干扰处理后输出功率的计算 ----------------

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Ps_out,Pi_out,Pn_out] = OutputPowerCalculate(w_opt,S_in,Wb_in,Noise)

% 全局变量
global    settings

% 阵元数
M       = settings.RecNum;

% 数据量
L       = settings.L;

% 抽头数
N       = settings.orders;

% 初始化
Xs      = zeros(N*M,L);
Xi      = zeros(N*M,L);
Xn      = zeros(N*M,L);

for RecIndex = 1:M
    
    for dataIndex = 1:L
    
        % 循环移位
        temValue  = circshift(S_in(RecIndex,:),-(dataIndex-1));
    
        Xs((RecIndex-1)*N+1:RecIndex*N,dataIndex) = temValue(1:N).';
        
        temValue  = circshift(Wb_in(RecIndex,:),-(dataIndex-1));
        
        Xi((RecIndex-1)*N+1:RecIndex*N,dataIndex) = temValue(1:N).';
        
        temValue  = circshift(Noise(RecIndex,:),-(dataIndex-1));
    
        Xn((RecIndex-1)*N+1:RecIndex*N,dataIndex) = temValue(1:N).';
    
    end % for dataIndex = 1:L
    
end % for RecIndex = 1:M

% 加权

Ys_out  = w_opt'*Xs;
Yi_out  = w_opt'*Xi;
Yn_out  = w_opt'*Xn;

Ps_out  = sum(abs(Ys_out).^2)/L;
Pi_out  = sum(abs(Yi_out).^2)/L;
Pn_out  = sum(abs(Yn_out).^2)/L;

end
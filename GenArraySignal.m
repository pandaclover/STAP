%{
  ------------------- 宽带阵列信号建模 ------------------------------------
  1) 对接收信号继续FFT，在各个频点上乘以时延矢量，再转换回时域
  2) 在原有程序的基础上添加加窗和反加窗的操作，是否能改善仿真结果呢？
  --- 但是感觉是否加窗不影响最终结果
  3) 在MDL准则的测试程序中对这部分内容进行了重写
  4) 加窗之后会对settings.fs/2与-settings.fs/2这两个频点产生影响
  --- 使这两个频点上的阵列频域信号不再符合Y(f)= A(f)*X(f)的形式
  --- 为什么呢？
  --- 不过在实际接收机中肯定是要经过低通滤波将信号主带外的能量滤掉的

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   [S_in, Wb_in] = GenArraySignal(Xs, I_wb)

% 全局变量
global    settings;

% FFT点数和分段数
fftNum    = settings.N;
    
SegNum    = settings.M;
    
% 有用信号数
SigNum    = settings.SigNum;

% 宽带干扰信号数
WiNum     = settings.WBInNum;

% 天线阵元数
RecNum    = settings.RecNum;

% 产生接收阵列各个频点上的导向矢量
Alphaf    = ArraySteerVectorCalculate_ula();

% 加窗
h_w       = settings.hw.';                       % fftNum*1
Hw        = repmat(h_w, 1, SegNum);              % fftNum*SegNum

% 反加窗
h_wd      = circshift(h_w, -fftNum/2);
h_i       = 1./(h_w + h_wd);                     % fftNum*1
h_i       = h_i.';                               % 1*fftNum
H_inv     = repmat(h_i, RecNum, 1);              % RecNum*SegNum

% 初始化输出信号
S_in      = zeros(RecNum, fftNum*SegNum);
Wb_in     = zeros(RecNum, fftNum*SegNum);

%--------------------------------------------------------------------------
for index = 1:SigNum
    
    % 频域相移矩阵初始化
    Xs_f2     = zeros(RecNum, fftNum, SegNum);
    Xs_fd2    = zeros(RecNum, fftNum, SegNum);
    
    % 有用信号的时域信号
    temXs_t   = reshape(Xs(index,:), fftNum, SegNum);
    temXs_td  = circshift(temXs_t, -fftNum/2, 1);
    
    % 时域加窗进行FFT
    Xs_f      = fftshift(fft(temXs_t.*Hw, [], 1),1);
    Xs_fd     = fftshift(fft(temXs_td.*Hw, [], 1),1);
    
    % 对各个频点进行处理
    for fn = 1:fftNum
        
        % 当前频点的导向矢量
        Af             = Alphaf.Xs{1,index}(:,fn);
        
        % 导向矢量与频域信号相乘
        temValue       = Af.*Xs_f(fn,:);                  % RecNum*SegNum
        temValue_d     = Af.*Xs_fd(fn,:);          
        
        % 改变temValue的排列顺序，将其变为3维数据矩阵，以便直接赋值给Xs_f
        temValue       = permute(temValue,[1,3,2]);       % RecNum*1*SegNum
        temValue_d     = permute(temValue_d,[1,3,2]);
        
        Xs_f2(:,fn,:)  = temValue;
        Xs_fd2(:,fn,:) = temValue_d;
        
    end % for fn = 1:fftNum
    
    %----------------------------------------------------------------------
    % 将移相之后的频域信号转换到时域内
    for m = 1:SegNum
        
        Xs1 = ifft(fftshift(Xs_f2(:,:,m),2),[],2);
        Xs2 = ifft(fftshift(Xs_fd2(:,:,m),2),[],2);
        Xs2 = circshift(Xs2, settings.N/2, 2);
        
        % 反加窗
        S_in(:,(m-1)*fftNum+1:m*fftNum) = ...
            S_in(:,(m-1)*fftNum+1:m*fftNum) + (Xs1 + Xs2).*H_inv;
        
    end % for m = 1:SegNum
      
end % for index = 1:SigNum

for index = 1:WiNum

    % 频域相移矩阵初始化
    Iw_f2     = zeros(RecNum, fftNum, SegNum);
    Iw_fd2    = zeros(RecNum, fftNum, SegNum);

    % 提取宽带干扰时域信号
    temIw_t   = reshape(I_wb(index,:),fftNum,SegNum);

    % 延时支路
    temIw_td  = circshift(temIw_t, -fftNum/2, 1);

    % 时域加窗进行FFT
    Iw_f      = fftshift(fft(temIw_t.*Hw,[],1),1);
    Iw_fd     = fftshift(fft(temIw_td.*Hw,[],1),1);

    %----------------------------------------------------------------------
    % 对各个频点进行处理
    for fn = 1:fftNum
        
        % 当前频点的导向矢量
        Af             = Alphaf.WI{1,index}(:,fn);
        
        % 导向矢量与频域信号相乘
        temValue       = Af.*Iw_f(fn,:);                  % RecNum*SegNum
        temValue_d     = Af.*Iw_fd(fn,:);                 
        
        temValue       = permute(temValue,[1,3,2]);       % RecNum*1*SegNum  
        temValue_d     = permute(temValue_d,[1,3,2]);
        
        Iw_f2(:,fn,:)  = temValue;
        Iw_fd2(:,fn,:) = temValue_d; 
        
    end % for fn = 1:fftNum

    %----------------------------------------------------------------------
    % 将移相之后的频域信号转换到时域内
    for m = 1:SegNum
        
        W1 = ifft(fftshift(Iw_f2(:,:,m),2),[],2);
        W2 = ifft(fftshift(Iw_fd2(:,:,m),2),[],2);
        W2 = circshift(W2, settings.N/2, 2);
        
        % 反加窗
        Wb_in(:,(m-1)*fftNum+1:m*fftNum) = ... 
            Wb_in(:,(m-1)*fftNum+1:m*fftNum) + (W1 + W2).*H_inv;
        
    end % for m = 1:SegNum

end % for index = 1:WiNum

end
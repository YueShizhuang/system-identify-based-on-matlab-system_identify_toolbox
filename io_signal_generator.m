function [input,output] = io_signal_generator(Wfb,A8)
%此函数输入给定的主燃油和尾喷管面积，返回用于系统辨识的输入数据。
% Wfb =2.406;
% A8 =0.25771;
%% 生成逆M序列伪信号
Wfb = Wfb;%稳态值
N = [500,1,1];%生成信号长度是N，1通道,1个周期即可
% levels = [Wfb*0.98 Wfb*1.02];
prbs_level = 0.015;
levels = [Wfb-prbs_level Wfb+prbs_level];
band  = [0 1];
Wfb_input_prbs = idinput(N,'prbs',band,levels);
% c1 = xcorr(sr,'coeff');
%逆M序列生成（是否这样生成还有待学习）
%Wfb_input_prbs =flipud(Wfb_input_prbs);
% figure(1)
% stairs(Wfb_input_prbs)
%谱密度分析
% Pxx = 10*log(abs(fft(sr1).^2)/length(sr1));
% f = (0:length(Pxx)-1)/length(Pxx);
% figure(3)
% plot(f,Pxx)
% A8 = A8;%稳态值
% levels = [A8*0.98 A8*1.02];
% band  = [0 1];
% A8_input_prbs = idinput(N,'prbs',band,levels);
%% 拼接阶跃信号
Wfb_input_step = ones(501,1) * Wfb*1;
A8_input = ones(501*3,1) * A8;
%% 拼接正弦信号
t = 0:0.02:10;
Wfb_input_sind = ((2.406*0.01)*sin(5*t)+Wfb)';
Wfb_input = [Wfb_input_prbs;Wfb_input_step;Wfb_input_sind];
% Wfb_input = [Wfb_input_prbs;Wfb_input_step];
%% 初始化，加载模型
libName='EngineDLL';
libNamePath='EngineDLL.dll';
libNameHeader='EngineDLL.h';
if ~libisloaded(libName)
    loadlibrary(libNamePath,libNameHeader);
    display('model is loaded！');
end
%% 模型输入
dstep=0.02;    %仿真步长（单位：s）
H=8;           %高度（km）
Ma=1.2;          %马赫数
P0=101.325;    %大气压力（kPa）
T0=288.15;     %大气温度（K）
deltaPs=0;     %静压修正（kPa）
deltaTs=0;     %静温修正（K）
Wfa=0;         %加力燃油(kg/s)
A9=0.31441;    %喷口面积(m^2)
FVGP=0;        %风扇导叶角度
CVGP=0;        %压气机导叶角度
SLJ=0;         %矢量角
FWJ=0;         %方位角
data_in_Steady=[H Ma P0 T0 deltaPs deltaTs Wfb  Wfa  A8 A9 FVGP CVGP SLJ FWJ];
data_out_Steady=zeros(1,100);
data_out_Dynamic=zeros(1,100);
data_out_Dynamic1=zeros(1,100);
%% 调用模型
[data_in_Steady,data_out_Steady]=calllib(libName,'Steady',data_in_Steady,data_out_Steady);    %调用稳态模型

Sensornum=19;            %输出参数个数
Simulatetime=30;        %仿真时间

Simulatenum=Simulatetime/dstep+1;            %仿真步数
Simulatedata=zeros(Simulatenum,Sensornum);   %存放输出参数
for i=1:Simulatenum  %以下动态仿真，可以根据需要给出Wfb或A8随时间的动态变化
    data_in_Dynamic=[dstep H Ma P0 T0 deltaPs deltaTs Wfb_input(i) Wfa A8_input(i) A9 FVGP CVGP SLJ FWJ];
    [data_in_Dynamic,data_out_Dynamic]=calllib(libName,'Dynamic',data_in_Dynamic,data_out_Dynamic);     %调用动态模型
    Simulatedata(i,:)=[data_out_Dynamic(1,1:19)];  %输出参数
end

pai = Simulatedata(:,11) / Simulatedata(:,19);
stad_pai = 4.11259393097577;
%% 卸载模型
if libisloaded(libName)
    unloadlibrary(libName);
    display('unload model！');
end
% input = [Wfb_input(1:1501)/Wfb,A8_input(1:1501)/A8];                      %归一化，输入选择Wfb和A8的阶跃输入
output = [Simulatedata(:,1)/9800,Simulatedata(:,2)/12700,pai(:,1)/stad_pai];%归一化,选择输出分别为低压转速、高压转速和增压比
input = [Wfb_input(1:1501),A8_input(1:1501)];                                             %输入选择Wfb&A8的阶跃输入

end
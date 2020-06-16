%选定输入为拼接信号的数据源，用系统辨识的方法得到状态空间方程
clear;
%% 模型输入
Wfb=2.406;     %主燃油(kg/s)
A8=0.25771;    %喉道面积(m^2)
%% 系统辨识输入数据
[input,output] = io_signal_generator(Wfb,A8);
plot(output)
%% 系统辨识
%% 数据源
Ts = 0.02;                                                                 %采样时间是0.02s
ze1 = iddata(output,input,Ts);                                             % 创建一个iddata对象
ze = ze1(1:1500);                                                            %数据子空间选择
%% 建立模型类
A = zeros(2,2);
B = zeros(2,2);
C = [1,0;0,1;0,0]
D = zeros(3,2);
K = zeros(2,3);
m = idss(A,B,C,D,K,'Ts',0);                                                %建立m状态空间模型

%固定一些参数的自由度
m.Structure.c.Free(1,1) = false;
m.Structure.c.Free(1,2) = false;
m.Structure.c.Free(2,1) = false;
m.Structure.c.Free(2,2) = false;
m.Structure.d.Free(1,1) = false;
m.Structure.d.Free(1,2) = false;
m.Structure.d.Free(2,1) = false;
m.Structure.d.Free(2,2) = false;
m.Structure.d.Free(3,1) = true;
m.Structure.d.Free(3,2) = true;
m.Structure.k.Free = false;
%% 设置辨识的准则并第一次辨识
opt = ssestOptions;
opt.Focus = 'simulation';
opt.SearchMethod = 'lm';
opt.InitialState =  'backcast';
mCT1 = ssest(ze,m,opt)
figure(2)
compare(mCT1,ze)
%% 储存数据
re_A = mCT1.A;
re_A_1 = [re_A(1) re_A(3) re_A(2) re_A(4)];
re_B = mCT1.B;
re_B_1 = [re_B(1) re_B(3) re_B(2) re_B(4)];
re_C = mCT1.C;
re_C_1 = [re_C(1) re_C(4) re_C(2) re_C(5) re_C(3) re_C(6)];
re_D = mCT1.D;
re_D_1= [re_D(1) re_D(4) re_D(2) re_D(5) re_D(3) re_D(6)];
re = [re_A_1,re_B_1,re_C_1,re_D_1];

%% 阶跃验证
AA =  mCT1.A;
BB =  mCT1.B;
CC =  mCT1.C;
DD =  mCT1.D;

non_out = nonlinear_output(Wfb,A8);
t=0:0.02:10;
num=size(t,2);
x0=[non_out(1,1);non_out(1,2)];
uu(:,1:3)=lsim(ss(AA,BB,CC,DD),[Wfb;A8]*ones(1,num),t,x0);
figure(3)
plot(t,uu(:,2),t,non_out(:,2))
legend('linear','nonlinear');
xlabel('Time(s)');ylabel('\n_H(r/min)');
figure(4)
plot(t,uu(:,3),t,non_out(:,3))
legend('linear','nonlinear');
xlabel('Time(s)');ylabel('\pi');
figure(5)
plot(t,non_out(:,2)-uu(:,2))
title('Nh_error')
figure(6)
plot(t,non_out(:,3)-uu(:,3))
title('pi_error')
 %% 保存图片
 s=strcat('mkdir Wfb_',num2str(Wfb),'_A8_',num2str(A8));
 system(s);
 s3=strcat('Wfb_',num2str(Wfb),'_A8_',num2str(A8),'/3.fig');
 s4=strcat('Wfb_',num2str(Wfb),'_A8_',num2str(A8),'/4.fig');
 s5=strcat('Wfb_',num2str(Wfb),'_A8_',num2str(A8),'/5.fig');
 s6=strcat('Wfb_',num2str(Wfb),'_A8_',num2str(A8),'/6.fig');
 saveas(3,s3,'fig');
 saveas(4,s4,'fig');
 saveas(5,s5,'fig');
 saveas(6,s6,'fig');
%  close all;

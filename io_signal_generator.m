function [input,output] = io_signal_generator(Wfb,A8)
%�˺��������������ȼ�ͺ�β����������������ϵͳ��ʶ���������ݡ�
% Wfb =2.406;
% A8 =0.25771;
%% ������M����α�ź�
Wfb = Wfb;%��ֵ̬
N = [500,1,1];%�����źų�����N��1ͨ��,1�����ڼ���
% levels = [Wfb*0.98 Wfb*1.02];
prbs_level = 0.015;
levels = [Wfb-prbs_level Wfb+prbs_level];
band  = [0 1];
Wfb_input_prbs = idinput(N,'prbs',band,levels);
% c1 = xcorr(sr,'coeff');
%��M�������ɣ��Ƿ��������ɻ��д�ѧϰ��
%Wfb_input_prbs =flipud(Wfb_input_prbs);
% figure(1)
% stairs(Wfb_input_prbs)
%���ܶȷ���
% Pxx = 10*log(abs(fft(sr1).^2)/length(sr1));
% f = (0:length(Pxx)-1)/length(Pxx);
% figure(3)
% plot(f,Pxx)
% A8 = A8;%��ֵ̬
% levels = [A8*0.98 A8*1.02];
% band  = [0 1];
% A8_input_prbs = idinput(N,'prbs',band,levels);
%% ƴ�ӽ�Ծ�ź�
Wfb_input_step = ones(501,1) * Wfb*1;
A8_input = ones(501*3,1) * A8;
%% ƴ�������ź�
t = 0:0.02:10;
Wfb_input_sind = ((2.406*0.01)*sin(5*t)+Wfb)';
Wfb_input = [Wfb_input_prbs;Wfb_input_step;Wfb_input_sind];
% Wfb_input = [Wfb_input_prbs;Wfb_input_step];
%% ��ʼ��������ģ��
libName='EngineDLL';
libNamePath='EngineDLL.dll';
libNameHeader='EngineDLL.h';
if ~libisloaded(libName)
    loadlibrary(libNamePath,libNameHeader);
    display('model is loaded��');
end
%% ģ������
dstep=0.02;    %���沽������λ��s��
H=8;           %�߶ȣ�km��
Ma=1.2;          %�����
P0=101.325;    %����ѹ����kPa��
T0=288.15;     %�����¶ȣ�K��
deltaPs=0;     %��ѹ������kPa��
deltaTs=0;     %����������K��
Wfa=0;         %����ȼ��(kg/s)
A9=0.31441;    %������(m^2)
FVGP=0;        %���ȵ�Ҷ�Ƕ�
CVGP=0;        %ѹ������Ҷ�Ƕ�
SLJ=0;         %ʸ����
FWJ=0;         %��λ��
data_in_Steady=[H Ma P0 T0 deltaPs deltaTs Wfb  Wfa  A8 A9 FVGP CVGP SLJ FWJ];
data_out_Steady=zeros(1,100);
data_out_Dynamic=zeros(1,100);
data_out_Dynamic1=zeros(1,100);
%% ����ģ��
[data_in_Steady,data_out_Steady]=calllib(libName,'Steady',data_in_Steady,data_out_Steady);    %������̬ģ��

Sensornum=19;            %�����������
Simulatetime=30;        %����ʱ��

Simulatenum=Simulatetime/dstep+1;            %���沽��
Simulatedata=zeros(Simulatenum,Sensornum);   %����������
for i=1:Simulatenum  %���¶�̬���棬���Ը�����Ҫ����Wfb��A8��ʱ��Ķ�̬�仯
    data_in_Dynamic=[dstep H Ma P0 T0 deltaPs deltaTs Wfb_input(i) Wfa A8_input(i) A9 FVGP CVGP SLJ FWJ];
    [data_in_Dynamic,data_out_Dynamic]=calllib(libName,'Dynamic',data_in_Dynamic,data_out_Dynamic);     %���ö�̬ģ��
    Simulatedata(i,:)=[data_out_Dynamic(1,1:19)];  %�������
end

pai = Simulatedata(:,11) / Simulatedata(:,19);
stad_pai = 4.11259393097577;
%% ж��ģ��
if libisloaded(libName)
    unloadlibrary(libName);
    display('unload model��');
end
% input = [Wfb_input(1:1501)/Wfb,A8_input(1:1501)/A8];                      %��һ��������ѡ��Wfb��A8�Ľ�Ծ����
output = [Simulatedata(:,1)/9800,Simulatedata(:,2)/12700,pai(:,1)/stad_pai];%��һ��,ѡ������ֱ�Ϊ��ѹת�١���ѹת�ٺ���ѹ��
input = [Wfb_input(1:1501),A8_input(1:1501)];                                             %����ѡ��Wfb&A8�Ľ�Ծ����

end
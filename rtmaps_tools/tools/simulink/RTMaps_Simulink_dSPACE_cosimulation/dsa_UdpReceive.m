% History
% 2.0.1: Bugfix: close all sockets in Terminate.

function dsa_UdpReceive(block)

setup(block);

function setup(block)

outputWidth = block.DialogPrm(2).Data;
sampleTime  = block.DialogPrm(3).Data;

% Register number of ports
block.NumInputPorts  = 0;
block.NumOutputPorts = 3;

block.OutputPort(1).DatatypeID  = 0;
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(1).Dimensions  = 1;
block.OutputPort(1).SampleTime = [sampleTime 0];

block.OutputPort(2).DatatypeID  = 0;
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';
block.OutputPort(2).Dimensions  = 1;
block.OutputPort(2).SampleTime = [sampleTime 0];

block.OutputPort(3).DatatypeID  = 7; % UInt32
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';
block.OutputPort(3).Dimensions  = ceil(outputWidth/4);
block.OutputPort(3).SampleTime = [sampleTime 0];

% Register parameters
block.NumDialogPrms = 5;
%block.DialogPrmsTunable = {'Tunable','Nontunable','SimOnlyTunable'};

block.SetAccelRunOnTLC(false);

block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('Terminate', @Terminate);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
%endfunction

function SetOutputPortSampleTime(block, idx, st)
% this function is required, but not used

function DoPostPropSetup(block)
block.NumDworks = 1;
block.Dwork(1).Name = 'thisBlocksIdx';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0; % double
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = false;
%endfunction

function Start(block)
global g_dsa_UdpBlocksetData;

import java.net.InetAddress
import java.net.DatagramSocket

portNumber = block.DialogPrm(1).Data;
rxTimeout    = block.DialogPrm(4).Data;
rxBufferSize = block.DialogPrm(5).Data;
g_dsa_UdpBlocksetData{end+1}.socket   = DatagramSocket(portNumber);
thisBlocksIdx = length(g_dsa_UdpBlocksetData);
g_dsa_UdpBlocksetData{thisBlocksIdx}.socket.setSoTimeout(rxTimeout); % timeout in ms
g_dsa_UdpBlocksetData{thisBlocksIdx}.socket.setReceiveBufferSize(rxBufferSize);
block.Dwork(1).Data = thisBlocksIdx;
%endfunction

function Terminate(~)
global g_dsa_UdpBlocksetData;

for idx = 1 : length(g_dsa_UdpBlocksetData)
    g_dsa_UdpBlocksetData{idx}.socket.close;
end
g_dsa_UdpBlocksetData = [];

%endfunction

function Outputs(block)
global g_dsa_UdpBlocksetData;

import java.net.DatagramPacket

thisBlocksIdx = block.Dwork(1).Data;
outputWidth = block.DialogPrm(2).Data;
maxPacketSize = outputWidth;
try
    packet = DatagramPacket(zeros(1,maxPacketSize,'uint8'),maxPacketSize);
    g_dsa_UdpBlocksetData{thisBlocksIdx}.socket.receive(packet);
    i8Data = packet.getData;
    u32Data = typecast(i8Data, 'uint32');
    block.OutputPort(1).Data = 1; % new data
    block.OutputPort(2).Data = packet.getLength;
    block.OutputPort(3).Data = u32Data;
catch % timeout occured
    block.OutputPort(1).Data = 0; % no new data
end

%endfunction

function SetInpPortFrameData(block, idx, fd)

if fd ~= 0
    disp('Frame based inputs??');
end
block.InputPort(idx).SamplingMode = fd;
block.OutputPort(1).SamplingMode  = fd;
block.OutputPort(2).SamplingMode  = fd;

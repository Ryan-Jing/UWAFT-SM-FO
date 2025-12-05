function dsa_UdpSend(block)

setup(block);


function setup(block)

% Register number of ports
block.NumInputPorts  = 3;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

% Override input port properties
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).SamplingMode = 'Sample';
block.InputPort(1).Dimensions  = 1;

block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).SamplingMode = 'Sample';
block.InputPort(2).Dimensions  = 1;

block.InputPort(3).DatatypeID  = 7;  % uint32
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).SamplingMode = 'Sample';

block.OutputPort(1).DatatypeID  = 0; % dpouble
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(1).Dimensions  = 1;

% Register parameters
block.NumDialogPrms = 2;
%block.DialogPrmsTunable = {'Tunable','Nontunable','SimOnlyTunable'};

block.SampleTimes = [-1 0];
block.SetAccelRunOnTLC(false);

block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('Terminate', @Terminate);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
%endfunction

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
hostName   = block.DialogPrm(1).Data;
g_dsa_UdpBlocksetData{end+1}.hostAddress = InetAddress.getByName(hostName);
thisBlocksIdx = length(g_dsa_UdpBlocksetData);
g_dsa_UdpBlocksetData{thisBlocksIdx}.socket = DatagramSocket;
block.Dwork(1).Data = thisBlocksIdx;
%endfunction

function Terminate(block)
global g_dsa_UdpBlocksetData;

for idx = 1 : length(g_dsa_UdpBlocksetData)
    g_dsa_UdpBlocksetData{idx}.socket.close;
end
g_dsa_UdpBlocksetData = [];
%endfunction

function Outputs(block)
global g_dsa_UdpBlocksetData;

enable = block.InputPort(1).Data;

if enable ~= 0
    import java.net.DatagramPacket

    messageSize = block.InputPort(2).Data;

    thisBlocksIdx = block.Dwork(1).Data;
    portNumber = block.DialogPrm(2).Data;
    u32Data = block.InputPort(3).Data;
    i8Data = typecast(u32Data, 'int8');
    dataSize = size(i8Data, 1);
    if messageSize > dataSize
        i8Data = [i8Data; zeros(messageSize-dataSize, 1)];
    end
    packet = DatagramPacket(i8Data(1:messageSize), messageSize, g_dsa_UdpBlocksetData{thisBlocksIdx}.hostAddress, portNumber);
    g_dsa_UdpBlocksetData{thisBlocksIdx}.socket.send(packet);
end
block.OutputPort(1).Data = 0;
%endfunction


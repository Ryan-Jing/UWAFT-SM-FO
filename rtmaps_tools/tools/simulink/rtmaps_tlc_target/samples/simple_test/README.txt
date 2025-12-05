
A simple example to test the code generation using the RTMaps TLC Target for Simulink.

The the model set the outport value to twice the input's.
It is composed of 1 Inport , 1 Gain (with gain=2) and 1 Outport.
The Inport is connected to the Gain's input and Outport is connected to the Gain's output.

In order to generate an RTMaps component

1. Install the RTMaps target using "install_rtmaps_target.m":
    >> install_rtmaps_target

2. Make sure the same C and C++ compiler is selected using:
    >> mex -setup C
    >> mex -setup C++

3. Run "run_simple_test.m" to create a temporary test model and generate
   the corresponding "simple_test.pck" from it:
    >> run_simple_test

The generated package can be tested using the "simple_test.rtd" diagram in RTMaps

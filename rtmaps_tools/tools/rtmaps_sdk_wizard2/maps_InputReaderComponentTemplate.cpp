////////////////////////////////////////////////////////////////////////////////
//     This file is part of RTMaps                                            //
//     Copyright (c) Intempora S.A. All rights reserved.                      //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////
// RTMaps SDK Template Component
////////////////////////////////

// This template component reads integers from two inputs and outputs them as a vector.
// It uses the Input Reader library to handle component inputs in a safe and straightforward manner.

// The component generates a new vector each time a new piece of data arrives on the first input.
// This is called the "Triggered" strategy. More strategies can be used easily thanks 
// to the Input Reader library. You can find information on this in the Input Reader documentation.
// It is located at the following location relative to your RTMaps installation folder: packages/rtmaps_input_reader/doc/. 
// More component samples are available at packages/rtmaps_input_reader/samples.

#include "maps_InputReaderComponentTemplate.h"

//We declare one input with FiFoReader type, then one input with SamplingReader type.
MAPS_BEGIN_INPUTS_DEFINITION(MAPSInputReaderComponentTemplate)
    MAPS_INPUT("input1_trigger",MAPS::FilterInteger32,MAPS::FifoReader)
    MAPS_INPUT("input2_resampling",MAPS::FilterInteger32,MAPS::SamplingReader)
MAPS_END_INPUTS_DEFINITION

// We declare 1 output for vectors of size 2.
MAPS_BEGIN_OUTPUTS_DEFINITION(MAPSInputReaderComponentTemplate)
    MAPS_OUTPUT("vectorOut",MAPS::Integer32,nullptr,nullptr,2)
MAPS_END_OUTPUTS_DEFINITION

#define IDX_O_OUTPUT 0

MAPS_BEGIN_PROPERTIES_DEFINITION(MAPSInputReaderComponentTemplate)
MAPS_END_PROPERTIES_DEFINITION

MAPS_BEGIN_ACTIONS_DEFINITION(MAPSInputReaderComponentTemplate)
MAPS_END_ACTIONS_DEFINITION

//Multiple inputs components have to be threaded. Don't allow sequential behavior.
MAPS_COMPONENT_DEFINITION(MAPSInputReaderComponentTemplate,"InputReaderComponentTemplate","1.0.0",128,
              MAPS::Threaded,MAPS::Threaded,
              2, // Nb of inputs
              1, // Nb of outputs
              0, // Nb of properties
              0) // Nb of actions

void MAPSInputReaderComponentTemplate::Birth()
{
    // Create a new input reader using the "Triggered" policy.
    // The "Triggered" policy waits for new data samples to be available
    // on its "trigger" input (which is the "input1_trigger" input in this sample)
    // then, it reads the data samples of the other inputs
    // ("input2_resampling" in this sample) and calls the user-provided callback
    m_inputReader = MAPS::MakeInputReader::Triggered(
        this,

        // The input reader will first wait for data on this input
        Input("input1_trigger"),

        // TriggerKind::DataInput means that we want to access the "value" of the data of the trigger input in the callback.
        // In this case, the trigger input MUST be added to the list of data inputs (see input list argument)
        MAPS::InputReaderOption::Triggered::TriggerKind::DataInput,
        // SamplingBehavior::WaitForAllInputs means that the data callback will be called
        // only if all inputs have received at least one sample since the beginning of the run
        MAPS::InputReaderOption::Triggered::SamplingBehavior::WaitForAllInputs,

        // The list of inputs to read.
        // You can pass in any contiguous sequence of "MAPSInput*" elements
        // that can be converted to a `MAPS::ArrayView<MAPSInput*>`
        // Examples of such sequences are: `std::vector<MAPSInput*>`, `std::array<MAPSInput*, N>`, `MAPSInput* someArray[N]`
        // Here, we pass in a temporary `std::array<MAPSInput*, 2>`
        MAPS::MakeArray(&Input("input1_trigger"), &Input("input2_resampling")),  // The data samples received on these inputs will be passed to the callback

        // This callback will be called when data was read from the trigger AND the data inputs.
        // Here, we demonstrate the use of a member function pointer as a data callback
        &MAPSInputReaderComponentTemplate::ProcessData
    );
}

void MAPSInputReaderComponentTemplate::Core()
{
    m_inputReader->Read();
}

void MAPSInputReaderComponentTemplate::Death()
{
    m_inputReader.reset();
}

void MAPSInputReaderComponentTemplate::ProcessData(MAPSTimestamp ts, MAPS::InputElt<int32_t> inElt1, MAPS::InputElt<int32_t> inElt2)
{
    // First make an OutputGuard object in which we can write the result to be output
    MAPS::OutputGuard<int32_t> outGuard{this, Output(IDX_O_OUTPUT)};

    // Generate the output vector
    outGuard.Data(0) = inElt1.Data();
    outGuard.Data(1) = inElt2.Data();

    // IMPORTANT: Specify the number of valid elements in the output vector
    outGuard.VectorSize() = 2;

    // IMPORTANT: Transfer the timestamp
    outGuard.Timestamp() = ts;
}

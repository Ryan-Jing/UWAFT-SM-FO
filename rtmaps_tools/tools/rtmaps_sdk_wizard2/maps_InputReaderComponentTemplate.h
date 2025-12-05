////////////////////////////////////////////////////////////////////////////////
//     This file is part of RTMaps                                            //
//     Copyright (c) Intempora S.A. All rights reserved.                      //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////
// SDK Programmer samples
////////////////////////////////

#pragma once

// Includes maps sdk library header
#include <maps.hpp>
// Includes the MAPS::InputReader class and its dependencies
#include <maps/input_reader/maps_input_reader.hpp>

// Declares a new MAPSComponent child class
class MAPSInputReaderComponentTemplate : public MAPSComponent
{
    // Use standard header definition macro
    MAPS_COMPONENT_STANDARD_HEADER_CODE(MAPSInputReaderComponentTemplate)
private:
    // Declare an input reader
    std::unique_ptr<MAPS::InputReader> m_inputReader;

    // Place here your specific methods and attributes

    void ProcessData(MAPSTimestamp ts, MAPS::InputElt<int32_t> inElt1, MAPS::InputElt<int32_t> inElt2);
};

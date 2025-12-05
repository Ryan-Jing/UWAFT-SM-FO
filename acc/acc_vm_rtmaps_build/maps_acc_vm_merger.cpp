#include "maps_acc_vm_merger.h"
#include <algorithm>
#include <cstring>
#include <iterator>
#include <type_traits>
#if _WIN32
#include <string.h>                    // _stricmp()
#else
#include <strings.h>                   // strcasecmp()
#endif

#include <maps_type_traits.hpp>
#include <maps_io_access.hpp>

using namespace acc_vm_rtmaps_tlc_helper;

// Use the macros to declare the inputs
MAPS_BEGIN_INPUTS_DEFINITION(ComponentClass)
// MISC ////////////////////////////////////////////////////////////////////////////////////////
  MAPS_INPUT("i_trigger", MAPS::FilterAny, MAPS::FifoReader)
// FIFO ////////////////////////////////////////////////////////////////////////////////////////
// bool
  MAPS_INPUT("i_fifo_bool" , MAPS::GetTypeFilter< to_rtmaps_type_t<bool > >(),
             MAPS::FifoReader)
// signed ints
  MAPS_INPUT("i_fifo_int8_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<int8_t > >(),
             MAPS::FifoReader)
  MAPS_INPUT("i_fifo_int16_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<int16_t > >
             (), MAPS::FifoReader)
  MAPS_INPUT("i_fifo_int32_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<int32_t > >
             (), MAPS::FifoReader)
  MAPS_INPUT("i_fifo_int64_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<int64_t > >
             (), MAPS::FifoReader)
// unsigned ints
  MAPS_INPUT("i_fifo_uint8_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<uint8_t > >
             (), MAPS::FifoReader)
  MAPS_INPUT("i_fifo_uint16_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<uint16_t>
             >(), MAPS::FifoReader)
  MAPS_INPUT("i_fifo_uint32_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<uint32_t>
             >(), MAPS::FifoReader)
  MAPS_INPUT("i_fifo_uint64_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<uint64_t>
             >(), MAPS::FifoReader)
// floats
  MAPS_INPUT("i_fifo_float" , MAPS::GetTypeFilter< to_rtmaps_type_t<float > >(),
             MAPS::FifoReader)
  MAPS_INPUT("i_fifo_double" , MAPS::GetTypeFilter< to_rtmaps_type_t<double > >(),
             MAPS::FifoReader)
// other
  MAPS_INPUT("i_fifo_struct" , MAPS::FilterStructure, MAPS::FifoReader) // structs
// SAMPLING ////////////////////////////////////////////////////////////////////////////////////
// bool
  MAPS_INPUT("i_sampling_bool" , MAPS::GetTypeFilter< to_rtmaps_type_t<bool > >(),
             MAPS::SamplingReader)
// signed ints
  MAPS_INPUT("i_sampling_int8_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<int8_t >
             >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_int16_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             int16_t > >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_int32_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             int32_t > >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_int64_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             int64_t > >(), MAPS::SamplingReader)
// unsigned ints
  MAPS_INPUT("i_sampling_uint8_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             uint8_t > >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_uint16_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             uint16_t> >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_uint32_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             uint32_t> >(), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_uint64_t" , MAPS::GetTypeFilter< to_rtmaps_type_t<
             uint64_t> >(), MAPS::SamplingReader)
// floats
  MAPS_INPUT("i_sampling_float" , MAPS::GetTypeFilter< to_rtmaps_type_t<float > >
             (), MAPS::SamplingReader)
  MAPS_INPUT("i_sampling_double" , MAPS::GetTypeFilter< to_rtmaps_type_t<double >
             >(), MAPS::SamplingReader)
// other
  MAPS_INPUT("i_sampling_struct" , MAPS::FilterStructure, MAPS::SamplingReader) // structs
  MAPS_END_INPUTS_DEFINITION
#define I_IDX_TRIGGER                  0

// Use the macros to declare the outputs
MAPS_BEGIN_OUTPUTS_DEFINITION(ComponentClass)
  MAPS_OUTPUT("o_struct", MAPS::Structure, nullptr, nullptr, 0)
  MAPS_END_OUTPUTS_DEFINITION
#define O_IDX_DATA                     0

// Use the macros to declare the properties
MAPS_BEGIN_PROPERTIES_DEFINITION(ComponentClass)
  MAPS_PROPERTY_READ_ONLY("p_data_types", "")
  MAPS_PROPERTY_ENUM("p_data_type", "", -1, true, false)
  MAPS_PROPERTY_READ_ONLY("p_data_type_info", "")
  MAPS_PROPERTY("p_field_selection_regex", "", false, false)
  MAPS_PROPERTY_ENUM("p_reading_policy",
                     "Synchronized"
                     "|Periodic Sampling"
                     "|Reactive"
                     "|Triggered"
                     "|Wait For All Inputs"
                     "|Periodic Sampling While Post-Processing"
                     , 2, false, false)
  MAPS_PROPERTY("p_sampling_period_us" , 1000000, false, false)
  MAPS_PROPERTY("p_sync_tolerance_us" , 0, false, false)
  MAPS_END_PROPERTIES_DEFINITION
#define P_IDX_OUTPUT_TYPES             0
#define P_IDX_OUTPUT_TYPE              1
#define P_IDX_OUTPUT_TYPE_INFO         2
#define P_IDX_INPUT_SELECTION_REGEX    3
#define P_IDX_READING_POLICY           4

// Use the macros to declare the actions
MAPS_BEGIN_ACTIONS_DEFINITION(ComponentClass)
  MAPS_ACTION2("a_selected_data_type_info", &ComponentClass::
               a_selected_output_type_info, true)
  MAPS_END_ACTIONS_DEFINITION
  // Use the macros to declare this component behavior
  MAPS_COMPONENT_DEFINITION(ComponentClass, ComponentName, ComponentVersion, 128,
  MAPS::Threaded, MAPS::Threaded,
  0,                                   // inputs
  0,                                   // outputs
  5,                                   // properties
  -1)                                  // actions
  void ComponentClass::a_selected_output_type_info(MAPSModule* m, int)
{
  static_cast<ComponentClass*>(m)->reportSelectedOutputTypeInfo();
}

void ComponentClass::reportSelectedOutputTypeInfo()
{
  if (m_outputStruct == nullptr) {
    ReportError("No output type selected");
  } else {
    ReportInfo(MAPSStreamedString()
               << "Selected Output Type Info:\n"
               << m_outputStruct->toString().c_str()
               );
  }
}

void ComponentClass::Set(MAPSProperty& p, const MAPSEnumStruct& v)
{
  if (&p == &Property(P_IDX_OUTPUT_TYPE) || &p == &Property(P_IDX_READING_POLICY))// @pattern update_enum
  {
    MAPSModule::Set(p, v.selectedEnum);
    return;
  }

  MAPSComponent::Set(p, v);
}

void ComponentClass::Set(MAPSProperty& p, const MAPSString& v)
{
  if (&p == &Property(P_IDX_OUTPUT_TYPE) || &p == &Property(P_IDX_READING_POLICY))// @pattern update_enum
  {
    if (MAPSEnumStruct::IsEnumString(v)) {
      MAPSEnumStruct enm;
      enm.FromString(v);
      MAPSModule::Set(p, enm.selectedEnum);
      return;
    }
  }

  MAPSComponent::Set(p, v);
}

void ComponentClass::Set(MAPSProperty& p, MAPSInt64 v)
{
  if (HasProperty("p_sampling_period_us") && (&p == &Property(
        "p_sampling_period_us"))) {
    if (v <= 0) {
      ReportError("p_sampling_period_us must be > 0");
      return;
    }
  } else if (HasProperty("p_sync_tolerance_us") && (&p == &Property(
               "p_sync_tolerance_us"))) {
    if (v < 0) {
      ReportError("p_sync_tolerance_us must be >= 0");
      return;
    }
  }

  MAPSComponent::Set(p, v);
}

void ComponentClass::Dynamic()
{
  DirectSet(Property(P_IDX_OUTPUT_TYPES), acc_vm_rtmaps_tlc_helper::
            typeListToMapsString_lite( acc_vm_rtmaps_tlc_types::getStructs() ));
  fillOutputTypeEnum();
  if (GetIntegerProperty(P_IDX_OUTPUT_TYPE) < 0) {
    return;
  }

  const std::string output_type = toString(GetStringProperty(P_IDX_OUTPUT_TYPE));
  if (output_type.empty()) {
    return;
  }

  m_outputStruct = & acc_vm_rtmaps_tlc_types::getStruct(output_type);
  if (m_outputStruct == nullptr) {
    ReportError(MAPSStreamedString() << "Output struct [" << output_type.c_str()
                << "] not found");
    return;
  }

  DirectSet(Property(P_IDX_OUTPUT_TYPE_INFO), MAPSString
            (m_outputStruct->toString_lite().c_str()));
  m_input_selection_regex = toString(GetStringProperty
    (P_IDX_INPUT_SELECTION_REGEX));
  m_reading_policy = static_cast<ReadingPolicy>(GetIntegerProperty
    (P_IDX_READING_POLICY));
  createProperties();
  createInputs();
  auto& output = NewOutput(O_IDX_DATA, MAPSString("o_") + output_type.c_str());
  output.SetTypeName(output_type.c_str());
}

void ComponentClass::fillOutputTypeEnum()
{
  using acc_vm_rtmaps_tlc_types::Struct;
  using acc_vm_rtmaps_tlc_types::getStructs;
  fillEnumPropertyWithContainerValues(
    this,
    Property(P_IDX_OUTPUT_TYPE),
    getStructs(),
    [] (const Struct& st)
  {
    return MAPSString(st.name.c_str());
  }

  ,
    true
    );
}

void ComponentClass::createProperties()
{
  switch (m_reading_policy)
  {
   case ReadingPolicy::PeriodicSampling:
   case ReadingPolicy::PeriodicSamplingWhilePostProcessing:
    NewProperty("p_sampling_period_us");
    break;

   case ReadingPolicy::Synchronized:
    NewProperty("p_sync_tolerance_us");
    break;

   default:
    break;
  }
}

void ComponentClass::createInputs()
{
  using std::string;
  using acc_vm_rtmaps_tlc_types::getStructs;
  using acc_vm_rtmaps_tlc_types::Struct;
  m_inputMap.clear();
  const auto is_enabled = [this] (const string& inputName)
  {
    MAPSRegExp selRx(m_input_selection_regex.empty()
                     ? "" : m_input_selection_regex.c_str(),
                     MAPSRegExp::OptCaseless
                     );
    return selRx.Match(inputName.c_str());
  }

  ;
  if (m_reading_policy == ReadingPolicy::Triggered) {
    NewInput("i_trigger");
  }

  for (auto& field : m_outputStruct->fields) {
    if (is_enabled(field.name)) {
      m_inputMap.emplace(createInputMapEntry(field));
    }
  }
}

template <typename TField_ActualType>
  ComponentClass::InputWrapper::FieldWriterCallback ComponentClass::
  makeFieldWriter_Primitive(
  const acc_vm_rtmaps_tlc_types::Field& field)
{
  using Field_RTMapsType = to_rtmaps_type_t< to_fixed_width_type_t<
    TField_ActualType> >;
  return [field] (const void* const srcFieldPtr_, void* const dstStructPtr_)
  {
    auto* srcFieldPtr = static_cast<const Field_RTMapsType*>(srcFieldPtr_);
    auto* dstFieldPtr = reinterpret_cast<TField_ActualType*>(static_cast<uint8_t*>
      (dstStructPtr_) + field.offset);
    for (size_t idx = 0; idx < field.capacity; ++idx) {
      dstFieldPtr[idx] = staticCast_primitiveType<TField_ActualType>
        (srcFieldPtr[idx]);
    }
  }

  ;
}

ComponentClass::InputWrapper::FieldWriterCallback ComponentClass::
  makeFieldWriter_Struct(
  const acc_vm_rtmaps_tlc_types::Field& field)
{
  return [field] (const void* const srcFieldPtr, void* const dstStructPtr)
  {
    std::memcpy(
                static_cast<uint8_t*>(dstStructPtr) + field.offset,
                srcFieldPtr,
                field.size * field.capacity
                );
  }

  ;
}

std::pair<MAPSInput*, ComponentClass::InputWrapper> ComponentClass::
  createInputMapEntry(
                      const acc_vm_rtmaps_tlc_types::Field& field)
{
  const std::string inputReaderType = [this] {
    switch (m_reading_policy)
    {
      case ReadingPolicy::PeriodicSampling:
      case ReadingPolicy::Triggered:
      return "sampling";

     default:
      return "fifo";
    }
  }();

  const auto newInput = [&] (const std::string& modelNameBase, const std::string
    & inputNameBase)
  {
    const std::string modelName = std::string("i_") + inputReaderType + "_" +
      modelNameBase;
    const std::string inputName = std::string("i_") + inputNameBase;
    return &NewInput(modelName.c_str(), inputName.c_str());
  }

  ;
  InputWrapper iw;
  iw.field = field;

#define _if_type(type_name)            if (field.type == #type_name) { iw.input = newInput(mapPrimitiveType<type_name>(), field.name); iw.sizeDivider = 1; iw.sizeofInputElement = sizeof(to_rtmaps_type_t<to_fixed_width_type_t<type_name> >); iw.writeField = makeFieldWriter_Primitive<type_name>(field); iw.typeFilter = &MAPS::GetTypeFilter< to_rtmaps_type_t<to_fixed_width_type_t<type_name> > >(); }

  // primitive types
  _if_type(bool)
    else _if_type(int8_t )
    else _if_type(int16_t)
    else _if_type(int32_t)
    else _if_type(int64_t)
    else _if_type(uint8_t )
    else _if_type(uint16_t)
    else _if_type(uint32_t)
    else _if_type(uint64_t)
    else _if_type(float )
    else _if_type(double)
    else _if_type(char )
    else _if_type(short)
    else _if_type(int )
    else _if_type(long )
    else _if_type(unsigned char )
    else _if_type(unsigned short)
    else _if_type(unsigned int )
    else _if_type(unsigned long )
    else _if_type(signed char )
    else _if_type(signed short)
    else _if_type(signed int )
    else _if_type(signed long )
  // struct
    else
  {
    iw.input = newInput("struct", field.name);
    iw.sizeDivider = field.size;
    iw.sizeofInputElement = field.size;
    iw.writeField = makeFieldWriter_Struct(field);
    iw.typeFilter = &MAPS::FilterStructure;
  }
#undef _if_type
  return std::make_pair(iw.input, iw);
}

void ComponentClass::Birth()
{
  initInputReader();
}

void ComponentClass::Core()
{
  m_inputReader->Read();
}

void ComponentClass::Death()
{
  m_inputReader.reset();
}

void ComponentClass::initInputReader()
{
  using ioelt_vector = std::vector<MAPSIOElt*>;
  using input_vector = const std::vector<MAPSInput*>;
  std::vector<MAPSInput*> inputList;
  inputList.reserve(m_inputMap.size());
  for (auto& kv : m_inputMap) {
    inputList.emplace_back(kv.first);
  }

  const auto firstTimeCb = [this] (const MAPSTimestamp, MAPS::ArrayView<MAPS::
    InputElt<>> inElts)
  {
    allocateOutput(inElts);
  }

  ;
  const auto onDataCb = [this] (const MAPSTimestamp ts, MAPS::ArrayView<MAPS::
    InputElt<>> inElts)
  {
    writeOutput(ts, inElts);
  }

  ;
  switch (m_reading_policy)
  {
   case ReadingPolicy::Synchronized:
    {
      m_inputReader = MAPS::MakeInputReader::Synchronized(
        this,
        static_cast<MAPSDelay>(GetIntegerProperty("p_sync_tolerance_us")),
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   case ReadingPolicy::PeriodicSampling:
    {
      m_inputReader = MAPS::MakeInputReader::PeriodicSampling(
        this,
        static_cast<MAPSDelay>(GetIntegerProperty("p_sampling_period_us")),
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   case ReadingPolicy::Reactive:
    {
      m_inputReader = MAPS::MakeInputReader::Reactive(
        this,
        MAPS::InputReaderOption::Reactive::FirstTimeBehavior::WaitForAllInputs,
        MAPS::InputReaderOption::Reactive::Buffering::Enabled,
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   case ReadingPolicy::Triggered:
    {
      m_inputReader = MAPS::MakeInputReader::Triggered(
        this,
        Input(I_IDX_TRIGGER),
        MAPS::InputReaderOption::Triggered::TriggerKind::NotDataInput,
        MAPS::InputReaderOption::Triggered::SamplingBehavior::WaitForAllInputs,
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   case ReadingPolicy::WaitForAllInputs:
    {
      m_inputReader = MAPS::MakeInputReader::WaitForAllInputs(
        this,
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   case ReadingPolicy::PeriodicSamplingWhilePostProcessing:
    {
      m_inputReader = MAPS::MakeInputReader::PeriodicSamplingBasedOnTimestamps(
        this,
        static_cast<MAPSDelay>(GetIntegerProperty("p_sampling_period_us")),
        inputList,
        firstTimeCb,
        onDataCb
        );
      break;
    }

   default:
    Error(MAPSStreamedString() << "Unknown reading policy [" << static_cast<int>
          (m_reading_policy) << "]");
  }
}

size_t ComponentClass::ioEltSizeToElementCount(const size_t ioEltSize, MAPSInput*
  const input)
{
  // returns the number of fields of type field.type[field.capacity]
  // that can be filled by an ioElt of size ioEltSize
  auto& iw = m_inputMap.at(input);

  // number of elements of type field.type
  const size_t elementCount = ioEltSize / iw.sizeDivider;

  // if the field is NOT an array, then the ioElt can fill elementCount times fields of field.type
  // if the field is an array, then we must divide by the array size
  const size_t arrayCount = elementCount / iw.field.capacity;
  return arrayCount;
}

void ComponentClass::allocateOutput(MAPS::ArrayView<MAPS::InputElt<>>& inElts)
{
  auto it = std::max_element(inElts.begin(), inElts.end(), [&] (const MAPS::
    InputElt<>& a, const MAPS::InputElt<>& b)
  {
    return ioEltSizeToElementCount(static_cast<size_t>(a.BufferSize()), a.Input())
      < ioEltSizeToElementCount(static_cast<size_t>(b.BufferSize()), b.Input());
  }

  );
  const size_t maxElementCount = ioEltSizeToElementCount(static_cast<size_t>
    (it->BufferSize()), it->Input());
  Output(O_IDX_DATA).AllocOutputBuffer(static_cast<int>(maxElementCount *
    m_outputStruct->size));
}

void ComponentClass::writeOutput(const MAPSTimestamp ts, MAPS::ArrayView<MAPS::
  InputElt<>>& inElts)
{
  // "truncate" to the minimum amount of data that can be read
  const size_t minElementCount = [&] {
    auto it = std::min_element(inElts.begin(), inElts.end(), [&] (const MAPS::
    InputElt<>& a, const MAPS::InputElt<>& b) {
      return ioEltSizeToElementCount(static_cast<size_t>(a.BufferSize()),
      a.Input())
      < ioEltSizeToElementCount(static_cast<size_t>(b.BufferSize()), b.Input());
    });

    return ioEltSizeToElementCount(static_cast<size_t>(it->BufferSize()),
      it->Input());
  }();

  MAPS::OutputGuard<> outGuard{ this, Output(O_IDX_DATA), true };

  outGuard.Timestamp() = ts;

#ifdef _MSC_VER

#pragma warning(push)
#pragma warning(disable:4267)
#pragma warning(disable:4365)

#else

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wconversion"

#endif

  outGuard.VectorSize() = minElementCount * m_outputStruct->size;

#ifdef _MSC_VER

#pragma warning(pop)

#else

#pragma GCC diagnostic pop

#endif

  uint8_t* const outputArray = outGuard.DataPointerAs<uint8_t>(0, false);
  std::memset(outputArray, 0, outGuard.VectorSize());
  for (size_t elementIdx = 0; elementIdx < minElementCount; ++elementIdx) {
    uint8_t* const outputElement = outputArray + (elementIdx *
      m_outputStruct->size);
    for (auto& inElt : inElts) {
      auto& iw = m_inputMap.at(inElt.Input());
      const uint8_t* const inputArray = static_cast<const uint8_t*>
        (inElt.DataPointer());
      const uint8_t* const inputElement = inputArray + (elementIdx *
        iw.sizeofInputElement * iw.field.capacity);
      iw.writeField(inputElement, outputElement);
    }
  }

  outGuard.Validate();
}

bool ComponentClass::checkInputType(const MAPSTypeInfo& typeInfo, MAPSInput*
  const input)
{
  bool validType = false;
  const auto& iw = m_inputMap.at(input);
  if (!MAPS::TypeFilter(typeInfo, *iw.typeFilter)) {
    validType = false;
  } else if ((MAPS::Structure & iw.typeFilter->mask) != 0) {
    const MAPSString* const typeName = typeInfo.name;
    if (typeName == nullptr) {
      validType = false;
    } else {
      validType = std::string((const char*) (*typeName)) == iw.field.type;
    }
  } else                               // primitive type
  {
    validType = true;
  }

  if (!validType) {
    ReportError(MAPSStreamedString()
                << "Input type mismatch"
                << " [input:" << input->ShortName() << "]"
                << " [expected:" << iw.field.type.c_str() << "]"
                << " [received:" << toString(typeInfo).c_str() << "]"
                );
  }

  return validType;
}

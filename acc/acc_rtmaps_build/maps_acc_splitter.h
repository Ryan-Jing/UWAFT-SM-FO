#ifndef maps_acc_splitter_h_
#define maps_acc_splitter_h_
#ifdef _MSC_VER
#if _MSC_VER < 1900
#error "In order to compile this code, you must use Visual Studio >= 2015 compiler"
#endif

#else
#if __cplusplus < 201103L
#error "In order to compile this code, you must use a C++11 compiler (e.g. GCC >= 5) and make sure that the '-std=c++11' (or '-std=c++14' or '-std=c++17' etc.) compiler flag is used"
#endif
#endif

#include <cstdint>
#include <functional>
#include <vector>
#include <maps.hpp>
#include "./acc_rtmaps_tlc_helper.h"
#include "./acc_rtmaps_tlc_types.h"
#define ComponentClass                 maps_acc_splitter
#define ComponentName                  "acc_splitter"
#define ComponentVersion               "2.3"

class ComponentClass : public MAPSComponent
{
 private:
  friend class acc_rtmaps_tlc_helper::DynamicInputModel;
  template <typename TComponent, typename TContainer, typename TLambda>
    friend
    void acc_rtmaps_tlc_helper::fillEnumPropertyWithContainerValues(TComponent*
    comp,
    MAPSProperty& prop, TContainer&& container, TLambda appendCallback, const
    bool sortElements);
 public:
  struct OutputWrapper
  {
    // void (bufferSize)
    using AllocOutputCallback = std::function<void (const size_t)>;

    // void (rawStructArray, structCount, timestamp)
    using WriteCallback = std::function<void (const uint8_t*, const size_t,
      const MAPSTimestamp)>;
    MAPSOutput* output;
    acc_rtmaps_tlc_types::Field field;
    AllocOutputCallback allocOutput;
    WriteCallback writeOutput;
    template <typename TAllocCallable, typename TWriteCallable>
      OutputWrapper(
                    MAPSOutput* output_, const acc_rtmaps_tlc_types::Field&
                    field_,
                    TAllocCallable allocOutput_, TWriteCallable writeOutput_)
      : output(output_)
      , field(field_)
      , allocOutput(allocOutput_)
      , writeOutput(writeOutput_)
    {
    }
  };

 private:
  MAPS_COMPONENT_STANDARD_HEADER_CODE(ComponentClass)
    void Set(MAPSProperty& p, const MAPSEnumStruct& v) override;
  void Set(MAPSProperty& p, const MAPSString& v) override;
  void Dynamic() override;
  static
    void a_selected_input_type_info(MAPSModule* m, int);
  void reportSelectedInputTypeInfo();
  void fillInputTypeEnum();
  void createOutputs();
  template <typename TDataType>
    OutputWrapper makePrimitiveOutputWrapper(MAPSOutput* output, const
    acc_rtmaps_tlc_types::Field& field);
  OutputWrapper makeStructOutputWrapper(MAPSOutput* output, const
    acc_rtmaps_tlc_types::Field& field);
  OutputWrapper createOutput(const acc_rtmaps_tlc_types::Field& field);
 private:
  std::string m_input_type;
  std::string m_output_selection_regex;
  bool m_firstTime;
  const acc_rtmaps_tlc_types::Struct* m_inputStruct = nullptr;
  acc_rtmaps_tlc_helper::DynamicInputModel m_input;
  std::vector<OutputWrapper> m_outputList;
  void checkInputType(const MAPSTypeInfo& inputTypeInfo);
  void allocOutputBuffers(const size_t inputBufferSize);
  void writeOutputs(const uint8_t* inputStructs, const size_t inputStructCount,
                    const MAPSTimestamp ts);
};

#endif                                 /* maps_acc_splitter_h_ */

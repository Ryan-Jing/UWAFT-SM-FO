#ifndef maps_acc_merger_h_
#define maps_acc_merger_h_
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
#include <cstdlib>
#include <functional>
#include <map>
#include <memory>
#include <utility>
#include <vector>
#include <maps.hpp>
#include <maps/input_reader/maps_input_reader.hpp>
#include "./acc_rtmaps_tlc_helper.h"
#include "./acc_rtmaps_tlc_types.h"
#define ComponentClass                 maps_acc_merger
#define ComponentName                  "acc_merger"
#define ComponentVersion               "2.1"

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
  enum class ReadingPolicy
  {
    Synchronized,
    PeriodicSampling,
    Reactive,
    Triggered,
    WaitForAllInputs,
    PeriodicSamplingWhilePostProcessing
  };

  struct InputWrapper
  {
    using FieldWriterCallback = std::function<void(const void* const /* srcFieldPtr */
      , void* const                    /* dstStructPtr */
      )>;
    MAPSInput* input;
    const MAPSTypeFilterBase* typeFilter;
    acc_rtmaps_tlc_types::Field field;
    size_t sizeDivider;
    size_t sizeofInputElement;
    FieldWriterCallback writeField;
    InputWrapper()
      : input(nullptr)
      , typeFilter(nullptr)
      , field()
      , sizeDivider(0)
      , sizeofInputElement(0)
      , writeField([] (const void* const, void* const)
                   {
                   }

                   )
    { }
  };

 private:
  MAPS_COMPONENT_STANDARD_HEADER_CODE(ComponentClass)
    void Set(MAPSProperty& p, const MAPSEnumStruct& v) override;
  void Set(MAPSProperty& p, const MAPSString& v) override;
  void Set(MAPSProperty& p, MAPSInt64 v) override;
  void Dynamic() override;
  bool HasProperty(const char* propertyName)
  {
    MAPSListIterator it;
    monitor.Lock();
    MAPSForallItems(it, properties)
    {
      if (properties[it]->ShortName() == propertyName) {
        monitor.Release();
        return true;
      }
    }

    monitor.Release();
    return false;
  }

 private:
  ReadingPolicy m_reading_policy;
  std::string m_input_selection_regex;
  const acc_rtmaps_tlc_types::Struct* m_outputStruct = nullptr;
  std::map<MAPSInput*, InputWrapper> m_inputMap;
  std::unique_ptr<MAPS::InputReader> m_inputReader;
  static
    void a_selected_output_type_info(MAPSModule* m, int);
  void reportSelectedOutputTypeInfo();
  void fillOutputTypeEnum();
  void createProperties();
  void createInputs();
  template <typename TField_ActualType>
    InputWrapper::FieldWriterCallback makeFieldWriter_Primitive(const
    acc_rtmaps_tlc_types::Field& field);
  InputWrapper::FieldWriterCallback makeFieldWriter_Struct(const
    acc_rtmaps_tlc_types::Field& field);
  std::pair<MAPSInput*, InputWrapper> createInputMapEntry(const
    acc_rtmaps_tlc_types::Field& field);
  void initInputReader();
  size_t ioEltSizeToElementCount(const size_t ioEltSize, MAPSInput* const input);
  void allocateOutput(MAPS::ArrayView<MAPS::InputElt<>>& inElts);
  void writeOutput(const MAPSTimestamp ts, MAPS::ArrayView<MAPS::InputElt<>>
                   & inElts);
  bool checkInputType(const MAPSTypeInfo& typeInfo, MAPSInput* const input);
};

#endif                                 /* maps_acc_merger_h_ */

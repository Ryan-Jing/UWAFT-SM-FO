#include "acc_rtmaps_tlc_types.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <string>
#include <type_traits>

//#include "rtwtypes.h"
#include "acc_types.h"
#include "tmwtypes.h"
#include "simstruc_types.h"
#include <maps.hpp>

namespace acc_rtmaps_tlc_types
{
  namespace detail
  {
    template <typename T>
      typename std::enable_if<std::is_integral<T>::value && std::is_signed<T>::
      value, std::string>::type makePrimitiveTypeName()
    {
      return std::string{ "int" } + std::to_string(sizeof(T) * 8) + "_t";
    }

    template <typename T>
      typename std::enable_if<std::is_integral<T>::value && std::is_unsigned<T>::
      value, std::string>::type makePrimitiveTypeName()
    {
      return std::string{ "uint" } + std::to_string(sizeof(T) * 8) + "_t";
    }

    template <typename T>
      typename std::enable_if<std::is_same<T, double>::value, std::string>::type
      makePrimitiveTypeName()
    {
      return "double";
    }

    template <typename T>
      typename std::enable_if<std::is_same<T, float>::value, std::string>::type
      makePrimitiveTypeName()
    {
      return "float";
    }

    std::array<Struct, 2 > makeSortedStructs()
    {
      std::array<Struct, 2 > structArr {
        Struct{
          "ACCStatusBus", sizeof(ACCStatusBus),

          {
            Field{
              0, sizeof(boolean_T),
              "boolean_T", "ACC_Enable_Pressed"
            }
            ,
            Field{
              1, sizeof(boolean_T),
              "boolean_T", "V2X_Switch_ON"
            }
            ,
            Field{
              2, sizeof(boolean_T),
              "boolean_T", "Longitudinal_Switch_ON"
            }
            ,
            Field{
              3, sizeof(boolean_T),
              "boolean_T", "Set_Resume"
            }
            ,
            Field{
              4, sizeof(boolean_T),
              "boolean_T", "Cancel_Pressed"
            }
            ,
            Field{
              5, sizeof(boolean_T),
              "boolean_T", "Driver_Brakes"
            }
            ,
            Field{
              6, sizeof(boolean_T),
              "boolean_T", "Timeout_Event"
            }
            ,
            Field{
              7, sizeof(boolean_T),
              "boolean_T", "In_CACC_Speed_Range"
            }
          }
        }
        ,
        Struct{
          "CurrentStateBus", sizeof(CurrentStateBus),

          {
            Field{
              0, sizeof(StatusType),
              "StatusType", "ACCStatus"
            }
            ,
            Field{
              4, sizeof(StatusType),
              "StatusType", "CACCStatus"
            }
            ,
            Field{
              8, sizeof(StatusType),
              "StatusType", "LCCStatus"
            }
            ,
            Field{
              12, sizeof(StatusType),
              "StatusType", "AINStatus"
            }
            ,
            Field{
              16, sizeof(StatusType),
              "StatusType", "APStatus"
            }
          }
        }
        ,
      };

      std::sort(structArr.begin(), structArr.end(), [] (const Struct& a, const
                 Struct& b)
                {
                return a.name < b.name;
                }

                );
      return structArr;
    }
  }                                    /* namespace detail */

  std::string Field::canonicalizeType(const std::string& typeName_)
  {

#define _to_canonical_name(T)          if (typeName_ == #T) { return detail::makePrimitiveTypeName<T>(); }

    _to_canonical_name(bool)
      else _to_canonical_name(int8_t)
      else _to_canonical_name(int16_t)
      else _to_canonical_name(int32_t)
      else _to_canonical_name(int64_t)
      else _to_canonical_name(uint8_t)
      else _to_canonical_name(uint16_t)
      else _to_canonical_name(uint32_t)
      else _to_canonical_name(uint64_t)
      else _to_canonical_name(float)
      else _to_canonical_name(double)
      else _to_canonical_name(char)
      else _to_canonical_name(short)
      else _to_canonical_name(int)
      else _to_canonical_name(long)
      else _to_canonical_name(unsigned char)
      else _to_canonical_name(unsigned short)
      else _to_canonical_name(unsigned int)
      else _to_canonical_name(unsigned long)
      else _to_canonical_name(signed char)
      else _to_canonical_name(signed short)
      else _to_canonical_name(signed int)
      else _to_canonical_name(signed long)
    // rtwtypes
      else _to_canonical_name(int8_T)
      else _to_canonical_name(uint8_T)
      else _to_canonical_name(int16_T)
      else _to_canonical_name(uint16_T)
      else _to_canonical_name(int32_T)
      else _to_canonical_name(uint32_T)
      else _to_canonical_name(real32_T)
      else _to_canonical_name(real64_T)
      else _to_canonical_name(real_T)
      else _to_canonical_name(time_T)
      else _to_canonical_name(boolean_T)
      else _to_canonical_name(int_T)
      else _to_canonical_name(uint_T)
      else _to_canonical_name(char_T)
      else _to_canonical_name(byte_T)
      else _to_canonical_name(DTypeId)
      else { return typeName_;         /* structName */
    }
#undef _to_canonical_name
  }

  const std::array<Struct, 2 >& getStructs()
  {
    static const std::array<Struct, 2 > structArr { detail::makeSortedStructs()
    };

    return structArr;
  }

  const Struct& getStruct(const std::string& structName)
  {
    const auto& structArr = getStructs();
    auto structIt = std::find_if(structArr.begin(), structArr.end(), [&] (const
      Struct& st)
    {
      return st.name == structName;
    }

    );
    if (structIt == structArr.end()) {
      MAPS::ReportError(MAPSString("acc_rtmaps_tlc_types::getStruct: Struct [")
                        + structName.c_str() + "] not found");
      throw MAPS::ErrorException;
    }

    return *structIt;
  }
}

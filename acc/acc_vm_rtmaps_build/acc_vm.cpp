/*
 * acc_vm.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "acc_vm".
 *
 * Model version              : 2.12
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C++ source code generated on : Fri Dec  5 15:50:35 2025
 *
 * Target selection: rtmaps.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "acc_vm.h"
#include "rtwtypes.h"
#include "StatusType.h"

/* Named constants for Chart: '<Root>/Chart' */
const uint8_T acc_vm_IN_ACC_Active{ 1U };

const uint8_T acc_vm_IN_ACC_Deactivated{ 2U };

const uint8_T acc_vm_IN_ACC_Standby{ 3U };

/* Model step function */
void acc_vm::step()
{
  StatusType CurrentState;

  /* Chart: '<Root>/Chart' incorporates:
   *  BusCreator generated from: '<Root>/Chart'
   *  Inport: '<Root>/ACC_Inputs'
   *  Inport: '<Root>/Current_State_Bus'
   * */
  switch (acc_vm_DW.is_c3_acc_vm) {
   case acc_vm_IN_ACC_Active:
    CurrentState = StatusType::Active;
    if (acc_vm_U.ACC_Inputs.Cancel_Pressed || acc_vm_U.ACC_Inputs.Driver_Brakes ||
        acc_vm_U.ACC_Inputs.Timeout_Event) {
      acc_vm_DW.is_c3_acc_vm = acc_vm_IN_ACC_Deactivated;
      CurrentState = StatusType::Deactivated;
    }
    break;

   case acc_vm_IN_ACC_Deactivated:
    CurrentState = StatusType::Deactivated;
    if (acc_vm_U.ACC_Inputs.ACC_Enable_Pressed &&
        acc_vm_U.ACC_Inputs.V2X_Switch_ON &&
        acc_vm_U.ACC_Inputs.Longitudinal_Switch_ON &&
        (acc_vm_U.Current_State_Bus.APStatus == StatusType::Standby)) {
      acc_vm_DW.is_c3_acc_vm = acc_vm_IN_ACC_Standby;
      CurrentState = StatusType::Standby;
    }
    break;

   default:
    /* case IN_ACC_Standby: */
    CurrentState = StatusType::Standby;
    if (acc_vm_U.ACC_Inputs.Set_Resume &&
        acc_vm_U.ACC_Inputs.In_CACC_Speed_Range) {
      acc_vm_DW.is_c3_acc_vm = acc_vm_IN_ACC_Active;
      CurrentState = StatusType::Active;
    }
    break;
  }

  /* End of Chart: '<Root>/Chart' */

  /* Outport: '<Root>/Out1' incorporates:
   *  DataTypeConversion: '<Root>/Data Type Conversion'
   */
  acc_vm_Y.ACCCurrentState = static_cast<uint8_T>(CurrentState);
}

/* Model initialize function */
void acc_vm::initialize()
{
  /* Chart: '<Root>/Chart' */
  acc_vm_DW.is_c3_acc_vm = acc_vm_IN_ACC_Deactivated;
}

/* Model terminate function */
void acc_vm::terminate()
{
  /* (no terminate code required) */
}

/* Constructor */
acc_vm::acc_vm() :
  acc_vm_U(),
  acc_vm_Y(),
  acc_vm_DW(),
  acc_vm_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
/* Currently there is no destructor body generated.*/
acc_vm::~acc_vm() = default;

/* Real-Time Model get method */
RT_MODEL_acc_vm_T * acc_vm::getRTM()
{
  return (&acc_vm_M);
}

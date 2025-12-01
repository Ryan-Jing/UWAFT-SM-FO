/*
 * acc.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "acc".
 *
 * Model version              : 2.1
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C++ source code generated on : Mon Dec  1 12:31:10 2025
 *
 * Target selection: rtmaps.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "acc.h"
#include "rtwtypes.h"
#include "StatusType.h"

/* Named constants for Chart: '<Root>/Chart' */
const uint8_T acc_IN_ACC_Active{ 1U };

const uint8_T acc_IN_ACC_Deactivated{ 2U };

const uint8_T acc_IN_ACC_Standby{ 3U };

/* Model step function */
void acc::step()
{
  /* Chart: '<Root>/Chart' incorporates:
   *  BusCreator generated from: '<Root>/Chart'
   *  Inport: '<Root>/ACC_Inputs'
   *  Inport: '<Root>/Current_State_Bus'
   * */
  switch (acc_DW.is_c3_acc) {
   case acc_IN_ACC_Active:
    /* Outport: '<Root>/ACCCurrentState' */
    acc_Y.ACCCurrentState = StatusType::Active;
    if (acc_U.ACC_Inputs.Cancel_Pressed || acc_U.ACC_Inputs.Driver_Brakes ||
        acc_U.ACC_Inputs.Timeout_Event) {
      acc_DW.is_c3_acc = acc_IN_ACC_Deactivated;

      /* Outport: '<Root>/ACCCurrentState' */
      acc_Y.ACCCurrentState = StatusType::Deactivated;
    }
    break;

   case acc_IN_ACC_Deactivated:
    /* Outport: '<Root>/ACCCurrentState' */
    acc_Y.ACCCurrentState = StatusType::Deactivated;
    if (acc_U.ACC_Inputs.ACC_Enable_Pressed && acc_U.ACC_Inputs.V2X_Switch_ON &&
        acc_U.ACC_Inputs.Longitudinal_Switch_ON && (static_cast<int32_T>
         (acc_U.Current_State_Bus.APStatus) == 0)) {
      acc_DW.is_c3_acc = acc_IN_ACC_Standby;

      /* Outport: '<Root>/ACCCurrentState' */
      acc_Y.ACCCurrentState = StatusType::Standby;
    }
    break;

   default:
    /* Outport: '<Root>/ACCCurrentState' */
    /* case IN_ACC_Standby: */
    acc_Y.ACCCurrentState = StatusType::Standby;
    if (acc_U.ACC_Inputs.Set_Resume && acc_U.ACC_Inputs.In_CACC_Speed_Range) {
      acc_DW.is_c3_acc = acc_IN_ACC_Active;

      /* Outport: '<Root>/ACCCurrentState' */
      acc_Y.ACCCurrentState = StatusType::Active;
    }
    break;
  }

  /* End of Chart: '<Root>/Chart' */
}

/* Model initialize function */
void acc::initialize()
{
  /* Chart: '<Root>/Chart' */
  acc_DW.is_c3_acc = acc_IN_ACC_Deactivated;
}

/* Model terminate function */
void acc::terminate()
{
  /* (no terminate code required) */
}

/* Constructor */
acc::acc() :
  acc_U(),
  acc_Y(),
  acc_DW(),
  acc_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
/* Currently there is no destructor body generated.*/
acc::~acc() = default;

/* Real-Time Model get method */
RT_MODEL_acc_T * acc::getRTM()
{
  return (&acc_M);
}

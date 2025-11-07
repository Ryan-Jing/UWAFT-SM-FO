/*
 * SM_FO_Simulink.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "SM_FO_Simulink".
 *
 * Model version              : 1.37
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C++ source code generated on : Fri Nov  7 13:01:04 2025
 *
 * Target selection: rtmaps.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "SM_FO_Simulink.h"
#include "rtwtypes.h"

/* Named constants for Chart: '<Root>/Chart' */
const uint8_T SM_FO_Simulink_IN_ACC_State{ 1U };

const uint8_T SM_FO_Simulink_IN_ACC_State1{ 2U };

const uint8_T SM_FO_Simulink_IN_ACC_State2{ 3U };

const uint8_T SM_FO_Simulink_IN_Entry_State{ 4U };

const uint8_T SM_FO_Simulink_IN_Started_State{ 5U };

/* Function for Chart: '<Root>/Chart' */
void SM_FO_Simulink::SM_FO_Simulink_SMFO_Test(void)
{
  std::printf("State Machine status is: %f\n", 1.0);
  std::fflush(stdout);
}

/* Model step function */
void SM_FO_Simulink::step()
{
  /* Chart: '<Root>/Chart' incorporates:
   *  Inport: '<Root>/x'
   */
  if (SM_FO_Simulink_DW.is_active_c3_SM_FO_Simulink == 0) {
    SM_FO_Simulink_DW.is_active_c3_SM_FO_Simulink = 1U;
    SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_Entry_State;
    SM_FO_Simulink_SMFO_Test();
    SM_FO_Simulink_DW.entry_status = 1.0;
  } else {
    switch (SM_FO_Simulink_DW.is_c3_SM_FO_Simulink) {
     case SM_FO_Simulink_IN_ACC_State:
      if (SM_FO_Simulink_DW.accAllowed == 0.0) {
        SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_ACC_State1;
        std::printf("ACC Denied");
        std::fflush(stdout);
      } else if (SM_FO_Simulink_DW.accAllowed == 1.0) {
        SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_ACC_State2;
        std::printf("ACC Accepted, sending ACC allow message");
        std::fflush(stdout);

        /* Outport: '<Root>/exit_message' */
        SM_FO_Simulink_Y.exit_message = 1.0;
      }
      break;

     case SM_FO_Simulink_IN_ACC_State1:
     case SM_FO_Simulink_IN_ACC_State2:
      break;

     case SM_FO_Simulink_IN_Entry_State:
      if (SM_FO_Simulink_DW.entry_status == 1.0) {
        SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_Started_State;
        std::printf("Exit status: %f\n, vehicle started", 1.0);
        std::fflush(stdout);
      } else if (SM_FO_Simulink_U.x == 0.0) {
        SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_Entry_State;
        SM_FO_Simulink_SMFO_Test();
        SM_FO_Simulink_DW.entry_status = 1.0;
      } else if (SM_FO_Simulink_DW.entry_status == 2.0) {
        SM_FO_Simulink_DW.is_c3_SM_FO_Simulink = SM_FO_Simulink_IN_ACC_State;
        std::printf("ACC Requested");
        std::fflush(stdout);
        SM_FO_Simulink_DW.accAllowed = 1.0;
      }
      break;

     default:
      /* case IN_Started_State: */
      break;
    }
  }

  /* End of Chart: '<Root>/Chart' */
}

/* Model initialize function */
void SM_FO_Simulink::initialize()
{
  /* (no initialization code required) */
}

/* Model terminate function */
void SM_FO_Simulink::terminate()
{
  /* (no terminate code required) */
}

/* Constructor */
SM_FO_Simulink::SM_FO_Simulink() :
  SM_FO_Simulink_U(),
  SM_FO_Simulink_Y(),
  SM_FO_Simulink_DW(),
  SM_FO_Simulink_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
/* Currently there is no destructor body generated.*/
SM_FO_Simulink::~SM_FO_Simulink() = default;

/* Real-Time Model get method */
RT_MODEL_SM_FO_Simulink_T * SM_FO_Simulink::getRTM()
{
  return (&SM_FO_Simulink_M);
}

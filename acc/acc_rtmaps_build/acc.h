/*
 * acc.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "acc".
 *
 * Model version              : 2.0
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C++ source code generated on : Mon Dec  1 13:49:26 2025
 *
 * Target selection: rtmaps.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef acc_h_
#define acc_h_
#include <cmath>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "acc_types.h"
#include "StatusType.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
struct DW_acc_T {
  uint8_T is_c3_acc;                   /* '<Root>/Chart' */
};

/* External inputs (root inport signals with default storage) */
struct ExtU_acc_T {
  ACCStatusBus ACC_Inputs;             /* '<Root>/ACC_Inputs' */
  CurrentStateBus Current_State_Bus;   /* '<Root>/Current_State_Bus' */
};

/* External outputs (root outports fed by signals with default storage) */
struct ExtY_acc_T {
  StatusType ACCCurrentState;          /* '<Root>/ACCCurrentState' */
};

/* Real-time Model Data Structure */
struct tag_RTM_acc_T {
  const char_T *errorStatus;
};

/* Class declaration for model acc */
class acc final
{
  /* public data and function members */
 public:
  /* Copy Constructor */
  acc(acc const&) = delete;

  /* Assignment Operator */
  acc& operator= (acc const&) & = delete;

  /* Move Constructor */
  acc(acc &&) = delete;

  /* Move Assignment Operator */
  acc& operator= (acc &&) = delete;

  /* Real-Time Model get method */
  RT_MODEL_acc_T * getRTM();

  /* Root inports set method */
  void setExternalInputs(const ExtU_acc_T *pExtU_acc_T)
  {
    acc_U = *pExtU_acc_T;
  }

  /* Root outports get method */
  const ExtY_acc_T &getExternalOutputs() const
  {
    return acc_Y;
  }

  /* Initial conditions function */
  void initialize();

  /* model step function */
  void step();

  /* model terminate function */
  static void terminate();

  /* Constructor */
  acc();

  /* Destructor */
  ~acc();

  /* private data and function members */
 private:
  /* External inputs */
  ExtU_acc_T acc_U;

  /* External outputs */
  ExtY_acc_T acc_Y;

  /* Block states */
  DW_acc_T acc_DW;

  /* Real-Time Model */
  RT_MODEL_acc_T acc_M;
};

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<Root>/Scope' : Unused code path elimination
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'acc'
 * '<S1>'   : 'acc/Chart'
 */
#endif                                 /* acc_h_ */

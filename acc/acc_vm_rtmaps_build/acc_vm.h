/*
 * acc_vm.h
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

#ifndef acc_vm_h_
#define acc_vm_h_
#include <cmath>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "acc_vm_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
struct DW_acc_vm_T {
  uint8_T is_c3_acc_vm;                /* '<Root>/Chart' */
};

/* External inputs (root inport signals with default storage) */
struct ExtU_acc_vm_T {
  ACCStatusBus ACC_Inputs;             /* '<Root>/ACC_Inputs' */
  CurrentStateBus Current_State_Bus;   /* '<Root>/Current_State_Bus' */
};

/* External outputs (root outports fed by signals with default storage) */
struct ExtY_acc_vm_T {
  uint8_T ACCCurrentState;             /* '<Root>/Out1' */
};

/* Real-time Model Data Structure */
struct tag_RTM_acc_vm_T {
  const char_T *errorStatus;
};

/* Class declaration for model acc_vm */
class acc_vm final
{
  /* public data and function members */
 public:
  /* Copy Constructor */
  acc_vm(acc_vm const&) = delete;

  /* Assignment Operator */
  acc_vm& operator= (acc_vm const&) & = delete;

  /* Move Constructor */
  acc_vm(acc_vm &&) = delete;

  /* Move Assignment Operator */
  acc_vm& operator= (acc_vm &&) = delete;

  /* Real-Time Model get method */
  RT_MODEL_acc_vm_T * getRTM();

  /* Root inports set method */
  void setExternalInputs(const ExtU_acc_vm_T *pExtU_acc_vm_T)
  {
    acc_vm_U = *pExtU_acc_vm_T;
  }

  /* Root outports get method */
  const ExtY_acc_vm_T &getExternalOutputs() const
  {
    return acc_vm_Y;
  }

  /* Initial conditions function */
  void initialize();

  /* model step function */
  void step();

  /* model terminate function */
  static void terminate();

  /* Constructor */
  acc_vm();

  /* Destructor */
  ~acc_vm();

  /* private data and function members */
 private:
  /* External inputs */
  ExtU_acc_vm_T acc_vm_U;

  /* External outputs */
  ExtY_acc_vm_T acc_vm_Y;

  /* Block states */
  DW_acc_vm_T acc_vm_DW;

  /* Real-Time Model */
  RT_MODEL_acc_vm_T acc_vm_M;
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
 * '<Root>' : 'acc_vm'
 * '<S1>'   : 'acc_vm/Chart'
 */
#endif                                 /* acc_vm_h_ */

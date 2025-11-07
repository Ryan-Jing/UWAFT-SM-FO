/*
 * SM_FO_Simulink.h
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

#ifndef SM_FO_Simulink_h_
#define SM_FO_Simulink_h_
#include <cmath>
#include <cstdio>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "SM_FO_Simulink_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
struct DW_SM_FO_Simulink_T {
  real_T entry_status;                 /* '<Root>/Chart' */
  real_T accAllowed;                   /* '<Root>/Chart' */
  uint8_T is_active_c3_SM_FO_Simulink; /* '<Root>/Chart' */
  uint8_T is_c3_SM_FO_Simulink;        /* '<Root>/Chart' */
};

/* External inputs (root inport signals with default storage) */
struct ExtU_SM_FO_Simulink_T {
  real_T x;                            /* '<Root>/x' */
};

/* External outputs (root outports fed by signals with default storage) */
struct ExtY_SM_FO_Simulink_T {
  real_T exit_message;                 /* '<Root>/exit_message' */
};

/* Real-time Model Data Structure */
struct tag_RTM_SM_FO_Simulink_T {
  const char_T *errorStatus;
};

/* Class declaration for model SM_FO_Simulink */
class SM_FO_Simulink final
{
  /* public data and function members */
 public:
  /* Copy Constructor */
  SM_FO_Simulink(SM_FO_Simulink const&) = delete;

  /* Assignment Operator */
  SM_FO_Simulink& operator= (SM_FO_Simulink const&) & = delete;

  /* Move Constructor */
  SM_FO_Simulink(SM_FO_Simulink &&) = delete;

  /* Move Assignment Operator */
  SM_FO_Simulink& operator= (SM_FO_Simulink &&) = delete;

  /* Real-Time Model get method */
  RT_MODEL_SM_FO_Simulink_T * getRTM();

  /* Root inports set method */
  void setExternalInputs(const ExtU_SM_FO_Simulink_T *pExtU_SM_FO_Simulink_T)
  {
    SM_FO_Simulink_U = *pExtU_SM_FO_Simulink_T;
  }

  /* Root outports get method */
  const ExtY_SM_FO_Simulink_T &getExternalOutputs() const
  {
    return SM_FO_Simulink_Y;
  }

  /* Initial conditions function */
  void initialize();

  /* model step function */
  void step();

  /* model terminate function */
  static void terminate();

  /* Constructor */
  SM_FO_Simulink();

  /* Destructor */
  ~SM_FO_Simulink();

  /* private data and function members */
 private:
  /* External inputs */
  ExtU_SM_FO_Simulink_T SM_FO_Simulink_U;

  /* External outputs */
  ExtY_SM_FO_Simulink_T SM_FO_Simulink_Y;

  /* Block states */
  DW_SM_FO_Simulink_T SM_FO_Simulink_DW;

  /* private member function(s) for subsystem '<Root>'*/
  void SM_FO_Simulink_SMFO_Test(void);

  /* Real-Time Model */
  RT_MODEL_SM_FO_Simulink_T SM_FO_Simulink_M;
};

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
 * '<Root>' : 'SM_FO_Simulink'
 * '<S1>'   : 'SM_FO_Simulink/Chart'
 */
#endif                                 /* SM_FO_Simulink_h_ */

/*
 * simple_test.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "simple_test".
 *
 * Model version              : 1.0
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C++ source code generated on : Tue Nov  4 20:27:41 2025
 *
 * Target selection: rtmaps.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef simple_test_h_
#define simple_test_h_
#include <cmath>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "simple_test_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* External inputs (root inport signals with default storage) */
struct ExtU_simple_test_T {
  real_T iPort;                        /* '<Root>/iPort' */
};

/* External outputs (root outports fed by signals with default storage) */
struct ExtY_simple_test_T {
  real_T oPort;                        /* '<Root>/oPort' */
};

/* Parameters (default storage) */
struct P_simple_test_T_ {
  real_T gain_Gain;                    /* Expression: 2
                                        * Referenced by: '<Root>/gain'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_simple_test_T {
  const char_T *errorStatus;
};

/* Class declaration for model simple_test */
class simple_test final
{
  /* public data and function members */
 public:
  /* Copy Constructor */
  simple_test(simple_test const&) = delete;

  /* Assignment Operator */
  simple_test& operator= (simple_test const&) & = delete;

  /* Move Constructor */
  simple_test(simple_test &&) = delete;

  /* Move Assignment Operator */
  simple_test& operator= (simple_test &&) = delete;

  /* Real-Time Model get method */
  RT_MODEL_simple_test_T * getRTM();

  /* Tunable parameters */
  static P_simple_test_T simple_test_P;

  /* Root inports set method */
  void setExternalInputs(const ExtU_simple_test_T *pExtU_simple_test_T)
  {
    simple_test_U = *pExtU_simple_test_T;
  }

  /* Root outports get method */
  const ExtY_simple_test_T &getExternalOutputs() const
  {
    return simple_test_Y;
  }

  /* Initial conditions function */
  void initialize();

  /* model step function */
  void step();

  /* model terminate function */
  static void terminate();

  /* Constructor */
  simple_test();

  /* Destructor */
  ~simple_test();

  /* private data and function members */
 private:
  /* External inputs */
  ExtU_simple_test_T simple_test_U;

  /* External outputs */
  ExtY_simple_test_T simple_test_Y;

  /* Real-Time Model */
  RT_MODEL_simple_test_T simple_test_M;
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
 * '<Root>' : 'simple_test'
 */
#endif                                 /* simple_test_h_ */

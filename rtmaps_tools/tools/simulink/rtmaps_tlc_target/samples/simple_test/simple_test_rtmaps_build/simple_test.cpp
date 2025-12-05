/*
 * simple_test.cpp
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

#include "simple_test.h"

/* Model step function */
void simple_test::step()
{
  /* Outport: '<Root>/oPort' incorporates:
   *  Gain: '<Root>/gain'
   *  Inport: '<Root>/iPort'
   */
  simple_test_Y.oPort = simple_test_P.gain_Gain * simple_test_U.iPort;
}

/* Model initialize function */
void simple_test::initialize()
{
  /* (no initialization code required) */
}

/* Model terminate function */
void simple_test::terminate()
{
  /* (no terminate code required) */
}

/* Constructor */
simple_test::simple_test() :
  simple_test_U(),
  simple_test_Y(),
  simple_test_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
/* Currently there is no destructor body generated.*/
simple_test::~simple_test() = default;

/* Real-Time Model get method */
RT_MODEL_simple_test_T * simple_test::getRTM()
{
  return (&simple_test_M);
}

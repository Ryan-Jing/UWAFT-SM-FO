/*
 * acc_vm_types.h
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

#ifndef acc_vm_types_h_
#define acc_vm_types_h_
#include "rtwtypes.h"
#include "StatusType.h"
#ifndef DEFINED_TYPEDEF_FOR_ACCStatusBus_
#define DEFINED_TYPEDEF_FOR_ACCStatusBus_

struct ACCStatusBus
{
  boolean_T ACC_Enable_Pressed;
  boolean_T V2X_Switch_ON;
  boolean_T Longitudinal_Switch_ON;
  boolean_T Set_Resume;
  boolean_T Cancel_Pressed;
  boolean_T Driver_Brakes;
  boolean_T Timeout_Event;
  boolean_T In_CACC_Speed_Range;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_CurrentStateBus_
#define DEFINED_TYPEDEF_FOR_CurrentStateBus_

struct CurrentStateBus
{
  StatusType ACCStatus;
  StatusType CACCStatus;
  StatusType LCCStatus;
  StatusType AINStatus;
  StatusType APStatus;
};

#endif

/* Forward declaration for rtModel */
typedef struct tag_RTM_acc_vm_T RT_MODEL_acc_vm_T;

#endif                                 /* acc_vm_types_h_ */

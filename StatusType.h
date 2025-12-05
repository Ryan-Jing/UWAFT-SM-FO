#ifndef STATUSTYPE_H
#define STATUSTYPE_H
#include "rtwtypes.h"

#ifndef DEFINED_TYPEDEF_FOR_StatusType_
#define DEFINED_TYPEDEF_FOR_StatusType_

typedef enum {
    Deactivated = 0,
    Standby = 1,
    Active = 2
} StatusType;

#endif
#endif /* STATUSTYPE_H */
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

// Define comparison operators for StatusType
#ifdef __cplusplus
inline bool operator!=(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) != static_cast<int>(rhs);
}

inline bool operator==(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) == static_cast<int>(rhs);
}

inline bool operator<(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) < static_cast<int>(rhs);
}

inline bool operator>(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) > static_cast<int>(rhs);
}

inline bool operator<=(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) <= static_cast<int>(rhs);
}

inline bool operator>=(const StatusType& lhs, const StatusType& rhs) {
    return static_cast<int>(lhs) >= static_cast<int>(rhs);
}
#endif

#endif /* STATUSTYPE_H */

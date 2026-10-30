/*
 * CI check: the shared header must compile cleanly in user mode, as C and as C++,
 * and the struct layout must not change by accident.
 */
#include <windows.h>
#include <winioctl.h>
#include <initguid.h>
#include "VirtualToneIoctl.h"

/* If this fails, a struct layout changed: bump VTM_INTERFACE_VERSION and update this check. */
C_ASSERT(sizeof(VTM_SIGNAL_PARAMS) == 5 * sizeof(ULONG));
C_ASSERT(VTM_INTERFACE_VERSION == 1);

int vtm_header_check(void)
{
    VTM_SIGNAL_PARAMS p;
    p.Version          = VTM_INTERFACE_VERSION;
    p.Enabled          = VTM_DEFAULT_ENABLED;
    p.Waveform         = VTM_DEFAULT_WAVEFORM;
    p.FrequencyHz      = VTM_DEFAULT_FREQUENCY_HZ;
    p.AmplitudePercent = VTM_DEFAULT_AMPLITUDE;
    return VTM_PARAMS_VALID(&p) ? 0 : 1;
}

/*
 * VirtualToneIoctl.h
 *
 * Shared interface between the Virtual Tone Microphone driver and the
 * user-mode communication library. Included by BOTH sides.
 *
 * STATUS: DRAFT - to be agreed by the team before M2.
 * Any change here must update the driver and the library in the same PR.
 */
#pragma once

#ifdef _KERNEL_MODE
#include <ntddk.h>
#else
#include <windows.h>
#include <winioctl.h>
#endif

/* Bump when the layout of any struct below changes. */
#define VTM_INTERFACE_VERSION   1

/*
 * Device interface GUID the library uses to find the driver.
 * {5ecb5cd2-cc8a-4d43-967a-c1e667f0e9f2}
 * To instantiate it, in exactly ONE source file of each binary include, in this order:
 *   user mode:   <windows.h>, <winioctl.h>, <initguid.h>, "VirtualToneIoctl.h"
 *   kernel mode: <ntddk.h>, <initguid.h>, "VirtualToneIoctl.h"
 * Every other file just includes "VirtualToneIoctl.h".
 */
DEFINE_GUID(GUID_DEVINTERFACE_VIRTUAL_TONE_MIC,
    0x5ecb5cd2, 0xcc8a, 0x4d43, 0x96, 0x7a, 0xc1, 0xe6, 0x67, 0xf0, 0xe9, 0xf2);

/* ---- Waveforms ---------------------------------------------------------- */
typedef enum _VTM_WAVEFORM {
    VtmWaveformSine   = 0,
    VtmWaveformSquare = 1,
    VtmWaveformNoise  = 2,
    VtmWaveformCount            /* keep last */
} VTM_WAVEFORM;

/* ---- Limits (from the specification) ------------------------------------ */
#define VTM_FREQUENCY_MIN_HZ        20
#define VTM_FREQUENCY_MAX_HZ        20000
#define VTM_AMPLITUDE_MAX_PERCENT   100

/* ---- Defaults applied at driver load (spec item 8) ---------------------- */
#define VTM_DEFAULT_ENABLED         1
#define VTM_DEFAULT_WAVEFORM        VtmWaveformSine
#define VTM_DEFAULT_FREQUENCY_HZ    440
#define VTM_DEFAULT_AMPLITUDE       50

/* ---- Signal parameters -------------------------------------------------- */
typedef struct _VTM_SIGNAL_PARAMS {
    ULONG Version;          /* must be VTM_INTERFACE_VERSION */
    ULONG Enabled;          /* 0 = silence, 1 = signal */
    ULONG Waveform;         /* VTM_WAVEFORM */
    ULONG FrequencyHz;      /* VTM_FREQUENCY_MIN_HZ .. VTM_FREQUENCY_MAX_HZ */
    ULONG AmplitudePercent; /* 0 .. VTM_AMPLITUDE_MAX_PERCENT */
} VTM_SIGNAL_PARAMS, *PVTM_SIGNAL_PARAMS;

/* Validation shared by driver (reject bad input) and library (fail early). */
#define VTM_PARAMS_VALID(p) (                                   \
    (p)->Version == VTM_INTERFACE_VERSION &&                    \
    (p)->Enabled <= 1 &&                                        \
    (p)->Waveform < VtmWaveformCount &&                         \
    (p)->FrequencyHz >= VTM_FREQUENCY_MIN_HZ &&                 \
    (p)->FrequencyHz <= VTM_FREQUENCY_MAX_HZ &&                 \
    (p)->AmplitudePercent <= VTM_AMPLITUDE_MAX_PERCENT)

/* ---- IOCTL codes -------------------------------------------------------- */
#define VTM_IOCTL_BASE  0x800   /* function codes 0x800+ are for vendors */

/* Input: none.               Output: VTM_SIGNAL_PARAMS */
#define IOCTL_VTM_GET_PARAMS \
    CTL_CODE(FILE_DEVICE_UNKNOWN, VTM_IOCTL_BASE + 0, METHOD_BUFFERED, FILE_READ_ACCESS)

/* Input: VTM_SIGNAL_PARAMS.  Output: none. Applied immediately, no stream restart. */
#define IOCTL_VTM_SET_PARAMS \
    CTL_CODE(FILE_DEVICE_UNKNOWN, VTM_IOCTL_BASE + 1, METHOD_BUFFERED, FILE_WRITE_ACCESS)

/* Input: none.               Output: ULONG (VTM_INTERFACE_VERSION of the driver) */
#define IOCTL_VTM_GET_VERSION \
    CTL_CODE(FILE_DEVICE_UNKNOWN, VTM_IOCTL_BASE + 2, METHOD_BUFFERED, FILE_ANY_ACCESS)

/* Reserved for later milestones (statistics, presets, ...): VTM_IOCTL_BASE + 0x10 and up. */

# lib/

User-mode communication library. Wraps the IOCTLs from `common/VirtualToneIoctl.h` behind a simple API:
find and open the device, get/set parameters, check the interface version, report when the driver is missing.

The GUI never calls `DeviceIoControl` directly (spec R6).

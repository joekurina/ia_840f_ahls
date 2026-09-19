#!/bin/sh

# Source-only safety lock: deliberately no environment-variable bypass.
printf '%s\n' 'IA840F SOURCE-ONLY PORT: generation/build disabled; see new_bsp/new/docs/asp-port.md. Requires explicit future authorization and reviewed prerequisites.' >&2
exit 78


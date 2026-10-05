# Copy and DMA debug findings

## Copy checker defect

The tutorial reader→data_stream_engine→writer path deliberately applies bitwise NOT (`data_stream_engine.sv:34`). The previously added identity oracle was wrong. A separate inversion-aware host passed the actual32×64-byte test on the unchanged image with nativePR0/host0/errors0. This does not settle the earlier4KiBcommandcompletiontimeout or reconstruct uncaptured predecessorbytes. [Copy outcome03](copy-outcome03.json).

## DMA size boundary and direction isolation

Actual pinned-buffer snapshots show unchanged poison in all destination words for unsplit512/1024-byte cases, immediately and100mslater; sourcecontentsremaincorrect.128/256-byte descriptors pass. Keeping H2D unchanged while splitting only D2H into256-byte descriptors makes both512-byte and1024-byte fullpayloadroundtrips pass with actualnativehost0. The1KiBcase uses oneH2Ddescriptor andfourD2Hdescriptors; it is a host workaround, not a repairedlarge-burst RTLclaim. [Paired results20](DMA-PAIRED-RESULTS20.json), [actual1KiBworkaround](host-only-result17-collection.json), [unmodifiedlargecasefailure](hardware-result05-collection.json).

## Source-predicted PU limit mismatch

Actual retained compile inputs, not older platform snapshots, show generated `FUNC_MODE "PU"` and `FUNC_MODE_IS_PU`. FIM `MAX_PAYLOAD_SIZE=128` is explicitly inDWORDs. Platform config multiplies by4, yielding512bytes; `PCIE_DM_ENCODING_EN=0` makes PIM use PU-size limits. PIM sizes its downstream512-bit AXI burst to8beats, and the gasket cannot selectDM encoding when that constant is0. [Hash-bound actualsources](PIM-source20-collection.json).

Standard PCIe DeviceControl read on PF0 was `0x2930`: MPS256bytes, MRRS512bytes. NoPCIeconfigwrite was made. Thus the retained source permits a512-byte PUwrite while the configured endpoint MPS is256. This is a concrete source/config contract mismatch consistent with the observedD2Hboundary. Wirepackets and physicalerrorcause were not captured; do not label sourceprediction as measuredwiretraffic or conflate this with the independently fixedcopyoracle. [Stable source/config collection](PIM-source20-collection.json).

The primary raw capture for that last source/config claim is the uniquely named `FIM-actual-payload-config19-examples01_*.log` in this directory; use `PIM-source20-collection.json` for stable archivedfilelinks. The exact log basename is transport-specific, not an assertedfileidentity.

## Next repair boundary

Independent source review `deleg_25f8767a` is checking the diagnosis and a supported AFU-side packet cap shared by copy andDMA, without changing the FIM/export or originals. Splitting must preserve completeburstdata, addressprogression, WLASTs and Bresponse aggregation; simply narrowing AWLEN is not a fix. Copy's4KiBtimeout, DMAread-responseerrorvisibility, and broaderreset/drainhealth remain unqualified. NoFPGAresynthesis has been performed.

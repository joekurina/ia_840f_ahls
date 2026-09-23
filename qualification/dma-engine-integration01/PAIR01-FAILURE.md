# First combined-engine result — descriptor counter failure

Native version/vlib/vdir/vlog/vsim all returned0; the simulator reported a fatal assertion and the outer runner returned1. At cycle171/1776ns, the first one-beat transfer had a descriptor dequeue but the public reader descriptor counter remained wrong. Error: `descriptor counter missed successful dequeue`. Preserve pair01 inputs/runner/result/logs; no hardware operation.

The old update is under `next[WAIT_FOR_WR_RSP_BIT]`. The actual dequeue is asserted in current WAIT when wr_fsm_done is true, which selects next IDLE; that update therefore misses the event. Candidate pair02 moves the same four-bit counter increment into the clocked nonreset default, preserving all functional datapath/control and reset behavior. The patch applies after the accepted reader AR fix, not to pristine donor. Counter wrap remains modulo16, not a monotonic count; this test covers consecutive increments, not wrap exhaustion.

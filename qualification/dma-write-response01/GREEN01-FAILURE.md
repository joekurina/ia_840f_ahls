# First candidate failure — preserved

Native compiler/simulator commands returned0; functional test and outer runner returned failure/1 at cycle606,6116ns: `spurious response error`. No timeout or native group survived. `result-green01.json`, `outer-green01.json`, `run-green01.py` and `inputs-candidate/` remain unchanged.

Source explanation: raw response_bad combinationally tests credit against registered b_accepted. After the accepting edge advances b_accepted, the same BVALID/payload remains present until the fixture's next falling-edge update; the raw check can then look uncredited. OR-ing that into the error-status output exposes a transient as an error even though the sticky error register did not capture a bad reply at an accepting edge. No waveform was captured; this is a source/timing explanation of the observed assertion, not a quoted waveform.

Fresh green02 changes only that status assignment to the clocked sticky response_error. The clocked error capture and same-edge invalid-response blocking of success remain. The failed candidate/hash and final differential binding are retained in source-binding02.json; earlier baseline failures use the identical final testbench and do not require rerun.

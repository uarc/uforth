#####
##### Init
#####

:INIT
jenteri:QUIT

#####
##### Dictionary
#####

:(run)_NAME
i:5
i:"(run)
:(run)
# TODO: All

:base_NAME
i:4
i:"base
:base
ld0i
$base_DSP read0 write3
0x30 jenteri:DEFER

:DEFER_NAME
i:5
i:"DEFER
:DEFER
ld0i
# TODO: All

:HEREP!_NAME
i:6
i:"HEREP!
:HEREP!
ld0i
# Check if we are in run mode or compile mode.
$shell_xt_DSP readi $(run)_XT jeq:DEFER+
# Compile mode
# TODO: Add to program.
return
:DEFER+
# Run mode
# TODO: Execute immediately.
return

:HEREP@_NAME
i:6
i:"HEREP@
:HEREP@
# The value is stored directly in the DSP, so retrieve it indirectly.
readi
return

:INTERPRET_NAME
i:9
i:"INTERPRET
:INTERPRET
ld0i
:INTERPRET-
# TODO: Interpret loop
jmpi:INTERPRET-

:NUMBER_NAME
i:6
i:"NUMBER
:NUMBER
# TODO: All

:QUIT_NAME
i:4
i:"QUIT
:QUIT
ld0i
# Reset the processor.
$QUIT+ .QUIT+ read0 read0 reset
# Perform an infinite loop of INTERPRET
:QUIT-
ld0i enteri:INTERPRET
:QUIT+
jenteri:QUIT-

:shell_xt_NAME
i:8
i:"shell_xt
:shell_xt
# TODO: All

#####
##### Backstack
#####

:shell_xt_XT
.shell_xt :shell_xt_DSP $(run)_XT $shell_xt_NAME i:0b1

:INTERPRET_XT
.INTERPRET $INTERPRET $INTERPRET_NAME i:0b0

:base_XT
.base :base_DSP fill:10,1 $base_NAME i:0b1

:(run)_XT
.(run) $(run) $(run)_NAME i:0b0

# Align the segments
alignp:0x3C,2048
align:0,2048

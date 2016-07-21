:INIT
jmpi:QUIT

:(run)_NAME
i:5
i:"(run)
:(run)

:base_NAME
i:4
i:"base
:base
$base_DSP read0 write3
0x30 jumpi:DEFER

:DEFER_NAME
i:5
i:"DEFER
:DEFER

:HEREP!_NAME
i:6
i:"HEREP!
:HEREP!

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
jmpi:INTERPRET-

:NUMBER_NAME
i:6
i:"NUMBER
:NUMBER

:QUIT_NAME
i:4
i:"QUIT
:QUIT
ld0i
# Reset the processor, immediately moving to the location after this.
$QUIT+ .QUIT+ read0 read0 reset
:QUIT+
# Perform an infinite loop of INTERPRET
:QUIT-
enteri:INTERPRET
jmpi:QUIT-

:shell_xt_NAME
i:8
i:"shell_xt
:shell_xt

:shell_xt_XT
.shell_xt $shell_xt $shell_xt_NAME i:0b1

:CONTINUE_XT
.CONTINUE $CONTINUE $CONTINUE_NAME i:0b0

:base_XT
.base :base_DSP fill:10,1 $base_NAME i:0b1

:(run)_XT
.(run) $(run) $(run)_NAME i:0b0

# Align the segments
alignp:0x3C,2048
align:0,2048

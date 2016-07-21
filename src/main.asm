:INIT
jmpi:QUIT

:base_NAME
i:4
i:"base
:base
$base_DSP read0 write3
0x30 jumpi:DEFER

:CONTINUE_NAME
i:8
i:"CONTINUE
:CONTINUE
ld0i
:CONTINUE-
jmpi:CONTINUE-

:DEFER_NAME
i:5
i:"DEFER
:DEFER

:HEREP!_NAME
i:6
i:"HEREP!
:HEREP!

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
jenteri:CONTINUE

:CONTINUE_XT
.CONTINUE $CONTINUE $CONTINUE_NAME i:0b0

:base_XT
.base :base_DSP fill:10,1 $base_NAME i:0b1

# Align the segments
alignp:0x3C,2048
align:0,2048

:INIT
jmpi:QUIT

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

:QUIT_NAME
i:4
i:"QUIT

:QUIT
ld0i
# Reset the processor, immediately moving to the location after this.
$QUIT+ .QUIT+ read0 read0 reset
:QUIT+
0 slb
$KEYBOARD_INTERRUPT iset:KEYBOARD_INTERRUPT
ien
jenteri:CONTINUE

# Interrupt tag
:KEYBOARD_INTERRUPT
# Inside the interrupt, echo the value back
cv1 send
return

:DEFER

:CONTINUE_XT
.CONTINUE $CONTINUE $CONTINUE_NAME i:0b0

# Align the segments
alignp:0x3C,2048
align:0,2048

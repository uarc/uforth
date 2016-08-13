#####
##### Init
#####

:INIT

#####
##### Dictionary
#####

:!_name $1 $"!
:!
# Compile mode
calli:STATE bz:+
    imm8:0x68 calli:DEFER
    bra:++
# Run (or other) mode
+
    write
++

:'_name $1 $"'
:'
# Set dc0 to the back stack.
push0 calli:hereb reads set0
# Get the string address and length on the stack.
calli:pp reads dup calli:BL calli:DWORD
# Place the string length in an immediate location in the loop.
writepri:+++
# Iterate through every dictionary entry.
iloop:+
    # Check if we reached the end of the dictionary
    get0 bnz:++
        # If so, then return 0.
        # Restore state.
        drop pop0 discard
        imm8:0 return
    ++
    # Duplicate this string address for next iteration
    dup
    # Lookup and get expanded string addr count combination from dictionary entry.
    # Offset of 2 on dictionary entry.
    rareadi0:2 calli:COUNT
    # Get this string length
    imm32 +++ pfill:0,4
    # Compare the two strings
    calli:STREQ bz:++
        # Found a match, so return the xt.
        drop read0:0
        # Restore state.
        pop0 discard return
    ++
    continue
+

:(compile)_name $9 $"(compile)
:(compile)

:(run)_name $5 $"(run)
:(run)

:*_name $1 $"*
:*

:*/_name $2 $"*/
:*/

:*/MOD_name $5 $"*/MOD
:*/MOD

:+_name $1 $"+
:PLUS

:+!_name $2 $"+!
:+!

:,_name $1 $",
:,

:-_name $1 $"-
:MINUS

:._name $1 $".
:.

:."_name $2 $"."
:."

:/_name $1 $"/
:/

:/MOD_name $4 $"/MOD
:/MOD

:0<_name $2 $"0<
:0<

:0=_name $2 $"0=
:0=

:1+_name $2 $"1+
:1+

:1-_name $2 $"1-
:1-

:2*_name $2 $"2*
:2*

:2/_name $2 $"2/
:2/

::_name $1 $":
::

:;_name $1 $";
:;

:<_name $1 $"<
:<

:=_name $1 $"=
:=

:>_name $1 $">
:>

:>BODY_name $5 $">BODY
:>BODY

:@_name $1 $"@
:@

:ABORT_name $5 $"ABORT
:ABORT

:ABORT"_name $6 $"ABORT"
:ABORT"

:ABS_name $3 $"ABS
:ABS

:ACCEPT_name $6 $"ACCEPT
:ACCEPT

:ALLOT_name $5 $"ALLOT
:ALLOT

:AND_name $3 $"AND
:AND

:base_name $4 $"base
:base

:BL_name $2 $"BL
:BL

:BODY_name $4 $"BODY
:BODY

:BS_name $2 $"BS
:BS

:COMPILE,_name $8 $"COMPILE,
:COMPILE,

:CONSTATNT_name $9 $"CONSTATNT
:CONSTATNT

:CONTINUE_name $8 $"CONTINUE
:CONTINUE

:COPY:_name $5 $"COPY:
:COPY:

:COUNT_name $5 $"COUNT
:COUNT

:CR_name $2 $"CR
:CR

:CREATE_name $6 $"CREATE
:CREATE

:DECIMAL_name $7 $"DECIMAL
:DECIMAL

:DEFER_name $5 $"DEFER
:DEFER

:DO_name $2 $"DO
:DO

:DOES_name $4 $"DOES
:DOES

:DOES>_name $5 $"DOES>
:DOES>

:DROP_name $4 $"DROP
:DROP

:DUP_name $3 $"DUP
:DUP

:DWORD_name $5 $"DWORD
:DWORD

:ELSE_name $4 $"ELSE
:ELSE

:EMIT_name $4 $"EMIT
:EMIT

:EXECUTE_name $7 $"EXECUTE
:EXECUTE

:EXIT_name $4 $"EXIT
:EXIT

:FALSE_name $5 $"FALSE
:FALSE

:FILL_name $4 $"FILL
:FILL

:FIND_name $4 $"FIND
:FIND

:FORGET_name $6 $"FORGET
:FORGET

:HERE_name $4 $"HERE
:HERE

:hered_name $5 $"hered
:hered

:herep_name $5 $"herep
:herep

:hereb_name $5 $"hereb
:hereb

:HEX_name $3 $"HEX
:HEX

:I_name $1 $"I
:I

:IDO_name $3 $"IDO
:IDO

:IF_name $2 $"IF
# IF is in the same location as IFZ!, look further down for its tag

:IF=_name $3 $"IF=
:IF=

:IF!=_name $4 $"IF!=
:IF!=

:IF>_name $3 $"IF>
:IF>

:IF>=_name $4 $"IF>=
:IF>=

:IF>U_name $4 $"IF>U
:IF>U

:IF>=U_name $5 $"IF>=U
:IF>=U

:IFC_name $3 $"IFC
:IFC

:IFC!_name $4 $"IFC!
:IFC!

:IFO_name $3 $"IFO
:IFO

:IFO!_name $4 $"IFO!
:IFO!

:IFI_name $3 $"IFI
:IFI

:IFI!_name $4 $"IFI!
:IFI!

:IFZ_name $3 $"IFZ
:IFZ

:IFZ!_name $4 $"IFZ!
# This is also the tag for IF
:IFZ! :IF

:IFA_name $3 $"IFA
:IFA

:IFA!_name $4 $"IFA!
:IFA!

:IMMEDIATE_name $9 $"IMMEDIATE
:IMMEDIATE

:INTERPRET_name $9 $"INTERPRET
:INTERPRET

:J_name $1 $"J
:J

:K_name $1 $"K
:K

:KEY_name $3 $"KEY
:KEY

:KEY?_name $4 $"KEY?
:KEY?

:L_name $1 $"L
:L

:LEAVE_name $5 $"LEAVE
:LEAVE

:LITERAL_name $7 $"LITERAL
:LITERAL

:LOOP_name $4 $"LOOP
:LOOP

:LSHIFT_name $6 $"LSHIFT
:LSHIFT

:MAX_name $3 $"MAX
:MAX

:MIN_name $3 $"MIN
:MIN

:MOD_name $3 $"MOD
:MOD

:MOVE_name $4 $"MOVE
:MOVE

:NEGATE_name $6 $"NEGATE
:NEGATE

:NIP_name $3 $"NIP
:NIP

:NL_name $2 $"NL
:NL

:NUMBER_name $6 $"NUMBER
:NUMBER

:OR_name $2 $"OR
:OR

:OVER_name $4 $"OVER
:OVER

:pa_name $2 $"pa
:pa

:POSTPONE_name $8 $"POSTPONE
:POSTPONE

:pp_name $2 $"pp
:pp

:QUIT_name $4 $"QUIT
:QUIT

:RECURSE_name $7 $"RECURSE
:RECURSE

:REVEAL_name $6 $"REVEAL
:REVEAL

:ROT_name $3 $"ROT
:ROT

:ROT:_name $4 $"ROT:
:ROT:

:RSHIFT_name $6 $"RSHIFT
:RSHIFT

:S"_name $2 $"S"
:S"

:SCAN_name $4 $"SCAN
:SCAN

:shell_xt_name $8 $"shell_xt
:shell_xt

:SPACE_name $5 $"SPACE
:SPACE

:SPACES_name $6 $"SPACES
:SPACES

:STATE_name $5 $"STATE
:STATE

:STREQ_name $5 $"STREQ
:STREQ

:THEN_name $4 $"THEN
:THEN

:TRUE_name $4 $"TRUE
:TRUE

:TUCK_name $4 $"TUCK
:TUCK

:TYPE_name $4 $"TYPE
:TYPE

:U._name $2 $"U.
:U.

:U<_name $2 $"U<
:U<

:U*_name $2 $"U*
:U*

:UNLOOP_name $6 $"UNLOOP
:UNLOOP

:VARIABLE_name $8 $"VARIABLE
:VARIABLE

:WORD_name $4 $"WORD
:WORD

:WORDS_name $5 $"WORDS
:WORDS

:XOR_name $3 $"XOR
:XOR

:XT>NAME_name $7 $"XT>NAME
:XT>NAME

:[_name $1 $"[
:[

:]_name $1 $"]
:

# Align the segments
palign:0x3C,2048
# Data must be aligned such that the backstack consumes the rest of memory.
malign:0,2048

:backstack_head

#####
##### Backstack
#####

:'_xt $.' $$' $$'_name $0
:!_xt $.! $$! $$!_name $1

#####
##### Init
#####

:INIT
# Select bus 0 for communication.
imm8:0 seb
bra:INIT

#####
##### Dictionary
#####

:!_name $1 $"!
:!
# Compile mode
callri:STATE bz:+
    imm8:0x68 bra:DEFERO
# Run (or other) mode
+
    write
    return
++

:'_name $1 $"'
:'
# Get the string address and length on the stack.
callri:pp reads dup callri:BL callri:DWORD
# Call find with a tail-call optimization.
bra:FIND

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
dup inc rot1 reads
return

:CR_name $2 $"CR
:CR
# Compile mode
callri:STATE bz:+
    # Defer imm8:0xD with a tail call optimization.
    imm16:0x0D94 bra:DEFERS
# Run (or other) mode
+
    imm8:0xD
    return
++

:CREATE_name $6 $"CREATE
:CREATE
callri:hereb addi:-4
# Set the word's program address.
callri:herep reads copy1 write
# Copy the string to hered.
callri:BL callri:WORD copy1 addi:2 write
# Set the word's data space address.
callri:hered reads copy1 addi:1 write
# Set the word's immediate to 0.
imm8:0 copy1 addi:3 write
return

:DECIMAL_name $7 $"DECIMAL
:DECIMAL
imm8:10 callri:base write
return

:DEFERO_name $6 $"DEFERO
:DEFERO
# Aquire the address of the program head pointer.
callri:herep
# Copy the address, read from it, and store the short to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writepo
# Advance the program pointer by 1 and write back the new head.
inc rot1 write
return

:DEFERS_name $6 $"DEFERS
:DEFERS
# Aquire the address of the program head pointer.
callri:herep
# Copy the address, read from it, and store the short to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writeps
# Advance the program pointer by 2 (the amount of octets in a short) and write back the new head.
addi:2 rot1 write
return

:DEFERW_name $6 $"DEFERW
:DEFERW
# Aquire the address of the program head pointer.
callri:herep
# Copy the address, read from it, and store the value to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writep
# Advance the program pointer by 4 (the amount of octets in a processor word) and write back the new head.
addi:4 rot1 write
return

:DO_name $2 $"DO
:DO
imm8:0xAA callri:DEFERO
callri:herep reads
imm8:0 bra:DEFERS

:DOES_name $4 $"DOES
:DOES
# FIXME: Better optimized with a `bra` instead of `jmpi`.
callri:herep reads addi:10 imm8:0x96 callri:DEFERO callri:DEFERW
imm8:0x1C callri:DEFERO
.DOIT bra:DEFERW

:DOIT
callri:hereb reads addi:-4 write
return

:DOES>_name $5 $"DOES>
:DOES>
# FIXME: Better optimized with a `bra` instead of `jmpi`.
callri:herep reads addi:10 imm8:0x96 callri:DEFERO callri:DEFERW
imm8:0x1C callri:DEFERO
.DODOES bra:DEFERW

:DODOES
# Perfom the functionality of DOIT (which consumes the program address)
callri:DOIT
# Then also add some code to produce the data space pointer of the new word in the new word before starting it.
callri:hereb reads addi:-3 reads bra:LITERAL

:DROP_name $4 $"DROP
:DROP
# Compile mode
callri:STATE bz:+
    # Defer `drop` with a tail call optimization.
    imm8:0xAF bra:DEFERO
# Run (or other) mode
+
    drop
    return
++

:DUP_name $3 $"DUP
:DUP
# Compile mode
callri:STATE bz:+
    # Defer `copy0` with a tail call optimization.
    imm8:0xE0 bra:DEFERO
# Run (or other) mode
+
    copy0
    return
++

:DWORD_name $5 $"DWORD
:DWORD
push0
writepri:++
set0

iloop:+
    read0:1 imm32 ++ pfill:0,4 beq:+++
        i0 pop0 discard return
    +++
    continue
+

:ELSE_name $4 $"ELSE
:ELSE
# Defer a branch always.
imm8:0x1D callri:DEFERO
# Get the herep address.
callri:herep reads
# Defer 16-bits to be replaced by the `THEN`.
imm8:0 callri:DEFERS
# Compute the branch offset.
dup copy2 sub addi:3 rot3 write
# At this point only the replacement address is left on the stack, so return.
return

:EMIT_name $4 $"EMIT
:EMIT
# Compile mode
callri:STATE bz:+
    # Defer `intsend` with a tail call optimization.
    imm8:0xA9 bra:DEFERO
# Run (or other) mode
+
    intsend
    return
++

:EXECUTE_name $7 $"EXECUTE
:EXECUTE
# Compile mode
callri:STATE bz:+
    # Defer `call` with a tail call optimization.
    imm8:0xA3 bra:DEFERO
# Run (or other) mode
+
    # Do a tail call optimized call to the param.
    jmp
++

:EXIT_name $4 $"EXIT
:EXIT
# Compile mode
callri:STATE bz:+
    # Defer `return` with a tail call optimization.
    imm8:0x12 bra:DEFERO
# Run (or other) mode
+
    # TODO: Print a message warning the user that this is impossible.
    return
++

:FALSE_name $5 $"FALSE
:FALSE
# Compile mode
callri:STATE bz:+
    # Defer `imm8:0` with a tail call optimization.
    imm16:0x0094 bra:DEFERS
# Run (or other) mode
+
    imm8:0
    return
++

:FILL_name $4 $"FILL
:FILL
push0 set0
writepri:++
loop:+
    imm32 ++ pfill:0,4
    writepst0:1
+
pop1
return

:FIND_name $4 $"FIND
:FIND
# Set dc0 to the back stack.
push0 callri:hereb reads set0
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
    # Get this string length
    imm32 +++ pfill:0,4
    # Lookup and get expanded string addr count combination from dictionary entry.
    # Offset of 2 on dictionary entry.
    rareadi0:2 callri:COUNT
    # Compare the two strings
    callri:STREQ bz:++
        # Found a match, so return the xt.
        drop read0:3
        # Set the carry bit to 1 if this is an immediate instruction (this is for internal use).
        imm8:-1 read0:0 add drop
        # Restore state.
        pop0 discard return
    ++
    # Need a continue here because we cannot branch to the end of the loop.
    continue
+

:FORGET_name $6 $"FORGET
:FORGET

:HERE_name $4 $"HERE
:HERE
callri:hered reads
return

:hered_name $5 $"hered
:hered
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$hered_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$hered_var
    return
++

:hered_var $$dictionary_end

:herep_name $5 $"herep
:herep
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$herep_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$herep_var
    return
++

:herep_var $.dictionary_end

:hereb_name $5 $"hereb
:hereb
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$hereb_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$hereb_var
    return
++

:hereb_var $$backstack_head

:HEX_name $3 $"HEX
:HEX
imm8:16 callri:base write
return

:I_name $1 $"I
:I
# Compile mode
callri:STATE bz:+
    # Defer `i0` with a tail call optimization.
    imm8:0x3C bra:DEFERO
# Run (or other) mode
+
    i0
    return
++

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
# Compile mode
callri:STATE bz:+
    # Defer `i1` with a tail call optimization.
    imm8:0x3D bra:DEFERO
# Run (or other) mode
+
    i1
    return
++

:K_name $1 $"K
:K
# Compile mode
callri:STATE bz:+
    # Defer `i2` with a tail call optimization.
    imm8:0x3E bra:DEFERO
# Run (or other) mode
+
    i2
    return
++

:KEY_name $3 $"KEY
:KEY

:KEY?_name $4 $"KEY?
:KEY?

:L_name $1 $"L
:L
# Compile mode
callri:STATE bz:+
    # Defer `i3` with a tail call optimization.
    imm8:0x3F bra:DEFERO
# Run (or other) mode
+
    i3
    return
++

:LEAVE_name $5 $"LEAVE
:LEAVE
# Compile mode
callri:STATE bz:+
    # Defer `break` with a tail call optimization.
    imm8:0x11 bra:DEFERO
# Run (or other) mode
+
    break
++

:LITERAL_name $7 $"LITERAL
:LITERAL
# TODO: Use imm8, imm16, or imm32 depending on the number.
# Defer `imm32`.
imm8:0x96 callri:DEFERO
# Defer the immediate literal and perform a tail call optimization.
bra:DEFERW

:LOOP_name $4 $"LOOP
:LOOP

:LSHIFT_name $6 $"LSHIFT
:LSHIFT
# Compile mode
callri:STATE bz:+
    # Defer `lsl` with a tail call optimization.
    imm8:0x5A bra:DEFERO
# Run (or other) mode
+
    lsl
    return
++

:MAX_name $3 $"MAX
:MAX
copy1 copy1 bles:+
    drop
    return
+
    rot1 drop
    return

:MIN_name $3 $"MIN
:MIN
copy1 copy1 bles:+
    rot1 drop
    return
+
    drop
    return

:MOD_name $3 $"MOD
:MOD

:MOVE_name $4 $"MOVE
:MOVE
push0 push1
set1 set0
loop:+
    read0:1 writepst0:1
+
pop1 pop0
return

:NEGATE_name $6 $"NEGATE
:NEGATE
# Compile mode
callri:STATE bz:+
    # Defer `subi:0` with a tail call optimization.
    imm16:0x0083 bra:DEFERS
# Run (or other) mode
+
    subi:0
    return
++

:NIP_name $3 $"NIP
:NIP
# Compile mode
callri:STATE bz:+
    # Defer `rot1 drop` with a tail call optimization.
    imm16:0xAFC1 bra:DEFERS
# Run (or other) mode
+
    rot1 drop
    return
++

:NL_name $2 $"NL
:NL
# Compile mode
callri:STATE bz:+
    # Defer imm8:0xA with a tail call optimization.
    imm16:0x0A94 bra:DEFERS
# Run (or other) mode
+
    imm8:0xA
    return
++

:NUMBER_name $6 $"NUMBER
:NUMBER

:OR_name $2 $"OR
:OR
# Compile mode
callri:STATE bz:+
    # Defer an or with a tail call optimization.
    imm8:0xA0 bra:DEFERO
# Run (or other) mode
+
    or
    return
++

:OVER_name $4 $"OVER
:OVER
# Compile mode
callri:STATE bz:+
    # Defer a rot1 with a tail call optimization.
    imm8:0xC1 bra:DEFERO
# Run (or other) mode
+
    rot1
    return
++

:pa_name $2 $"pa
:pa
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$pa_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$pa_var
    return
++

:pa_var $$pa_pad

:pa_pad mfill:0,128

:POSTPONE_name $8 $"POSTPONE
:POSTPONE

:pp_name $2 $"pp
:pp
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$pp_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$pp_var
    return
++

:pp_var mfill:0,1

:QUIT_name $4 $"QUIT
:QUIT
imm8:0 dup reset

:RECURSE_name $7 $"RECURSE
:RECURSE
callri:hereb reads addi:-4 reads bra:COMPILE,

:REVEAL_name $6 $"REVEAL
:REVEAL
callri:hereb dup reads addi:-4 rot1 write
return

:ROT_name $3 $"ROT
:ROT
# Compile mode
callri:STATE bz:+
    # Defer `rot2` with tail-call optimization.
    imm8:0xC2 bra:DEFERO
# Run (or other) mode
+
    rot2
    return
++

:ROT:_name $4 $"ROT:
:ROT:
# Compile mode
callri:STATE bz:+
    # Defer `rot#`.
    callri:NUMBER imm8:0xC0 add bra:DEFERO
# Run (or other) mode
+
    # TODO: This should display an error.
    return
++

:RSHIFT_name $6 $"RSHIFT
:RSHIFT
# Compile mode
callri:STATE bz:+
    # Defer `lsr`.
    imm8:0x5B bra:DEFERO
# Run (or other) mode
+
    lsr
    return
++

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
copy2 beq:+
    ddrop drop imm8:0 return
+
push0 push1 set0 rot1 set1
loop:+
    read0:1 read1:1 beq:++
        pop1 pop0 discard imm8:0 return
    ++
    continue
+
pop1 pop0 imm8:1 return

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

:dictionary_end

# Align the segments
palign:0x3C,2048
# Data must be aligned such that the backstack consumes the rest of memory.
malign:0,2040

:backstack_head

#####
##### Backstack
#####

:'_xt $.' $$' $$'_name $0
:!_xt $.! $$! $$!_name $1

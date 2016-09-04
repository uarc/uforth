#####
##### Init
#####

:INIT
# Select bus 0 for communication.
imm8:0 seb
# Begin infinite user input + interpret loop.
-
# Set the processing position to the processing area address.
imm16:$pa_var reads imm16:$pp_var write
# Get characters from the user.
iloop:+
    intrecv
    # Check if it was a backspace.
    dup imm8:8 bne:++
        # It was a backspace, but check if we have any characters at all before moving back.
        imm16:$pa_var reads imm16:$pp_var reads beq:+++
            # We got a backspace and we have characters to undo.
            # Decrement the processing position.
            imm16:$pp_var reads dec imm16:$pp_var write
            # Send the backspace character to the terminal.
            intsend
            continue
        +++
            # We got a backspace, but there are no characters in the input buffer, so do nothing.
            drop continue
    ++
    # Check if it was a carriage return (enter key).
    dup imm8:13 bne:++
        # It was, so insert two spaces in the pad for internal reasons.
        imm16:$pp_var reads
        imm8:0x20 copy1 write inc
        imm8:0x20 copy1 write inc
        imm16:$pp_var write
        # Print out a newline character to the terminal.
        imm8:10 intsend
        # Exit the loop to interpret.
        drop break
    ++
    # Any other key needs to be added to the input buffer.
    imm16:$pp_var reads dup inc imm16:$pp_var write write
+
# Set the pp back to the processing area.
imm16:$pa_var reads imm16:$pp_var write
callri:INTERPRET
bra:-

#####
##### Dictionary
#####

:!_name $1 $"!
:!
# Compile mode
callri:STATE bz:+
    # Defer `write`.
    imm8:0x68 bra:DEFERO
# Run (or other) mode
+
    write
    return
++

:'_name $1 $"'
:'
# Get the string address and length on the stack.
imm16:$pp_var reads dup imm8:0x20 callri:DWORD
# Update pp variable now that the word has been parsed to move it to the next word.
dup inc copy2 add imm16:$pp_var write
# Call find with a tail-call optimization.
bra:FIND

:(compile)_name $9 $"(compile)
:(compile)
callri:[
# Get the next word string on the stack as addr n format, but leave an extra ending address underneath on the stack.
# Perform the increment here so we don't interfere with the carry bit later.
imm8:0x20 imm8:64 callri:SCAN dup imm16:$pp_var reads sub rot1 inc rot1 imm16:$pp_var reads rot1
# Find the word with the name.
callri:FIND
callri:]
# Check if the word was found at all.
dup bz:+
    # It was found.
    # Advance the pp after the word.
    rot1 imm16:$pp_var write
    # Check if it is immediate or not.
    bc:++
        # It is not immediate, so compile it into the current word.
        bra:COMPILE,
    ++
        # It is immediate, so call it with tail call optimization (jump).
        jmp
    +++
+
ddrop
# If it wasn't found, try parsing it as a NUMBER.
callri:NUMBER
# Compile the number literal into the program with a tail-call optimization.
bra:LITERAL

:(run)_name $5 $"(run)
:(run)
# Get the next word string on the stack as addr n format, but leave an extra ending address underneath on the stack.
imm8:0x20 imm8:64 callri:SCAN dup imm16:$pp_var reads sub imm16:$pp_var reads rot1
# Find the word with the name.
callri:FIND
# Check if the word was found at all.
dup bz:+
    # It was found.
    # Advance the pp after the word.
    rot1 inc imm16:$pp_var write
    # Regardless of if it is immediate or not, run it with a tail-call optimization.
    jmp
+
ddrop
# If it wasn't found, try parsing it as a NUMBER with a tail-call optimization.
bra:NUMBER

:*_name $1 $"*
:*
dup imm8:0 bles:+
    # First number is positive.
    rot1 dup imm8:0 bles:++
        # Second number is positive.
        bra:U*
    ++
        # Second number is negative.
        subi:0
        callri:U* subi:0
        return
+
    # Top number is negative.
    subi:0
    rot1 dup imm8:0 bles:++
        # Second number is positive.
        callri:U* subi:0
        return
    ++
        # Second number is negative.
        subi:0
        bra:U*

:*/_name $2 $"*/
:*/
rot2 rot2 callri:* rot1 bra:/

:*/MOD_name $5 $"*/MOD
:*/MOD
rot2 rot2 callri:* rot1 bra:/MOD

:+_name $1 $"+
:PLUS
# Compile mode
callri:STATE bz:+
    # Defer a `add` with a tail call optimization.
    imm8:0x58 bra:DEFERO
# Run (or other) mode
+
    add
    return
++

:+!_name $2 $"+!
:+!
rot1 copy1 reads add rot1 write
return

:,_name $1 $",
:,
imm16:$hered_var reads write imm16:$hered_var reads inc imm16:$hered_var write
return

:-_name $1 $"-
:MINUS
# Compile mode
callri:STATE bz:+
    # Defer a `sub` with a tail call optimization.
    imm8:0x59 bra:DEFERO
# Run (or other) mode
+
    sub
    return
++

:._name $1 $".
:.
dup imm8:0 bles:+
    bra:U.
+
    # It was less than 0 so print a negative sign.
    imm8:45 intsend
    subi:0 bra:U.

:."_name $2 $"."
:."
# Get the string into the data space and get the address.
imm8:0x22 callri:WORD
# Since the pp is moved after the quotation, its on the space, so move it forwards one more character.
imm16:$pp_var dup reads inc rot1 write
# Defer the loading of the address at runtime.
callri:LITERAL
# Defer `COUNT`.
imm16:.COUNT callri:COMPILE,
# Defer `TYPE` with tail-call optimization.
imm16:.TYPE bra:COMPILE,

:/_name $1 $"/
:/
callri:/MOD rot1 drop
return

:/MOD_name $4 $"/MOD
:/MOD
dup bnz:+
    # TODO: Add error message for divide by zero.
    bra:QUIT
+
# Add quotient then remainder to stack.
imm8:0 dup
WORD_BITS loop:+
    # Shift remainder to left by 1.
    lsli:1
    # Circular shift left a copy of the numerator by i + 1.
    copy3 i0 inc csl
    # Or the lowest bit into the remainder.
    andi:1 or
    # Check if the remainder is greater than or equal to the divisor.
    copy0 copy3 bles:++
        # It was greater or equal, so subtract it from the remainder.
        copy2 sub
        # Add a one at bit position (31 - i) in the quotient.
        rot1 imm8:1 i0 inc csr or rot1
    ++
+
# Get rid of the numerator and the divisor.
rot3 rot3 ddrop
# Swap remainder and quotient.
rot1
return

:0<_name $2 $"0<
:0<
imm8:0 bles:+
    imm8:0
    return
+
    imm8:1
    return
++

:0=_name $2 $"0=
:0=
bz:+
    imm8:0
    return
+
    imm8:1
    return
++

:1+_name $2 $"1+
:1+
# Compile mode
callri:STATE bz:+
    # Defer an `inc` with a tail call optimization.
    imm8:0x0C bra:DEFERO
# Run (or other) mode
+
    inc
    return
++

:1-_name $2 $"1-
:1-
# Compile mode
callri:STATE bz:+
    # Defer a `dec` with a tail call optimization.
    imm8:0x0D bra:DEFERO
# Run (or other) mode
+
    dec
    return
++

:2*_name $2 $"2*
:2*
# Compile mode
callri:STATE bz:+
    # Defer an `lsli:1` with a tail call optimization.
    imm16:0x0184 bra:DEFERS
# Run (or other) mode
+
    lsli:1
    return
++

:2/_name $2 $"2/
:2/
# Compile mode
callri:STATE bz:+
    # Defer an `asri:1` with a tail call optimization.
    imm16:0x0186 bra:DEFERS
# Run (or other) mode
+
    asri:1
    return
++

::_name $1 $":
::
callri:CREATE
# Enter compilation mode.
bra:]

:;_name $1 $";
:;
# While in compile mode, call EXIT.
callri:EXIT
# Enter run mode.
callri:[
# Reveal the word in the dictionary with a tail call optimization.
bra:REVEAL

:<_name $1 $"<
:<
bles:+
    imm8:0
    return
+
    imm8:1
    return
++

:<=_name $2 $"<=
:<=
bleq:+
    imm8:0
    return
+
    imm8:1
    return
++

:=_name $1 $"=
:=
beq:+
    imm8:0
    return
+
    imm8:1
    return
++

:>_name $1 $">
:>
bleq:+
    imm8:1
    return
+
    imm8:0
    return
++

:>=_name $2 $">=
:>=
bles:+
    imm8:1
    return
+
    imm8:0
    return
++

:@_name $1 $"@
:@
# Compile mode
callri:STATE bz:+
    # Defer an `read cv0` with a tail call optimization.
    imm16:0x20A2 bra:DEFERS
# Run (or other) mode
+
    reads
    return
++

:ABORT"_name $6 $"ABORT"
:ABORT"
# Immedate word so append the semantics of ABORT" rather than performing it.
callri:." imm16:.QUIT bra:COMPILE,

:ABS_name $3 $"ABS
:ABS
dup imm8:0 bles:+
    return
+
    subi:0
    return
++

:ACCEPT_name $6 $"ACCEPT
:ACCEPT
push0 set0
loop:+
    intrecv cv1 writepst0:1
+
get0 pop0
return

:ALLOT_name $5 $"ALLOT
:ALLOT
imm16:$hered_var reads add imm16:$hered_var write
return

:AND_name $3 $"AND
:AND
# Compile mode
callri:STATE bz:+
    # Defer an `and` with a tail call optimization.
    imm8:0x5F bra:DEFERO
# Run (or other) mode
+
    and
    return
++

:base_name $4 $"base
:base
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$base_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$base_var
    return
++

:base_var $10

:BL_name $2 $"BL
:BL
# Compile mode
callri:STATE bz:+
    # Defer imm8:0x20 with a tail call optimization.
    imm16:0x2094 bra:DEFERS
# Run (or other) mode
+
    imm8:0x20
    return
++

:BODY_name $4 $"BODY
:BODY
imm16:$hereb_var reads inc reads
return

:BS_name $2 $"BS
:BS
# Compile mode
callri:STATE bz:+
    # Defer imm8:0x08 with a tail call optimization.
    imm16:0x0894 bra:DEFERS
# Run (or other) mode
+
    imm8:0x08
    return
++

:COMPILE,_name $8 $"COMPILE,
:COMPILE,
# Compute the PC 16-bit relative offset between the execution token and herep.
imm16:$herep_var reads sub
# Defer `callri`.
imm8:0x1F callri:DEFERO
# Defer the immediate parameter to `callri` with a tail call optimization.
bra:DEFERS

:CONSTANT_name $8 $"CONSTANT
:CONSTANT
callri:CREATE
# Defer `imm32:val`.
imm8:0x96 callri:DEFERO callri:DEFERW
# Defer `callri:DOCON` with a tail call optimization.
imm16:.DOCON bra:COMPILE,

:DOCON
# Compile mode
callri:STATE bz:+
    bra:LITERAL
# Run (or other) mode
+
    # It's already on the stack, so just return.
    return
++

:CONTINUE_name $8 $"CONTINUE
:CONTINUE
# Compile mode
callri:STATE bz:+
    # Defer `continue` with a tail call optimization.
    imm8:0x13 bra:DEFERO
# Run (or other) mode
+
    # TODO: Add an error message.
    bra:QUIT
++

:COPY:_name $5 $"COPY:
:COPY:
# Compile mode
callri:STATE bz:+
    # Temporarily enter run mode.
    callri:[
    # Defer `copy#`.
    callri:NUMBER imm8:0xE0 add callri:DEFERO
    # Return to compile mode with tail call optimization.
    bra:]
# Run (or other) mode
+
    callri:NUMBER imm8:0xC0 add writepori:+++
    nop +++ pfill:0,1
    return
++

:COUNT_name $5 $"COUNT
:COUNT
dup inc rot1 reads
return

:CR_name $2 $"CR
:CR
imm8:10 intsend
return

:CREATE_name $6 $"CREATE
:CREATE
imm16:$hereb_var reads addi:-4
# Set the word's program address.
imm16:$herep_var reads copy1 write
# Copy the string to hered.
imm8:0x20 callri:WORD copy1 addi:2 write
# Set the word's data space address.
imm16:$hered_var reads copy1 addi:1 write
# Set the word's immediate to 0.
imm8:0 rot1 addi:3 write
return

:DECIMAL_name $7 $"DECIMAL
:DECIMAL
imm8:10 imm16:$base_var write
return

:DEFERO_name $6 $"DEFERO
:DEFERO
# Aquire the address of the program head pointer.
imm16:$herep_var
# Copy the address, read from it, and store the short to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writepo
# Advance the program pointer by 1 and write back the new head.
inc rot1 write
return

:DEFERS_name $6 $"DEFERS
:DEFERS
# Aquire the address of the program head pointer.
imm16:$herep_var
# Copy the address, read from it, and store the short to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writeps
# Advance the program pointer by 2 (the amount of octets in a short) and write back the new head.
addi:2 rot1 write
return

:DEFERW_name $6 $"DEFERW
:DEFERW
# Aquire the address of the program head pointer.
imm16:$herep_var
# Copy the address, read from it, and store the value to program memory, leaving the program pointer on the stack.
copy0 reads rot2 copy1 writep
# Advance the program pointer by 4 (the amount of octets in a processor word) and write back the new head.
addi:4 rot1 write
return

:DIGIT_name $5 $"DIGIT
:DIGIT
dup imm8:10 bles:+
    dup imm8:36 bles:++
        # It is way too big (over base 36).
        # TODO: Add error message for too big.
        bra:QUIT
    ++
    addi:65 intsend
    return
+
    # It was less than 10.
    addi:48 intsend
    return

:DO_name $2 $"DO
:DO
imm8:0xAA callri:DEFERO
imm16:$herep_var reads
imm8:0 bra:DEFERS

:DOES_name $4 $"DOES
:DOES
imm16:$herep_var reads addi:6 imm8:0x95 callri:DEFERO callri:DEFERS
imm8:0x1D callri:DEFERO
imm16:.DOIT imm16:$herep_var reads sub bra:DEFERS

:DOIT
imm16:$hereb_var reads addi:-4 write
return

:DOES>_name $5 $"DOES>
:DOES>
imm16:$herep_var reads addi:6 imm8:0x95 callri:DEFERO callri:DEFERS
imm8:0x1D callri:DEFERO
imm16:.DODOES imm16:$herep_var reads sub bra:DEFERS

:DODOES
# Perfom the functionality of DOIT (which consumes the program address)
callri:DOIT
# Then also add some code to produce the data space pointer of the new word in the new word before starting it.
imm16:$hereb_var reads addi:-3 reads bra:LITERAL

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
+

:ELSE_name $4 $"ELSE
:ELSE
# Defer a branch always.
imm8:0x1D callri:DEFERO
# Get the herep address.
imm16:$herep_var reads
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
push0 imm16:$hereb_var reads set0
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
        # Found a match, so drop the address and return the xt.
        drop read0:3
        # Set the carry bit to 1 if this is an immediate instruction (this is for internal use).
        imm8:-1 read0:0 add drop
        # Restore state.
        pop0 discard return
    ++
    # Move to the next entry.
    move0:4
+

:FORGET_name $6 $"FORGET
:FORGET
# Set dc0 to the back stack.
push0 imm16:$hereb_var reads set0
# Get the end of the word.
imm8:0x20 imm8:64 callri:SCAN
# Get the processing position, read the old address to conveyor, and write the next address to it.
dup inc imm16:$pp_var dup read write
# Duplicate the address, get the old address from the conveyor, and calculate the string length.
dup cv0 sub
# Place the string length in an immediate location in the loop.
writepori:+++
# Iterate through every dictionary entry.
iloop:+
    # Check if we reached the end of the dictionary
    get0 bnz:++
        # Restore state.
        drop pop0 discard
        return
    ++
    # Duplicate this string address for next iteration
    dup
    # Get this string length
    imm8 +++ pfill:0,1
    # Lookup and get expanded string addr count combination from dictionary entry.
    # Offset of 2 on dictionary entry.
    rareadi0:2 callri:COUNT
    # Compare the two strings
    callri:STREQ bz:++
        # Found a match, so drop the address.
        drop
        # Retrieve the program address from the token and set herep.
        rareadi0:0 imm16:$herep_var write
        # Retrieve the string address and set hered to it.
        rareadi0:2 imm16:$hered_var write
        # Get the address, add 4 to it, and set hereb.
        get0 addi:4 imm16:$hereb_var write
        # Restore state.
        pop0 discard return
    ++
    # Move to the next entry.
    move0:4
+

:HERE_name $4 $"HERE
:HERE
imm16:$hered_var reads
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
imm8:16 imm16:$base_var write
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
imm8:0x16 callri:DEFERO
imm16:$herep_var reads
imm8:0 bra:DEFERS

:IF=_name $3 $"IF=
:IF=
# Defer a `bne`
imm8:0x6D callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IF!=_name $4 $"IF!=
:IF!=
# Defer a `beq`
imm8:0x6C callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IF>_name $3 $"IF>
:IF>
# Defer a `bleq`
imm8:0x6F callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IF>=_name $4 $"IF>=
:IF>=
# Defer a `bles`
imm8:0x6E callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IF>U_name $4 $"IF>U
:IF>U
# Defer a `blequ`
imm8:0x71 callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IF>=U_name $5 $"IF>=U
:IF>=U
# Defer a `blesu`
imm8:0x70 callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFC_name $3 $"IFC
:IFC
# Defer a `bnc`
imm8:0x8B callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFC!_name $4 $"IFC!
:IFC!
# Defer a `bc`
imm8:0x8A callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFO_name $3 $"IFO
:IFO
# Defer a `bno`
imm8:0x8D callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFO!_name $4 $"IFO!
:IFO!
# Defer a `bo`
imm8:0x8C callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFI_name $3 $"IFI
:IFI
# Defer a `bni`
imm8:0x8F callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFI!_name $4 $"IFI!
:IFI!
# Defer a `bi`
imm8:0x8E callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFZ_name $3 $"IFZ
:IFZ
# Defer a `bnz`
imm8:0xAC callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

# IF is in the same location as IFZ!.
:IF_name $2 $"IF

:IFZ!_name $4 $"IFZ!
# This is also the tag for IF
:IFZ! :IF
# Defer a `bz`
imm8:0xAB callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFA_name $3 $"IFA
:IFA
# Defer a `bna`
imm8:0xB9 callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IFA!_name $4 $"IFA!
:IFA!
# Defer a `ba`
imm8:0xB8 callri:DEFERO
# Get the address for `ELSE` or `THEN` to replace.
imm16:$herep_var reads
# Defer 16-bits to be replaced by the `ELSE` or `THEN`.
imm8:0 bra:DEFERS

:IMMEDIATE_name $9 $"IMMEDIATE
:IMMEDIATE
imm8:1 imm16:$hereb_var reads addi:3 write
return

:INTERPRET_name $9 $"INTERPRET
:INTERPRET
iloop:+
    imm16:$pp_var reads reads imm8:0x20 bne:++
        discard return
    ++
    imm16:$shell_xt_var reads call
+

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
intrecv cv1
return

:KEY?_name $4 $"KEY?
:KEY?
imm8:0 bna:+
    imm8:1 return
+
    imm8:0 return
++

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
    # TODO: Add an error message.
    bra:QUIT
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
# Replace the offset pointed to by top of stack with (herep - 3 - location).
calli:herep reads addi:-3 copy1 sub rot1 write
return

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
callri:/MOD drop
return

:MOVE_name $4 $"MOVE
:MOVE
push0 push1
set1 set0
loop:+
    read0:1 writepst1:1
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
push0 imm16:$pp_var reads set0
# Check for negative and put a `1` on the stack if there is a negative sign and `0` otherwise.
read0:0 imm8:45 bne:+
    imm8:1
    # Advance DC0 to the first digit after the negative sign.
    move0:1
    bra:++
+
    imm8:0
++
# Add accumulator to stack.
imm8:0
iloop:+
    read0:1 dup imm8:0x20 bne:++
        # Set the new pp after the number.
        get0 imm16:$pp_var write
        # Drop the space character.
        drop
        break
    ++
    dup imm8:48 bles:++
        imm8:57 copy1 bles:+++
            # This is in the range '0' - '9'.
            addi:-48 rot1 imm16:$base_var reads callri:U* add
            continue
        +++
    ++
    dup imm8:65 bles:++
        imm8:90 copy1 bles:+++
            # This is in the range 'A' - 'Z'.
            addi:-65 rot1 imm16:$base_var reads callri:U* add
            continue
        +++
    ++
    dup imm8:97 bles:++
        imm8:122 copy1 bles:+++
            # This is in the range 'a' - 'z'.
            addi:-97 rot1 imm16:$base_var reads callri:U* add
            continue
        +++
    ++
    # TODO: Print an error message.
    bra:QUIT
+
rot1 bz:+
    # Negate number due to negative sign.
    subi:0
+
pop0 return

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
callri:' bnz:+
    # TODO: Add some sort of error message.
    bra:QUIT
+
bra:COMPILE,

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

# Uses the same xt as `QUIT`.
:ABORT_name $5 $"ABORT
:QUIT_name $4 $"QUIT
:QUIT
# Emit a newline before restarting.
imm8:0xA callri:EMIT
imm8:0 dup reset

:RECURSE_name $7 $"RECURSE
:RECURSE
imm16:$hereb_var reads addi:-4 reads bra:COMPILE,

:REVEAL_name $6 $"REVEAL
:REVEAL
imm16:$hereb_var dup reads addi:-4 rot1 write
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
    # Temporarily enter run mode.
    callri:[
    # Defer `rot#`.
    callri:NUMBER imm8:0xC0 add callri:DEFERO
    # Return to compile mode with tail call optimization.
    bra:]
# Run (or other) mode
+
    callri:NUMBER imm8:0xC0 add writepori:+++
    nop +++ pfill:0,1
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
callri:[ imm8:0x20 callri:WORD callri:LITERAL bra:]

:SCAN_name $4 $"SCAN
:SCAN
push0 imm16:$pp_var reads set0
loop:+
    dup read0:1 bne:++
        drop
        # Decrement is here because DC0 goes one beyond the delimiter.
        get0 dec
        pop0 discard
        return
    ++
+
drop pop0 imm8:0
return

:shell_xt_name $8 $"shell_xt
:shell_xt
# Compile mode
callri:STATE bz:+
    # Defer an imm16 instruction.
    imm8:0x95 callri:DEFERO
    # Defer the 16-bit immediate address of the variable and perform a tail call optimization.
    imm16:$shell_xt_var bra:DEFERS
# Run (or other) mode
+
    # Add the variable address to the stack.
    imm16:$shell_xt_var
    return
++

:shell_xt_var $.(run)

:SPACE_name $5 $"SPACE
:SPACE
# Compile mode
callri:STATE bz:+
    # Defer `imm8:0x20 intsend` with a tail call optimization.
    imm16:0x2094 callri:DEFERS imm8:0xA9 bra:DEFERO
# Run (or other) mode
+
    imm8:0x20 intsend
    return
++

:SPACES_name $6 $"SPACES
:SPACES
loop:+
    imm8:0x20 intsend
+
return

:STATE_name $5 $"STATE
:STATE
imm16:$shell_xt_var reads .(compile) bne:+
    imm8:1 return
+
    imm8:0 return
++

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
+
pop1 pop0 imm8:1 return

:THEN_name $4 $"THEN
:THEN
# Get the herep address.
imm16:$herep_var reads
# Compute the branch offset.
copy1 sub addi:1 rot1 write
# Nothing is left on the stack.
return

:TRUE_name $4 $"TRUE
:TRUE
# Compile mode
callri:STATE bz:+
    # Defer `imm8:1` with a tail call optimization.
    imm16:0x0194 bra:DEFERS
# Run (or other) mode
+
    imm8:1
    return
++

:TUCK_name $4 $"TUCK
:TUCK
# Compile mode
callri:STATE bz:+
    # Defer `rot1 copy1` with a tail call optimization.
    imm16:0xE1C1 bra:DEFERS
# Run (or other) mode
+
    rot1 copy1
    return
++

:TYPE_name $4 $"TYPE
:TYPE
push0 rot1 set0
loop:+
    read0:1 intsend
+
pop0
return

:U._name $2 $"U.
:U.
# Get the digit to display and check if we need to call this again.
imm16:$base_var reads callri:/MOD dup bz:+
    # Since the quotient is not 0, call this again to display the more significant digits.
    callri:U.
    # Print this digit with a tail call optimization.
    bra:DIGIT
+
drop bra:DIGIT

:U<_name $2 $"U<
:U<
blesu:+
    imm8:0 return
+
    imm8:1 return
++

:U*_name $2 $"U*
:U*
# Push the accumulator.
imm8:0
WORD_BITS loop:+
    # Shift the product accumulator to the left by 1.
    lsli:1
    copy1 andi:0x80000000 bz:++
        copy2 add
    ++
    # Shift the multiplicand to the left by 1.
    rot1 lsli:1 rot1
+
# Remove both multiplier and multiplicand.
rot2 rot2 ddrop
return

:UNLOOP_name $6 $"UNLOOP
:UNLOOP
# Compile mode
callri:STATE bz:+
    # Defer `discard` with a tail call optimization.
    imm8:0x1E bra:DEFERO
# Run (or other) mode
+
    discard
    return
++

:VARIABLE_name $8 $"VARIABLE
:VARIABLE
# Create the word.
callri:CREATE
# Allot space for the variable.
imm8:1 callri:ALLOT
# TODO: Add a DOVAR to inline the address for efficiency.
# Defer the instructions to produce the address.
imm8:0x96 callri:DEFERO imm16:$hered_var reads callri:DEFERW
# Reveal the word in the dictionary with a tail call optimization.
bra:REVEAL

:WORD_name $4 $"WORD
:WORD
# Word cap at 64 (change this number to alter this)
imm8:64 callri:SCAN dup bnz:+
    # In this case, the delimiter was not found.
    # TODO: Print errors.
    bra:QUIT
+
# Find the length of the string.
imm16:$pp_var reads sub
# Write the length of the string to data space.
dup dup imm16:$hered_var reads write
# Get the string source address again.
imm16:$pp_var reads
# Update the processing position now that we know the length of the string and have the beginning address already.
dup copy2 add inc imm16:$pp_var write
# The string is now in `n addr` format, so copy it to (hered + 1) after the number word.
imm16:$hered_var reads inc callri:MOVE
# Get original hered and also increment hered to the new length, including an increment for the number.
imm16:$hered_var reads dup rot2 add inc
# Write back the incremented hered.
imm16:$hered_var write
# The old hered is left on the stack and is the location the string begins.
return

:WORDS_name $5 $"WORDS
:WORDS
# Set dc0 to the back stack.
push0 imm16:$hereb_var reads set0
# Iterate through every dictionary entry.
iloop:+
    # Check if we reached the end of the dictionary
    get0 bnz:++
        pop0 discard
        return
    ++
    # Read the entry with an offset of 2 to get the name address and display it.
    rareadi0:2 callri:COUNT callri:TYPE
    # Send a space to the terminal.
    imm8:0x20 intsend
+

:XOR_name $3 $"XOR
:XOR
# Compile mode
callri:STATE bz:+
    # Defer `xor` with tail-call optimization.
    imm8:0xA1 bra:DEFERO
# Run (or other) mode
+
    xor
    return
++

:XT>NAME_name $7 $"XT>NAME
:XT>NAME
addi:2 reads
return

:[_name $1 $"[
:[
imm16:.(run) imm16:$shell_xt_var write
return

:]_name $1 $"]
:]
imm16:.(compile) imm16:$shell_xt_var write
return

:dictionary_end

# Program memory aligned to 64k.
palign:0xC0,0x10000
# Main memory aligned to 64kW.
# Data must be aligned such that the backstack consumes the rest of memory.
malign:0,64972

:backstack_head

#####
##### Backstack
#####

:]_xt $.] $$] $$]_name $0
:[_xt $.[ $$[ $$[_name $1
:XT>NAME_xt $.XT>NAME $$XT>NAME $$XT>NAME_name $0
:XOR_xt $.XOR $$XOR $$XOR_name $1
:WORDS_xt $.WORDS $$WORDS $$WORDS_name $0
:WORD_xt $.WORD $$WORD $$WORD_name $0
:VARIABLE_xt $.VARIABLE $$VARIABLE $$VARIABLE_name $0
:UNLOOP_xt $.UNLOOP $$UNLOOP $$UNLOOP_name $1
:U*_xt $.U* $$U* $$U*_name $0
:U<_xt $.U< $$U< $$U<_name $0
:U._xt $.U. $$U. $$U._name $0
:TYPE_xt $.TYPE $$TYPE $$TYPE_name $0
:TUCK_xt $.TUCK $$TUCK $$TUCK_name $1
:TRUE_xt $.TRUE $$TRUE $$TRUE_name $1
:THEN_xt $.THEN $$THEN $$THEN_name $1
:STREQ_xt $.STREQ $$STREQ $$STREQ_name $0
:STATE_xt $.STATE $$STATE $$STATE_name $0
:SPACES_xt $.SPACES $$SPACES $$SPACES_name $0
:SPACE_xt $.SPACE $$SPACE $$SPACE_name $1
:shell_xt_xt $.shell_xt $$shell_xt $$shell_xt_name $1
:SCAN_xt $.SCAN $$SCAN $$SCAN_name $0
:S"_xt $.S" $$S" $$S"_name $1
:RSHIFT_xt $.RSHIFT $$RSHIFT $$RSHIFT_name $1
:ROT:_xt $.ROT: $$ROT: $$ROT:_name $1
:ROT_xt $.ROT $$ROT $$ROT_name $1
:REVEAL_xt $.REVEAL $$REVEAL $$REVEAL_name $0
:RECURSE_xt $.RECURSE $$RECURSE $$RECURSE_name $1
:QUIT_xt $.QUIT $$QUIT $$QUIT_name $0
:ABORT_xt $.QUIT $$QUIT $$ABORT_name $0
:pp_xt $.pp $$pp $$pp_name $1
:POSTPONE_xt $.POSTPONE $$POSTPONE $$POSTPONE_name $0
:pa_xt $.pa $$pa $$pa_name $1
:OVER_xt $.OVER $$OVER $$OVER_name $1
:OR_xt $.OR $$OR $$OR_name $1
:NUMBER_xt $.NUMBER $$NUMBER $$NUMBER_name $0
:NL_xt $.NL $$NL $$NL_name $1
:NIP_xt $.NIP $$NIP $$NIP_name $1
:NEGATE_xt $.NEGATE $$NEGATE $$NEGATE_name $1
:MOVE_xt $.MOVE $$MOVE $$MOVE_name $0
:MOD_xt $.MOD $$MOD $$MOD_name $0
:MIN_xt $.MIN $$MIN $$MIN_name $0
:MAX_xt $.MAX $$MAX $$MAX_name $0
:LSHIFT_xt $.LSHIFT $$LSHIFT $$LSHIFT_name $1
:LOOP_xt $.LOOP $$LOOP $$LOOP_name $1
:LITERAL_xt $.LITERAL $$LITERAL $$LITERAL_name $0
:LEAVE_xt $.LEAVE $$LEAVE $$LEAVE_name $1
:L_xt $.L $$L $$L_name $1
:KEY?_xt $.KEY? $$KEY? $$KEY?_name $0
:KEY_xt $.KEY $$KEY $$KEY_name $0
:K_xt $.K $$K $$K_name $1
:J_xt $.J $$J $$J_name $1
:INTERPRET_xt $.INTERPRET $$INTERPRET $$INTERPRET_name $0
:IMMEDIATE_xt $.IMMEDIATE $$IMMEDIATE $$IMMEDIATE_name $0
:IFA!_xt $.IFA! $$IFA! $$IFA!_name $1
:IFA_xt $.IFA $$IFA $$IFA_name $1
:IFZ!_xt $.IFZ! $$IFZ! $$IFZ!_name $1
:IF_xt $.IFZ! $$IFZ! $$IF_name $1
:IFZ_xt $.IFZ $$IFZ $$IFZ_name $1
:IFI!_xt $.IFI! $$IFI! $$IFI!_name $1
:IFI_xt $.IFI $$IFI $$IFI_name $1
:IFO!_xt $.IFO! $$IFO! $$IFO!_name $1
:IFO_xt $.IFO $$IFO $$IFO_name $1
:IFC!_xt $.IFC! $$IFC! $$IFC!_name $1
:IFC_xt $.IFC $$IFC $$IFC_name $1
:IF>=U_xt $.IF>=U $$IF>=U $$IF>=U_name $1
:IF>U_xt $.IF>U $$IF>U $$IF>U_name $1
:IF>=_xt $.IF>= $$IF>= $$IF>=_name $1
:IF>_xt $.IF> $$IF> $$IF>_name $1
:IF!=_xt $.IF!= $$IF!= $$IF!=_name $1
:IF=_xt $.IF= $$IF= $$IF=_name $1
:IDO_xt $.IDO $$IDO $$IDO_name $1
:I_xt $.I $$I $$I_name $1
:HEX_xt $.HEX $$HEX $$HEX_name $0
:hereb_xt $.hereb $$hereb $$hereb_name $1
:herep_xt $.herep $$herep $$herep_name $1
:hered_xt $.hered $$hered $$hered_name $1
:HERE_xt $.HERE $$HERE $$HERE_name $0
:FORGET_xt $.FORGET $$FORGET $$FORGET_name $0
:FIND_xt $.FIND $$FIND $$FIND_name $0
:FILL_xt $.FILL $$FILL $$FILL_name $0
:FALSE_xt $.FALSE $$FALSE $$FALSE_name $1
:EXIT_xt $.EXIT $$EXIT $$EXIT_name $1
:EXECUTE_xt $.EXECUTE $$EXECUTE $$EXECUTE_name $1
:EMIT_xt $.EMIT $$EMIT $$EMIT_name $1
:ELSE_xt $.ELSE $$ELSE $$ELSE_name $1
:DWORD_xt $.DWORD $$DWORD $$DWORD_name $0
:DUP_xt $.DUP $$DUP $$DUP_name $1
:DROP_xt $.DROP $$DROP $$DROP_name $1
:DOES>_xt $.DOES> $$DOES> $$DOES>_name $1
:DOES_xt $.DOES $$DOES $$DOES_name $1
:DO_xt $.DO $$DO $$DO_name $1
:DIGIT_xt $.DIGIT $$DIGIT $$DIGIT_name $0
:DEFERW_xt $.DEFERW $$DEFERW $$DEFERW_name $0
:DEFERS_xt $.DEFERS $$DEFERS $$DEFERS_name $0
:DEFERO_xt $.DEFERO $$DEFERO $$DEFERO_name $0
:DECIMAL_xt $.DECIMAL $$DECIMAL $$DECIMAL_name $0
:CREATE_xt $.CREATE $$CREATE $$CREATE_name $0
:CR_xt $.CR $$CR $$CR_name $0
:COUNT_xt $.COUNT $$COUNT $$COUNT_name $0
:COPY:_xt $.COPY: $$COPY: $$COPY:_name $1
:CONTINUE_xt $.CONTINUE $$CONTINUE $$CONTINUE_name $1
:CONSTANT_xt $.CONSTANT $$CONSTANT $$CONSTANT_name $0
:COMPILE,_xt $.COMPILE, $$COMPILE, $$COMPILE,_name $0
:BS_xt $.BS $$BS $$BS_name $1
:BODY_xt $.BODY $$BODY $$BODY_name $0
:BL_xt $.BL $$BL $$BL_name $1
:base_xt $.base $$base $$base_name $1
:AND_xt $.AND $$AND $$AND_name $1
:ALLOT_xt $.ALLOT $$ALLOT $$ALLOT_name $0
:ACCEPT_xt $.ACCEPT $$ACCEPT $$ACCEPT_name $0
:ABS_xt $.ABS $$ABS $$ABS_name $0
:ABORT"_xt $.ABORT" $$ABORT" $$ABORT"_name $1
:@_xt $.@ $$@ $$@_name $1
:>=_xt $.>= $$>= $$>=_name $0
:>_xt $.> $$> $$>_name $0
:=_xt $.= $$= $$=_name $0
:<=_xt $.<= $$<= $$<=_name $0
:<_xt $.< $$< $$<_name $0
:;_xt $.; $$; $$;_name $1
::_xt $.: $$: $$:_name $0
:2/_xt $.2/ $$2/ $$2/_name $1
:2*_xt $.2* $$2* $$2*_name $1
:1-_xt $.1- $$1- $$1-_name $1
:1+_xt $.1+ $$1+ $$1+_name $1
:0=_xt $.0= $$0= $$0=_name $0
:0<_xt $.0< $$0< $$0<_name $0
:/MOD_xt $./MOD $$/MOD $$/MOD_name $0
:/_xt $./ $$/ $$/_name $0
:."_xt $.." $$." $$."_name $1
:._xt $.. $$. $$._name $0
:-_xt $.MINUS $$MINUS $$-_name $1
:,_xt $., $$, $$,_name $0
:+!_xt $.+! $$+! $$+!_name $0
:+_xt $.PLUS $$PLUS $$+_name $1
:*/MOD_xt $.*/MOD $$*/MOD $$*/MOD_name $0
:*/_xt $.*/ $$*/ $$*/_name $0
:*_xt $.* $$* $$*_name $0
:(run)_xt $.(run) $$(run) $$(run)_name $0
:(compile)_xt $.(compile) $$(compile) $$(compile)_name $0
:'_xt $.' $$' $$'_name $0
:!_xt $.! $$! $$!_name $1

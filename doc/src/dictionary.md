# Dictionary

Word patterns are enclosed in single quotes (') and are represented using a regex. Non-capitalized words are variables. Constants are still capitalized.

### !
- dstack: `( w addr -- )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Writes `w` to the address `addr`.

### !:
- dstack: `( w -- )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Writes `w` to the variable token specified in the pattern.
- Can be used to set the body address for many words, but not all.

### '
- dstack: `( -- xt )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Places the execution token of the word found on the stack or calls `ABORT"`.

### (compile)
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and compiles it into the current definition.
- Skips the word currently being written when searching for words so the word can reference previous definitions.

### (run)
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and immediately executes it.

### +
- dstack: `( a b -- a+b )`

### +:
- dstack: `( a -- a+b )`
- Attempt to parse a number `b` using `NUMBER` and create an immediate add using it.

### +1
- dstack: `( a -- a+1 )`

### ,
- dstack: `( w -- )`
- Writes a single processor word to the data space of the most recently created word.

### -
- dstack: `( a b -- a-b )`

### -:
- dstack: `( a -- a-b )`
- Attempt to parse a number `b` using `NUMBER` and create an immediate subtract using it.

### -1
- dstack: `( a -- a-1 )`

### .
- dstack: `( w -- )`
- Print a signed number `w` using the base specified in `BASE`.

### .U
- dstack: `( w -- )`
- Print an unsigned number `w` using the base specified in `BASE`.

### :
- pattern: `'^ ([^ ]*)(?: |$)'`
- Updates `hered_start` with the current `hered`.
- Creates a new unfinished word entry in the dictionary with the name matched by the capture group in the pattern.
- Enters compilation mode.
- Resets tail call variables.

### :NONAME
- dstack: `( -- xt )`
- Makes a new anonymous word.
- Places the execution token of this anonymous word on the stack.
- Updates `hered_start` with the current `hered`.
- Creates a new unfinished word entry in the dictionary with the name matched by the capture group in the pattern.
- Enters compilation mode.
- Resets tail call variables.

### ;
- Finish the definition of this word, perform a tail-call optimization if possible, and if not insert an `EXIT`.

### @
- dstack: `( addr -- w )`
- Reads `w` from the address `addr`.

### @:
- dstack: `( -- w )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Reads `w` from the variable token specified in the pattern.
- Can also be used to find the address of the body of many tokens.

### [
- Enter into compilation mode.

### ]
- Enter into run mode.

### ABORT"
- pattern: `'^ ([^ ]*)"'`
- Compiles the specified message into the current word and prints it along with executing `QUIT`.

### ALLOT
- dstack: `( w -- )`
- Allocates, but does not initialize, `w` total processor words to the data space of the most recently created word.

### base
- Contains the base that numbers should be interpreted with using `NUMBER`.

### BREAK
- Breaks out of a loop.

### CALL
- dstack: `( pa -- )`
- Calls the program address `pa` on the stack.

### CALLED
- dstack: `( ins -- )`
- Updates the various tail words to indicate the new tail call instruction to be optimized if `;` is encountered.

### COMPILE,
- dstack: `( xt -- )`
- Adds a call to the execution token `xt` directly into the current word.

### CONTINUE
- Continues a loop on the next iteration from the beginning.

### COPY:
- dstack: `( w .. - w .. w )`
- Aquires the next number using `NUMBER` and compiles an immediate stack copy to the top from a specific depth.

### CREATE
- pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new word entry with the name given by the pattern.
- Resets tail call variables.

### CREATE_RAW
- pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new word entry with the name given by the pattern.
- Does not add `LOADDS` automatically, so this can be used for optimization.
- Resets tail call variables.

### DEFER
- dstack: `( ins -- )`
- Adds an instruction to the word currently being built.

### DOES>
- Compile a combination of code and data to a new word up until a `;`.
- Unlike other FORTHs, this doesn't provide the data space pointer, and simply calls `POSTPONE` on everything until `;`.
  - If the pointer is needed, it should be provided by adding it into the data space of the executing word.

### DROP
- dstack: `( w -- )`

### ELSE
- The alternate case of an `IF` statement.

### EMIT
- dstack: `( c -- )`
- Print the character c on the terminal.
  - This can control the terminal using the backspace and newline characters.

### EXIT
- Returns from the current word.

### FOR
- dstack: `( w -- )`
- Compile-time dstack: `( -- addr )`
  - Pushes the address where the address of the last instruction needs to be added.
- Takes a number of times to iterate and iterates that many times.

### FOREVER
- Compile-time dstack: `( -- addr )`
  - Pushes the address where the address of the last instruction needs to be added.
- Begins a loop which loops forever.

### FORGET
- pattern: `'^ ([^ ]*)(?: |$)'`
- Forgets everything after and including the specified word.

### GETCDS
- dstack: `( -- addr )`
- Get the address of the current data space location.
- This is compiled immediately into the definition and therefore does not affect the address.

### HERED!
- dstack: `( hered -- )`
- Stores the data space post-increment stack pointer.

### HERED@
- dstack: `( -- hered )`
- Reads the data space post-increment stack pointer.

### hered_start
- Contains the beginning of the current definition's hered.
- This is used to track how many things are in the current definition's data space.

### HEREP!
- dstack: `( herep -- )`
- Stores the program memory post-increment stack pointer.

### HEREP@
- dstack: `( -- herep )`
- Reads the program memory post-increment stack pointer.

### HEREB!
- dstack: `( hereb -- )`
- Stores the address of the dictionary head/beginning (the xt of the most recent word).

### HEREB@
- dstack: `( -- hereb )`
- Gets the address of the dictionary head/beginning (the xt of the most recent word).

### I
- dstack: `( -- i )`
- Gets inner loop iterator.

### IF=
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.

### IF!=
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.

### IF<
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.

### IF<=
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.

### IF<U
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Performs an unsigned comparison.

### IF<=U
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Performs an unsigned comparison.

### IFC
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for carry bit status.

### IFC!
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for carry bit status.

### IFO
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for overflow bit status.

### IFO!
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for overflow bit status.

### IFI
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for interrupt bit status, which clears it if it was set.

### IFI!
- dstack: `( a b -- )`
- Goes to `ELSE` or `THEN` if there is none if the condition is not met.
- Checks for interrupt bit status, which clears it if it was set.

### INTERPRET
- Interprets whatever is at the TIB, processing each word using `shell_xt` until all words are consumed.

### J
- dstack: `( -- j )`
- Gets second most inner loop iterator.

### K
- dstack: `( -- k )`
- Gets third most inner loop iterator.

### KEY
- dstack: `( -- c )`
- Retrieves a key from the input device.

### L
- dstack: `( -- l )`
- Gets fourth most inner loop iterator.

### LITERAL
- dstack: `( -- w )`
- Compile-time dstack: `( w -- )`

### LOAD
- dstack: `( -- w )`
- Load an immediate word from the data space.

### LOADDS
- dstack: `( addr -- )`
- Loads the data space address `addr`.
- This is compiled to any word which uses its data space immediately when it is required (many words may not).

### LOOP
- Compile-time dstack: `( addr -- )`
  - Places the address of the instruction before this at the address `addr`.
- Ends a loop definition.

### NUMBER
- dstack: `( -- w )`
- Reads a number from the `PP` with the proper base from `base`.

### POSTPONE
- pattern: `'^ ([^ ]*)(?: |$)'`
- Finds a word and compiles in the ability for the current word to add that word to the definition of another word appropriately when it is ran.
- This is called repeatedly on all words after a `DOES>` up until the `;`, thus it provides the same behavior.

### PP!
- dstack: `( pp -- )`
- Stores the pointer to the location of the input processing position.

### PP@
- dstack: `( -- pp )`
- Provides the pointer to the location of the input processing position.

### QUIT
- This is called at the beginning of the program and when any fault occurs.
- This resets everything in the processor and returns control to the shell.

### REVEAL
- Reveals and finishes the most recent word, also performing tail-call optimization on it.

### ROT:
- dstack: `( w .. - .. w )`
- Aquires the next number using `NUMBER` and compiles an immediate stack rotate to the top from a specific depth.

### SCAN
- dstack: `( c -- addr )`
- Scans from `PP` out until the character `c` is found, then returning the address of c.

### SELF
- dstack: `( .. -- .. )`
- Executes the word currently being compiled, allowing for recursion of itself.
  - This can create a data race if the word performs an immediate write of a variable in its own data space.
    - This can/may be intentional.

### shell_xt
- Contains the xt which is used by `INTERPRET` for determining what to do with words.

### tail_paddr
- Contains the program address off the tail call.
- If this is 0, no replacement happens.

### tail_ins
- Contains the instruction (properly shifted to the correct processor word position) to replace at the tail address.

### THEN
- The end of an `IF` statement.

### TIB@
- dstack: `( -- tib )`
- Adds the address of the terminal input buffer to the stack.

### TYPE
- dstack: `( str -- )`
- Takes a string address from the stack and sends it to the terminal device.

### UNDO
- Removes the most recent word from the dictionary.
- This is used automatically when an issue occurs when attempting to compile a word.

### WORD
- dstack: `( c -- str )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Takes a character delimiter and places a string at hered from the input, then returns the address of the string.

### XT>DATA@
- dstack: `( xt -- addr )`
- Consumes an execution token and produces the data space address of the program.
  - If the word has no data space, this will return 0.

### XT>EXEC
- dstack: `( xt -- .. )`
- Executes an execution token. This is not an efficient method of executing and it is recommended to compile execution directly into any word, which will optimize the call appropriately.
- Sets DC0 to the xt and does a jumpi.
  - If only one value is consumed by the word, it can use it immediately instead of loading a new DC0.

### XT>NAME@
- dstack: `( xt -- str )`
- Consumes an execution token and produces the address to the name of the xt in UFORTH string format.

### XT>PROG@
- dstack: `( xt -- pa )`
- Consumes an execution token and produces a program address which can be called or jumped to.
  - If this token has no program this will return 0.

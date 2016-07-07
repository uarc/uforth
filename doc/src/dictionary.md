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

### '
- dstack: `( -- xt )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Places the execution token of the word found.

### (compile)
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and compiles it into the current definition.

### (run)
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and immediately executes it.

### ,
- dstack: `( w -- )`
- Writes a single processor word to the data space of the most recently created word.

### :
- pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new unfinished word entry in the dictionary with the name matched by the capture group in the pattern.
- Enters compilation mode.

### ;
- Finish the definition of this word, perform a tail-call optimization if possible, and if not insert an `EXIT`.

### @
- dstack: ( addr -- w )
- Reads `w` from the address `addr`.

### @:
- dstack: ( -- w )
- pattern: `'^ ([^ ]*)(?: |$)'`
- Reads `w` from the variable token specified in the pattern.

### [
- Enter into compilation mode.

### ]
- Enter into run mode.

### ALLOT
- dstack: `( w -- )`
- Allocates, but does not initialize, `w` total processor words to the data space of the most recently created word.

### CALL
- dstack: `( pa -- )`
- Calls the program address `pa` on the stack.

### CALLED
- dstack: `( ins -- )`
- Updates the various tail words to indicate the new tail call instruction to be optimized if `;` is encountered.

### DEFER
- dstack: `( ins -- )`
- Adds an instruction to the word currently being built.

### DOES>
- Compile a combination of code and data to a new word up until a `;`.

### EXIT
- Returns from the current word.

### FORGET
- pattern: `'^ ([^ ]*)(?: |$)'`
- Forgets everything after and including the specified word.

### hered
- Contains the data space post-increment stack pointer.

### herep
- Contains the program memory post-increment stack pointer.

### hereb
- Contains the address of the dictionary head/beginning (the xt of the most recent word).

### INTERPRET
- Interprets whatever is at the TIB, processing each word using `shell_xt` until all words are consumed.

### LOADDS
- dstack: `( addr -- )`
- Loads the data space address `addr`.
- This is compiled to any word which uses its data space immediately when it is required (many words may not).

### pp
- Contains the pointer to the location of the next pattern to be interpreted.

### QUIT
- This is called at the beginning of the program and when any fault occurs.
- This resets everything in the processor and returns control to the shell.

### shell_xt
- Contains the xt which is used by `INTERPRET` for determining what to do with words.

### tail_paddr
- Contains the program address off the tail call.

### tail_ins
- Contains the instruction (properly shifted to the correct processor word position) to replace at the tail address.

### UNDO
- Removes the most recent word from the dictionary.
- This is used automatically when an issue occurs when attempting to compile a word.

### XT>DATA
- dstack: `( xt -- addr )`
- Consumes an execution token and produces the data space address of the program.
  - If the word has no data space, this will return 0.

### XT>EXEC
- dstack: `( xt -- .. )`
- Executes an execution token. This is not an efficient method of executing and it is recommended to compile execution directly into any word, which will optimize the call appropriately.

### XT>NAME
- dstack: `( xt -- str )`
- Consumes an execution token and produces the address to the name of the xt in UFORTH string format.

### XT>PROG
- dstack: `( xt -- pa )`
- Consumes an execution token and produces a program address which can be called or jumped to.
  - If this token has no program this will return 0.

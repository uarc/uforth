# Dictionary

Word patterns are enclosed in single quotes (') and are represented using a regex. Non-capitalized words are variables. Constants are still capitalized.

### `!`
- dstack: `( w addr -- )`
- Writes `w` to the address `addr`.

### `'`
- dstack: `( -- xt )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Places the execution token of the word found on the stack.

### `(compile)`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and compiles it into the current definition.
- Skips the word currently being written when searching for words so the word can reference previous definitions.

### `(run)`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Consumes a word and immediately executes it.

### `*`
- dstack: `( a b -- a*b )`

### `*/`
- dstack: `( a b c -- a*b/c )`

### `*/MOD`
- dstack: `( a b c -- a*b%c a*b/c )`

### `+`
- dstack: `( a b -- a+b )`

### `+!`
- dstack: `( a addr -- )`
- Adds `a` to word at address `addr`.

### `,`
- dstack: `( w -- )`
- Writes and allocates a single processor word to the data space of the most recently created word.

### `-`
- dstack: `( a b -- a-b )`

### `.`
- dstack: `( w -- )`
- Print a signed number `w` using the base specified in `BASE`.

### `."`
- Compile:
  - Pattern: `'^ ([^ ]*)"'`
  - Appends the run semantics to the current word.
- Run:
  - Prints out the string pattern.

### `/`
- dstack: `( a b -- a/b )`

### `/MOD`
- dstack: `( a b -- a%b a/b )`

### `0<`
- dstack: `( a -- bool )`
- Puts a `1` on the stack if `a < 0` (signed comparison), `0` otherwise.

### `0=`
- dstack: `( a -- bool )`
- Puts a `1` on the stack if `a == 0`, `0` otherwise.

### `1+`
- dstack: `( a -- a+1 )`

### `1-`
- dstack: `( a -- a-1 )`

### `2*`
- dstack: `( a -- a*2 )`

### `2/`
- dstack: `( a -- a/2 )`

### `:`
- Compile-time pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new unfinished word entry in the dictionary with the name matched by the capture group in the pattern.
- Enters compilation mode.

### `;`
- Finish the definition of this word and insert an `EXIT`.

### `<`
- dstack: `( a b -- bool )`
- Puts a `1` on the stack if `a` is less than `b`, `0` otherwise.

### `=`
- dstack: `( a b -- bool )`
- Puts a `1` on the stack if `a` and `b` are equal, `0` otherwise.

### `>`
- dstack: `( a b -- bool )`
- Puts a `1` on the stack if `a` is greater than `b`, `0` otherwise.

### `>BODY`
- dstack: `( xt -- addr )`
- Places the data-space address of execution token `xt` on the stack.

### `@`
- dstack: `( addr -- w )`
- Reads `w` from the address `addr`.

### `ABORT`
- dstack: `( -- )`
- Has the same functionality as `QUIT` in UFORTH.

### `ABORT"`
- pattern: `'^ ([^ ]*)"'`
- Compiles the specified message into the current word and prints it along with executing `QUIT`.

### `ABS`
- dstack: `( a -- abs(a) )`
- Computes the absolute value of `a`.

### `ACCEPT`
- dstack: `( addr1 n -- addr2 )`
- Writes characters from the input up to `n` characters at address `addr1`, `addr2` is the address following the last character written.

### `ABS`
- dstack: `( w -- u )`
- Finds the absolute value of w.

### `ALLOT`
- dstack: `( w -- )`
- Allocates, but does not initialize, `w` total processor words to the data space of the most recently created word.

### `AND`
- dstack: `( a b -- a&b )`

### `base`
- dstack: `( -- addr )`
- Retrieves the address to the base that numbers should be interpreted with using `NUMBER`.

### `BL`
- dstack: `( -- ' ' )`
- Adds the character for space/blank to the stack.

### `BS`
- dstack: `( -- '\b' )`
- Adds the character for backspace to the stack.

### `COMPILE,`
- dstack: `( xt -- )`
- Adds a call to the execution token `xt` directly into the current word.

### `CONSTATNT`
- Compile:
  - dstack: `( n -- )`
  - pattern: `'^ ([^ ]*)(?: |$)'`
    - The matched pattern becomes the name of the word.
- Run:
  - dstack: `( -- n )`

### `CONTINUE`
- Continues a loop on the next iteration from the beginning.

### `COPY:`
- dstack: `( w .. - w .. w )`
- Aquires the next number using `NUMBER` and compiles an immediate stack copy to the top from a specific depth.

### CREATE
- Compile-time pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new word entry with the name given by the pattern.

### DEFER
- dstack: `( ins -- )`
- Adds an instruction to the word currently being built.

### DO
- Run:
  - dstack: `( n -- )`
  - Begins a loop which will execute `n` times.
- Compile:
  - dstack: `( -- paddr )`
  - Places the program address `paddr` onto the stack to place `pc - paddr - 3` at `LOOP`.

### DOES>
- Compile a combination of code and data to a new word up until a `;`.
- Unlike other FORTHs, this doesn't provide the data space pointer, and simply calls `POSTPONE` on everything until `;`.
  - If the pointer is needed, it should be provided by adding it into the data space of the executing word.

### DROP
- dstack: `( w -- )`

### ELSE
- Compile:
  - dstack: `( paddr1 -- paddr2 )`
  - Writes `pc - paddr1` to `paddr1` and creates a new `paddr2` for the invocation of `THEN` to write to.
- Run:
  - Specifies the location to go to in an `IF` statement if the condition is false.

### EMIT
- dstack: `( c -- )`
- Print the character c on the terminal.
  - This can control the terminal using the backspace and newline characters.

### EXECUTE
- dstack: `( xt -- .. )`
- Executes an execution token.

### EXIT
- Returns from the current word.

### FORGET
- pattern: `'^ ([^ ]*)(?: |$)'`
- Forgets everything defined after and including the specified word.

### hered
- dstack: `( -- addr )`
- Provides the address of the data space post-increment stack pointer.

### herep
- dstack: `( -- addr )`
- Provides the address of the program memory post-increment stack pointer.

### hereb
- dstack: `( -- addr )`
- Provides the address of the dictionary head/beginning (the most recent word that is complete).

### I
- dstack: `( -- i )`
- Gets inner loop iterator.

### IDO
- Run:
  - dstack: `( -- )`
  - Begins an infinite loop which can only be broken out of using `LEAVE`.
- Compile:
  - dstack: `( -- paddr )`
  - Places the program address `paddr` onto the stack to place `pc - paddr - 3` at `LOOP`.

### IF=
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for equal.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IF!=
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for not equal.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IF>
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for greater than.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IF>=
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for greater than or equal to.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IF>U
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for greater than unsigned.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IF>=U
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for greater than or equal to unsigned.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFC
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for carry bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFC!
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for not carry bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFO
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for overflow bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFO!
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for not overflow bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFI
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for interrupt bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFI!
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for not interrupt bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFZ
- Run:
  - dstack: `( a -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for zero.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFZ!
- Run:
  - dstack: `( a -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for not zero.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFA
- Run:
  - dstack: `( b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for available interrupt on bus `b`.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### IFA!
- Run:
  - dstack: `( b -- )`
  - Goes to `ELSE` or `THEN` if there is none if the condition is not met.
  - Checks for no available interrupt on bus `b`.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

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
- Retrieves a key character `c` in ASCII from the input device.

### L
- dstack: `( -- l )`
- Gets fourth most inner loop iterator.

### `LEAVE`
- Compile:
  - dstack: `( -- )`
- Run:
  - Breaks out of a loop.

### LITERAL
- dstack: `( -- w )`
- Compile-time dstack: `( w -- )`

### LOOP
- Compile:
  - dstack: `( addr -- )`
  - Consumes the loop address and terminates the loop definition.
- Run:
  - Repeats the condition of the loop and checks it again.

### NL
- dstack: `( -- '\n' )`
- Adds the character for newline to the stack.

### NUMBER
- dstack: `( -- w )`
- Reads a number from the `pp` with the base from `base` or aborts on failure.

### POSTPONE
- Compile-time pattern: `'^ ([^ ]*)(?: |$)'`
- Append the compilation semantics of the word to the current word's defintion.

### pa
- dstack: `( -- addr )`
- Places the address `addr` of the input processing address (which is also an address) on the stack.
  - This address points to the beginning of where the input buffer begins.

### pp
- dstack: `( -- addr )`
- Places the address `addr` of the input processing position (which is also an address) on the stack.

### QUIT
- This is called at the beginning of the program and when any fault occurs.
- This soft-resets everything in the processor and returns control to the shell.

### REVEAL
- Reveals and finishes the most recent word, moving hereb to its location.

### ROT
- dstack: `( a b c - b c a )`

### ROT:
- dstack: `( w .. - .. w )`
- Aquires the next number using `NUMBER` and compiles an immediate stack rotate to the top from a specific depth.

### S"
- dstack: `( -- addr )`
- Compile-time pattern: `'^ ([^ ]*)"'`
- Puts the address of the string specified at compile-time onto the stack.

### SCAN
- dstack: `( c n -- addr )`
- Scans from `PP` out until the character `c` is found, checking up to `n` characters, then returning the address of c.

### shell_xt
- Contains the xt which is used by `INTERPRET` for determining what to do with words.
  - This can be `(compile)` or `(run)`.
    - If it is not either of these, words executed which have different run-time and compile-time operation will choose the run-time option instead.
      - This is a convention that new words that have such behavior should also follow, though it is not necessary for the system to operate correctly.

### STATE
- dstack: `( -- bool )`
- Places a `1` on the stack if the system is in `(compile)` mode, `0` otherwise.

### THEN
- Compile:
  - dstack: `( paddr -- )`
- Run:
  - Signifies the location which an if statement ends at.

### TYPE
- dstack: `( addr n -- )`
- Types `n` characters from `addr` to the terminal.
  - Control characters may interface with the terminal.

### U.
- dstack: `( w -- )`
- Print an unsigned number `w` using the base specified in `BASE`.

### WORD
- dstack: `( c -- str )`
- Compile-time pattern: `'^ ([^ ]*)(?: |$)'`
- Takes a character delimiter and places a string in the data space at hered, then returns the address of the string.

### XT>NAME
- dstack: `( xt -- str )`
- Consumes an execution token and produces the address to the name of the xt in UFORTH string format.

### [
- Enter into run mode.

### ]
- Enter into compilation mode.

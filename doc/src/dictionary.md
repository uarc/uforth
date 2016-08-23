# Dictionary

Word patterns are enclosed in single quotes (') and are represented using a regex. Non-capitalized words are variables. Constants are still capitalized.

### `!`
- dstack: `( w addr -- )`
- Writes `w` to the address `addr`.

### `'`
- dstack: `( -- xt )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Places the execution token of the word found on the stack, if not found returns `0`.
  - An execution token will never be `0`.
- Also sets the carry bit to `1` if the instruction is immediate.

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

### `BODY`
- dstack: `( -- addr )`
- Retrieves the address of the data space of the most recent word.

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

### `COUNT`
- dstack: `( addr1 - addr2 n )`
- Retrieves the character count from the string in memory at `addr1`, placing the character pointer `addr2` and the number of characters `n` on the stack.

### `CR`
- dstack: `( -- )`
- Sends a newline to the terminal.

### `CREATE`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Creates a new word entry with the name given by the pattern.
- The only thing this changes internally is that the dictionary entry values are set.

### `DECIMAL`
- dstack: `( -- )`
- Sets `base` to `10`.

### `DEFERO`
- dstack: `( o -- )`
- Adds an octet `o` to the word currently being built.

### `DEFERS`
- dstack: `( s -- )`
- Adds a short (two octets) `s` to the word currently being built.

### `DEFERW`
- dstack: `( w -- )`
- Adds a processor word `w` to the word currently being built.

### `DO`
- Compile:
  - dstack: `( -- paddr )`
  - Places the program address `paddr` onto the stack to place `pc - paddr - 3` at `LOOP`.
- Run:
  - dstack: `( n -- )`
  - Begins a loop which will execute `n` times.

### `DOES`
- Compile:
  - Ends compilation of this word, but begins compilation of a program to override the most recent word with.
- Run:
  - Sets the word currently being built to have the program specified after `DOES`.
- Execution:
  - dstack: `( -- )`

### `DOES>`
- Compile:
  - Same functionality as `DOES`.
- Run:
  - Same functionality as `DOES`.
- Execution:
  - dstack: `( -- addr )`
  - Same as `DOES`, but also places the data space address `addr` of the word on the stack.

### `DROP`
- dstack: `( w -- )`

### `DUP`
- dstack: `( w -- w w )`

### `DWORD`
- dstack: `( addr c - n )`
- Counts the amount of characters until the delimiter `c` is found at `addr` and adds it to the stack.

### `ELSE`
- Compile:
  - dstack: `( paddr1 -- paddr2 )`
  - Writes `pc - paddr1` to `paddr1` and creates a new `paddr2` for the invocation of `THEN` to write to.
- Run:
  - Specifies the location to go to in an `IF` statement if the condition is false.

### `EMIT`
- dstack: `( c -- )`
- Print the character c on the terminal.
  - This can control the terminal using the backspace and newline characters.

### `EXECUTE`
- dstack: `( .. xt -- .. )`
- Executes an execution token.

### `EXIT`
- Returns from the current word.

### `FALSE`
- dstack: `( -- false )`
- Places a `0` on the stack.

### `FILL`
- dstack: `( u w addr -- )`
- Fill the location at address `addr` with `u` number of the processor word `w`.

### `FIND`
- dstack: `( addr n -- xt )`
- Find the WORD with the string at `addr` with length `n` and place its execution token, or `0` if not found, on the stack.
  - An execution token will never be `0`.
- Also sets the carry bit to `1` if the instruction is immediate.

### `FORGET`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Forgets everything defined after and including the specified word.

### `HERE`
- dstack: `( -- addr )`
- Places the data space pointer `addr` on the stack.

### `hered`
- dstack: `( -- addr )`
- Provides the address of the data space post-increment stack pointer.

### `herep`
- dstack: `( -- addr )`
- Provides the address of the program memory post-increment stack pointer.

### `hereb`
- dstack: `( -- addr )`
- Provides the address of the dictionary head/beginning pointer (the most recent word that is complete).

### `HEX`
- dstack: `( -- )`
- Sets `base` to `16`.

### `I`
- dstack: `( -- i )`
- Gets inner loop iterator.

### `IDO`
- Run:
  - dstack: `( -- )`
  - Begins an infinite loop which can only be broken out of using `LEAVE`.
- Compile:
  - dstack: `( -- paddr )`
  - Places the program address `paddr` onto the stack to place `pc - paddr - 3` at `LOOP`.

### `IF`
- Same as `IFZ!`.

### `IF=`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for equal.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IF!=`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for not equal.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IF>`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for greater than.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IF>=`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for greater than or equal to.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IF>U`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for greater than unsigned.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IF>=U`
- Run:
  - dstack: `( a b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for greater than or equal to unsigned.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFC`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for carry bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFC!`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for not carry bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFO`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for overflow bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFO!`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for not overflow bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFI`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for interrupt bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFI!`
- Run:
  - dstack: `( -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for not interrupt bit set.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFZ`
- Run:
  - dstack: `( a -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for zero.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFZ!`
- Run:
  - dstack: `( a -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for not zero.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFA`
- Run:
  - dstack: `( b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for available interrupt on bus `b`.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IFA!`
- Run:
  - dstack: `( b -- )`
  - Goes to `ELSE` or `THEN` if the condition is not met.
  - Checks for no available interrupt on bus `b`.
- Compile:
  - dstack: `( -- paddr )`
  - Adds the program address to write the relative address `pc - paddr` to for jumping to the else.

### `IMMEDIATE`
- Makes the most recent word an immediate word, meaning that it is executed even in compile mode.

### `INTERPRET`
- Interprets whatever is at the TIB, processing each word using `shell_xt` until all words are consumed.

### `J`
- dstack: `( -- j )`
- Gets second most inner loop iterator.

### `K`
- dstack: `( -- k )`
- Gets third most inner loop iterator.

### `KEY`
- dstack: `( -- c )`
- Retrieves a key character `c` in ASCII from the input device.

### `KEY?`
- dstack: `( -- bool )`
- If a key is ready to be received by `KEY`, returns `1`, otherwise `0`.

### `L`
- dstack: `( -- l )`
- Gets fourth most inner loop iterator.

### `LEAVE`
- Compile:
  - dstack: `( -- )`
- Run:
  - Breaks out of a loop.

### `LITERAL`
- dstack: `( -- w )`
- Compile-time dstack: `( w -- )`

### `LOOP`
- Compile:
  - dstack: `( addr -- )`
  - Consumes the loop address and terminates the loop definition.
- Run:
  - Repeats the condition of the loop and checks it again.

### `LSHIFT`
- dstack: `( a s -- a<<s )`

### `MAX`
- dstack: `( a b -- c )`
- `c` is the max of `a` or `b`.

### `MIN`
- dstack: `( a b -- c )`
- `c` is the min of `a` or `b`.

### `MOD`
- dstack: `( a b -- a%b )`

### `MOVE`
- dstack: `( n addr1 addr2 -- )`
- Moves `n` processor words from `addr1` to `addr2`.

### `NEGATE`
- dstack: `( a -- -a )`

### `NIP`
- dstack: `( a b -- b )`

### `NL`
- dstack: `( -- '\n' )`
- Adds the character for newline to the stack.

### `NUMBER`
- dstack: `( -- w )`
- Reads a number from the `pp` with the base from `base` or aborts on failure.

### `OR`
- dstack: `( a b -- a|b )`

### `OVER`
- dstack: `( a b -- a b a )`

### `pa`
- dstack: `( -- addr )`
- Places the address `addr` of the input processing address (which is also an address) on the stack.
  - This address points to the beginning of where the input buffer begins.

### `POSTPONE`
- Compile-time pattern: `'^ ([^ ]*)(?: |$)'`
- Append the compilation semantics of the word to the current word's defintion.

### `pp`
- dstack: `( -- addr )`
- Places the address `addr` of the input processing position (which is also an address) on the stack.

### `QUIT`
- This is called at the beginning of the program and when any fault occurs.
- This soft-resets everything in the processor and returns control to the shell.

### `RECURSE`
- Recursively calls the word currently being built. Must follow a `:` or `CREATE`.

### `REVEAL`
- Reveals and finishes the most recent word, moving `hereb` to its location.

### `ROT`
- dstack: `( a b c - b c a )`

### `ROT:`
- dstack: `( w .. - .. w )`
- Aquires the next number using `NUMBER` and compiles an immediate stack rotate to the top from a specific depth.

### `RSHIFT`
- dstack: `( a b - a>>b )`

### `S"`
- Compile:
  - pattern: `'^ ([^ ]*)"'`
- Run:
  - dstack: `( -- addr n )`
  - Puts the address `addr` and the number of characters `n` of the string specified at compile-time onto the stack.

### `SCAN`
- dstack: `( c n -- addr )`
- Scans from `pp` out until the character `c` is found, checking up to `n` characters, then returning the address of c.

### `shell_xt`
- Contains the xt which is used by `INTERPRET` for determining what to do with words.
  - This can be `(compile)` or `(run)`.
    - If it is not either of these, words executed which have different run-time and compile-time operation will choose the run-time option instead.
      - This is a convention that new words that have such behavior should also follow, though it is not necessary for the system to operate correctly.

### `SPACE`
- dstack: `( -- )`
- Displays a space character.

### `SPACES`
- dstack: `( n -- )`
- Displays `n` space characters.

### `STATE`
- dstack: `( -- bool )`
- Places a `1` on the stack if the system is in `(compile)` mode, `0` otherwise.

### `STREQ`
- dstack: `( addr1 n1 addr2 n2 -- bool )`
- Checks if `n1 == n2` and returns `0` if they arent equal, otherwise returns `1` if the strings are equal, `0` otherwise.
- Note: The most efficient way to implement this is with dstack: `( n1 addr1 addr2 n2 -- bool )`
  - This would only save one instruction and, since this is a FORTH kernel, readability is more important.

### `THEN`
- Compile:
  - dstack: `( paddr -- )`
- Run:
  - Signifies the location which an if statement ends at.

### `TRUE`
- dstack: `( -- true )`
- Places a `1` on the stack.

### `TUCK`
- dstack: `( a b -- b a b )`

### `TYPE`
- dstack: `( addr n -- )`
- Types `n` characters from `addr` to the terminal.
  - Control characters may interface with the terminal.

### `U.`
- dstack: `( w -- )`
- Print an unsigned number `w` using the base specified in `BASE`.

### `U<`
- dstack: `( a b -- bool )`
- If the unsigned compaison of `a < b` is true, add a `1` to the stack, `0` otherwise.

### `U*`
- dstack: `( a b -- a*b )`
- Unsigned multiplication of `a` and `b`.

### `UNLOOP`
- dstack: `( -- )`
- Discards the innermost loop parameters to return, jump, or branch out of the loop.

### `VARIABLE`
- Run:
  - dstack: `( -- )`
  - pattern: `'^ ([^ ]*)(?: |$)'`
  - Creates a new word with the pattern.
- Execution:
  - dstack: `( -- addr )`
  - Places the unique address `addr` of the variable on the stack.

### `WORD`
- dstack: `( c -- str )`
- pattern: `'^ ([^ ]*)(?: |$)'`
- Takes a character delimiter and places a string from `pp` in the data space at hered, then returns it.

### `WORDS`
- dstack: `( -- )`
- Prints all available words in the dictionary.

### `XOR`
- dstack: `( a b -- a^b )`

### `XT>NAME`
- dstack: `( xt -- addr n )`
- Consumes an execution token and produces the address to the name of the xt.

### `[`
- Enter into run mode.

### `]`
- Enter into compilation mode.

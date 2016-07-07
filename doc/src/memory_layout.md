# Memory Layout

In UFORTH there are three important memory locations in the memory layout: the dictionary stack, the data space stack, and the program memory.

### Dictionary Stack
At the end of memory, the dictionary stack descends towards lower addresses. The dictionary stack contains a fixed header for every single FORTH word in the dictionary. Any static information of any word is contained in the header. This header contains a pointer to the address of the program, the address of the name string, etc. The data space address for the word is 0 if it does not need one. The execution token for any given word points to the location in which the program address is stored, which is also the beginning of the word header.

##### Word Header Layout

|Bits|Use|
|----|---|
|WORD|Program memory address|
|WORD|Data space address|
|WORD|Name string address|
|1|Immediate word flag (bit 0)|

### Data Space Stack
When a word is compiled, it gets a data space area. If this area is ever increased in size/allocated to the word, it will cause the data space address to be set, otherwise it will remain 0 to indicate it was not used.

### Program Memory
u0-x is a harvard architecture and therefore has its own program memory. As you compile a word, each instruction added to the word is placed into the program memory. The word header points to the beginning of the word definition and it is called or jumped to. Almost every word will return at its end, but that doesn't mean the word has to be called. The last non-immediate word in any given compiled word can be converted into a jump as a tail-call optimization. Words which are not immediate, but do perform calls, will need to explicitly handle this condition by calling the word `CALLED` right before writing the call to memory. This word is used by the OS to store the position and previous value of the word containing the instruction which is to potentially be replaced by a jump, and it requires the precise instruction to pass to it to perform the tail-call optimization. To see the full spec for `CALLED`, read its [dictionary entry](dictionary.html#CALLED).

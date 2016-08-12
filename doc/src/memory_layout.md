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
When a word is compiled, it gets a data space area. This area can be completely empty, but it will always be set.

### Program Memory
u0-x is a harvard architecture and therefore has its own program memory. As you compile a word, each instruction added to the word is placed into the program memory. Words which are executed are called using the calli instruction, which takes one cycle.

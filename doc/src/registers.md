# Registers

u0 has 4 data counter (DC) registers with useful addressing modes. The calling convention is that callees must preserve the DCs, because all parameters are passed on the primary stack for convenience and information about DCs is hidden.

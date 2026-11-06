/* Both GraphX framebuffers occupy 0xD40000..0xD657FF. A large resident
 * program must fail at link time, before drawing can overwrite its code. */
ASSERT(___data_high <= 0xD40000, "Pedro resident program overlaps LCD framebuffers; use a smaller build")

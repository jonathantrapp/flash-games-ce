/* Both GraphX framebuffers occupy 0xD40000..0xD657FF. Reject an oversized
 * resident program before drawing can overwrite its code or data. */
ASSERT(___data_high <= 0xD40000, "Scouts resident program overlaps LCD framebuffers; use a smaller build")

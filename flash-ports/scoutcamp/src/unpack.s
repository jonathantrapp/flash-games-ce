; Lossless PackBits expansion from RAM to LCD RAM. C ABI: dst, src, src_end.
; Commands 0..127 copy n+1 literals; 128..255 repeat one byte n-127 times.
.section .text._scout_unpack,"ax",@progbits
.assume ADL = 1
.globl _scout_unpack
.type _scout_unpack,@function
_scout_unpack:
    push ix
    ld ix,0
    add ix,sp
    push iy
    ld de,(ix+6)
    ld hl,(ix+9)
    ld iy,(ix+12)
.Lunpack_next:
    push hl
    lea bc,iy+0
    or a,a
    sbc hl,bc
    pop hl
    jr nc,.Lunpack_done
    ld a,(hl)
    inc hl
    bit 7,a
    jr z,.Lunpack_literal
    and a,127
    ld bc,0
    ld c,a
    inc bc
    ld a,(hl)
    inc hl
    ld (de),a
    inc de
    dec bc
    ld a,b
    or a,c
    jr z,.Lunpack_next
    push hl
    push de
    pop hl
    dec hl
    ldir
    pop hl
    jr .Lunpack_next
.Lunpack_literal:
    ld bc,0
    ld c,a
    inc bc
    ldir
    jr .Lunpack_next
.Lunpack_done:
    pop iy
    pop ix
    ret
.size _scout_unpack,.-_scout_unpack

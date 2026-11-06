; Exact resident sky rectangle. C ABI: left, top, right, bottom (exclusive).
; Caller checks bounds and calls gfx_Wait before direct framebuffer writes.
.section .text._pedro_sky_region,"ax",@progbits
.assume ADL = 1
.globl _pedro_sky_region
.type _pedro_sky_region,@function
_pedro_sky_region:
    push ix
    ld ix,0
    add ix,sp
    push iy
    ld hl,(ix+12)
    ld de,(ix+6)
    or a,a
    sbc hl,de
    push hl                     ; ix-6: width
    ex de,hl
    ld hl,320
    or a,a
    sbc hl,de
    push hl                     ; ix-9: destination stride
    ld hl,(ix+15)
    ld de,(ix+9)
    or a,a
    sbc hl,de
    push hl                     ; ix-12: rows remaining
    ld bc,0
    or a,a
    sbc hl,bc
    jr z,.Lsky_done
    ld hl,(ix+9)
    add hl,hl
    add hl,hl
    ld bc,_sky_rows
    add hl,bc
    push hl
    pop iy
    ld a,(ix+9)
    ld bc,0
    ld b,a
    ld c,64
    mlt bc
    ld hl,0
    ld h,a
    add hl,bc                   ; top * 320
    ld bc,(ix+6)
    add hl,bc
    ld bc,(0xE30014)            ; GraphX draw-buffer pointer
    add hl,bc
    ex de,hl
.Lsky_row:
    ld hl,(iy+0)
    ld bc,0
    or a,a
    sbc hl,bc
    jr z,.Lsky_uniform
    ld bc,(ix+6)
    add hl,bc
    ld bc,(ix-6)
    ldir
    jr .Lsky_next
.Lsky_uniform:
    ld a,(iy+3)
    ld (de),a
    inc de
    ld bc,(ix-6)
    dec bc
    ld a,b
    or a,c
    jr z,.Lsky_next
    push de
    pop hl
    dec hl
    ldir
.Lsky_next:
    ld hl,(ix-9)
    add hl,de
    ex de,hl
    ld bc,4
    add iy,bc
    ld hl,(ix-12)
    dec hl
    ld (ix-12),hl
    ld bc,0
    or a,a
    sbc hl,bc
    jr nz,.Lsky_row
.Lsky_done:
    ld iy,(ix-3)
    ld sp,ix
    pop ix
    ret
.size _pedro_sky_region,.-_pedro_sky_region

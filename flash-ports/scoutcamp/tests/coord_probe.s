	.section	.text,"ax",@progbits
	assume	adl = 1
	public	_ex1                            ; -- Begin function ex1
_ex1:                                   ; @ex1
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	iy, (hl)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	ex	de, hl
	add	iy, de
	ld	c, 8
	lea	hl, iy + 0
	call	__ishrs
	pop	ix
	ret
                                        ; -- End function
	public	_ex2                            ; -- Begin function ex2
_ex2:                                   ; @ex2
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	hl, (hl)
	ld	c, 8
	call	__ishrs
	pop	ix
	ret
                                        ; -- End function
	public	_ex3                            ; -- Begin function ex3
_ex3:                                   ; @ex3
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	de, (iy + 1)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	pop	ix
	ret
                                        ; -- End function
	public	_ex4                            ; -- Begin function ex4
_ex4:                                   ; @ex4
; %bb.0:
	ld	hl, -5
	call	__frameset
	ld	hl, (ix + 6)
	ld	hl, (hl)
	ld	(ix - 5), hl
	ld	de, (ix - 3)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	sp, ix
	pop	ix
	ret
                                        ; -- End function
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	extern	__Unwind_SjLj_Unregister
	extern	_llvm.stackrestore.p0
	extern	__ishrs
	extern	_llvm.eh.sjlj.functioncontext
	extern	_llvm.eh.sjlj.setup.dispatch
	extern	_llvm.eh.sjlj.callsite
	extern	__frameset
	extern	_llvm.stacksave.p0
	extern	_llvm.lifetime.end.p0
	extern	_llvm.lifetime.start.p0
	extern	__ishru
	extern	__frameset0
	extern	__Unwind_SjLj_Register
	extern	_llvm.frameaddress.p0
	extern	_llvm.eh.sjlj.lsda

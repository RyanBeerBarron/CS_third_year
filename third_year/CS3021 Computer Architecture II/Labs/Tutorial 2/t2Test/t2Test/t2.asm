includelib legacy_stdio_definitions.lib
extrn printf:near
option casemap:none             ; case sensitive

.data
public g
g	QWORD	4
fq	db	"a = %ld b = %ld c = %ld d = %ld e = %ld sum = %ld", 10, 0
fqns	db "qns", 10, 0


.code
public min 

min:	mov		rax, rcx		; v = a
		cmp		rax, rdx		; if ( v < b)
		jl		min0			; 
		mov		rax, rdx		;	v = b
min0:	cmp		rax, r8			; if ( v < c)
		jl		min1			;
		mov		rax, r8			;	v = c
min1:	ret		0				; return v


public p

p:		sub		rsp, 32			; shadow space for min
		mov		r10, rcx		; tmp0 = i
		mov		r11, rdx		; tmp1 = j
		mov		rcx, [g]		; a = g
		mov		rdx, r10		; b = tmp0
		mov		r10, r8			; tmp0 = k
		mov		r8, r11			; c = tmp1
		call	min				;
		mov		rcx, rax
		mov		rdx, r10
		mov		r8, r9
		call	min
		add		rsp, 32
		ret		0


public gcd

gcd:	sub		rsp, 32
		mov		rax, rcx
		cmp		rdx, 0
		jne		gcd0
		add		rsp, 32
		ret		0
gcd0:	mov		rcx, rdx
		cqo
		idiv	rcx
		call	gcd
		add		rsp, 32
		ret		0


public q

q:		mov		rax, [rsp+40]
		sub		rsp, 56
		xor		r10, r10
		add		r10, rcx
		add		r10, rdx
		add		r10, r8
		add		r10, r9
		add		r10, rax
		mov		[rsp+48], r10
		mov		[rsp+40], rax
		mov		[rsp+32], r9
		mov		r10, rcx
		mov		r11, rdx
		mov		rax, r8
		lea		rcx, fq
		mov		rdx, r10
		mov		r8, r11
		mov		r9, rax
		call	printf
		mov		rax, [rsp+48]
		add		rsp, 56
		ret		0

public qns

qns:	sub		rsp, 32
		lea		rcx, fqns
		call	printf
		add		rsp, 32
		mov		rax, 0
		ret		0

end
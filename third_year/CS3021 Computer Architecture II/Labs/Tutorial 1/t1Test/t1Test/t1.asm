.686                                ; create 32 bit code
.model flat, C                      ; 32 bit memory model
 option casemap:none                ; case sensitive


.data
public    g
g    DWORD    4


.code
public	 min

min:	push	ebp				; save old frame pointer
		mov		ebp, esp		; set frame pointer to current stack pointer, which is where the old frame pointer is
		sub		esp, 4			; allocate memory for one 32bit variable (v)
		mov		eax, [ebp+8]	; load first parameter in eax (a)
		mov		ecx, [ebp+12]	; load second parameter in ecx (b)
		mov		edx, [ebp+16]	; load third parameter in edx (c)
		mov		[ebp-4], eax	; int v = a 
		cmp		[ebp-4], ecx	; if (b < v)
		jl		min0			;	
		mov		[ebp-4], ecx	;	v = b
min0:	cmp		[ebp-4], edx	; if (c < v)
		jl		min1			;
		mov		[ebp-4], edx	;	v = c
min1:	mov		eax, [ebp-4]	; a = v, pass result in eax
		mov		esp, ebp		; deallocate memory, restore stack pointer
		pop		ebp				; restore old frame pointer
		ret		0				; return from function, result in eax
      


public p

p:		push	ebp
		mov		ebp, esp
		sub		esp, 4
		mov		eax, [g]
		mov		ecx, [ebp+8]
		mov		edx, [ebp+12]
		push	edx
		push	ecx
		push	eax
		call	min
		add		esp, 12
		mov		ecx, [ebp+16]
		mov		edx, [ebp+20]
		push	edx
		push	ecx
		push	eax
		call	min
		add		esp, 12
		mov		esp, ebp
		pop		ebp
		ret		0

public gcd

gcd:	push	ebp
		mov		ebp, esp
		mov		ecx, [ebp+12]
		mov		eax, [ebp+8]
		cmp		ecx, 0
		jne		gcd0
		mov		esp, ebp
		pop		ebp
		ret		0
gcd0:	cdq
		idiv	ecx
		push	edx
		push	ecx
		call	gcd
		add		esp, 8
		mov		esp, ebp
		pop		ebp
		ret		0
	

end

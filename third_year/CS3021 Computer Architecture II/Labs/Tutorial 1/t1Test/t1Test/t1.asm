686                                ; create 32 bit code
.model flat, C                      ; 32 bit memory model
 option casemap:none                ; case sensitive

.code


public	 min

min:	push	ebp				;
		mov		ebp, esp		;
		mov		eax, [ebp+8]	; load first parameter in eax
		mov		ebx, [ebp+12]	; load second parameter in ebx
		mov		ecx, [ebp+16]	;
		cmp		eax, ebx		;
		jl		min0			;
		cmp		ebx, ecx		;
		jl		min1			;


min0	cmp		eax, ecx
		jl		min2






min2	
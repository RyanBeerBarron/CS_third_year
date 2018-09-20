686                                ; create 32 bit code
.model flat, C                      ; 32 bit memory model
 option casemap:none                ; case sensitive
.data
public    g
g    DWORD    4


.code
public	 min

min:	push	ebp				;
		mov		ebp, esp		;
    sub esp, 4        ;
		mov		eax, [ebp+8]	; load first parameter in eax
		mov		ecx, [ebp+12]	; load second parameter in ecx
		mov		edx, [ebp+16]	; load third parameter in edx
    mov   [ebp-4], eax    ;
    cmp		[ebp-4], ecx		;
		jl		min0			;
       mov   [ebp-4], ecx  ;
min0   cmp		[ebp-4], edx	;
		   jl		min1			;
       mov [ebp-4], edx    ;
min1   mov eax, [ebp-4]
       mov esp, ebp
       pop ebp
       ret 0
       






min2

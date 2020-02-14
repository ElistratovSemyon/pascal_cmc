.NOLIST
.NOLISTMACRO
.386
.model flat,stdcall
.data
spec dw ?
spec2 dw ?
.code
; 
; procedure Double_Point_Crossover(var new_1, new_2:word;
;                                 first_indiv, second_indiv:word;
;                                 left, right:word);
; +8 right
; +12 left
; +16 second_indiv
; +20 first_indiv
; +24 new_2
; +28 new_1


                                
                                 
public DOUBLE_POINT_CROSSOVER 
DOUBLE_POINT_CROSSOVER proc   

                push ebp
                mov ebp, esp
                push eax
                push ebx
                push edx
                push ecx
                push esi
                push edi
               
                xor dx, dx
				
				mov bl, byte ptr [ebp+12]
				mov bh, byte ptr [ebp+8]
@@:				cmp bl, bh
				mov ax, word ptr 1
				mov cl, bh
				sub cl, bl
				shl ax, cl
				or dx, ax
				inc bl
				jbe @B
				
				mov ax, [ebp+20]
				mov bx, [ebp+16]
				
				mov si, ax
                and si, dx
                mov di, bx
                and di, dx
                not dx
                and ax, dx
                and bx, dx
                or ax, di
                or bx, si
                
                mov ecx, [ebp+24]
                mov edx, [ebp+20]
                mov [ecx], ax
                mov [edx], bx
				
                push edi              
                pop esi
                pop ecx
                pop edx
                pop ebx
                pop eax
                pop ebp
                ret 24;??
DOUBLE_POINT_CROSSOVER endp 
end.
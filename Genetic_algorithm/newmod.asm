
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
;                                 left_point, right_point:byte);
;
;
; +8 r
; +12 l
; +16 second_indiv
; +20 first_indiv
; +24 new_2
; +28 new_1
;

                               
                                 
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
                ; do mask
                mov dx, byte ptr 1
                mov cl, 16
                mov ch, byte ptr [ebp+12]
                sub cl, ch
                inc cl
                shl dx, cl
                mov bx, byte ptr 1
                mov cl, 16
                mov ch, byte ptr [ebp+8]
                sub cl, ch
                
                shl bx, cl
                sub dx, bx
                
                mov ax, [ebp+20]
                mov bx, [ebp+16]
		; and mask with first and with second then change (use not mask)		
		mov si, ax
                and si, dx
                mov di, bx
                and di, dx
                not dx
                and ax, dx
                and bx, dx
                or ax, di
                or bx, si
                
                mov ecx, [ebp+28]
                mov edx, [ebp+24]
                mov [ecx], ax
                mov [edx], bx
                
En:             
                
                
                pop edi
                pop esi
                pop ecx
                pop edx
                pop ebx
                pop eax
                pop ebp
                ret 24;??
DOUBLE_POINT_CROSSOVER endp 

;procedure Single_Point_Crossover(var new_1, new_2:word;
;                                 first_indiv, second_indiv:word;
;                                 point:byte);
;
;
; +8 point
; +12 second_indiv
; +16 first_indiv
; +20 new_2
; +24 new_1
;
public SINGLE_POINT_CROSSOVER 
SINGLE_POINT_CROSSOVER proc   

                             push ebp
                mov ebp, esp
                push eax
                push ebx
                push edx
                push ecx
                push esi
                push edi
                
                ; do mask
                mov dx, byte ptr 1
                mov cl, 16
                mov ch, byte ptr [ebp+8]
                sub cl, ch
                inc cl
                shl dx, cl
                mov cx, word ptr 1
                sub dx, cx
                
                mov ax, [ebp+16]
                mov bx, [ebp+12]
		
                ; and mask with first and with second then change (use not mask)
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
                
En:             
                
                
                pop edi
                pop esi
                pop ecx
                pop edx
                pop ebx
                pop eax
                pop ebp
                ret 20;??
SINGLE_POINT_CROSSOVER endp   
 

;procedure Versatile_Point_Crossover(var new_1:word;
;                                    first_indiv, second_indiv:word;
;                                    mask:word); 
;
;
; +8 mask
; +12 second_indiv
; +16 first_indiv
; +20 new_2
;
;
public VERSATILE_POINT_CROSSOVER                         
VERSATILE_POINT_CROSSOVER proc     

                push ebp
                mov ebp, esp
                push eax
                push ebx
                push edx
                push ecx
                push esi
                
                ; and mask with second then and (not mask) with first
                mov dx, [ebp+8]
                mov ax, [ebp+12]
                mov ebx, [ebp+20]
                and ax, dx
                mov cx, [ebp+16]
                not dx
                and cx, dx
                or ax, cx
                mov [ebx], ax
                            
                pop esi
                pop ecx
                pop edx
                pop ebx
                pop eax
                pop ebp
                ret 16;??
 
VERSATILE_POINT_CROSSOVER  endp 

;procedure Homogeneous_Point_Crossover(var new_1:word;
;                                    first_indiv, second_indiv:word;
;                                    mask:mas_mask);
; +8 mask
; +12 second_indiv
; +16 first_indiv
; +20 new_2

                                    
public HOMOGENEOUS_POINT_CROSSOVER                         
HOMOGENEOUS_POINT_CROSSOVER proc     

                push ebp
                mov ebp, esp
                push eax
                push ebx
                push edx
                push ecx
                push esi
                 
                
                ; create new indiv
                mov ebx, [ebp+20]
                mov edx, [ebp+16]
                
                mov [ebx], edx
                mov edx, [ebp+8]
                
                
                
                xor ch, ch
                ; go on array if 1 then second indiv, else first
L:     
                xor eax, eax
                inc ch
                inc edx
                mov ax, word ptr 1
                mov cl, 16
                sub cl, ch
                shl ax, cl
                mov spec, ax
                test ax, word ptr [edx]; check for 0
                jnz Cont
                
                mov ax,  [ebp+16]                
                mov si,  [ebp+12] 
                and ax, spec
                and si, spec
                cmp ax, si
                je Cont; if same bit i do nothing
                mov eax, [ebp+20]
                mov bx, [eax] 
                xor bx, spec
                mov [eax], bx
                
Cont:           cmp ch, 16
                jne L
                
En:             
                
                
                pop esi
                pop ecx
                pop edx
                pop ebx
                pop eax
                pop ebp
                ret 16;??
 
HOMOGENEOUS_POINT_CROSSOVER  endp                                     
                                    
                                    
                                    
;procedure Bit_Mutation(var new_1:word; indiv:word; point:byte); 
;begin
;  new_1 := indiv xor (1 shl (GENS - point));
;end;
; +8 point
; +12 indiv
; +16 new


public BIT_MUTATION
BIT_MUTATION proc 

                push ebp
                mov ebp, esp
                push eax
                push ecx
                
                
                mov cl, 16
                mov ch, byte ptr [ebp+8]
                sub cl, ch
                mov ax, word ptr 1
                shl ax, cl; 1 shl (GENS-point);
                ; output
                mov cx, [ebp+12]
                xor cx, ax
                mov eax, [ebp+16]
                mov [eax], cx
                
                pop ecx
                pop eax
                pop ebp
                ret 12
BIT_MUTATION endp           
    

;procedure Replace_Mutation(var new_1:word; indiv:word; first_point, second_point:byte);
; +8 point_1
; +12 point_2
; +16 indiv
; +20 new

public REPLACE_MUTATION
REPLACE_MUTATION proc 

                push ebp
                mov ebp, esp
                push eax
                push ebx
                push ecx
                push edx
                mov ecx, [ebp+20]
                mov dx,word ptr [ebp+16]
                mov [ecx], dx
                ; save first bit
                mov cl, 16
                mov ch, byte ptr[ebp+12]
                sub cl, ch
                mov ax, word ptr 1
                shl ax, cl
                mov spec, ax
                mov cx, [ebp+16]
                and ax, cx
               ; save second bit
                mov cl, 16
                mov ch, byte ptr[ebp+8]
                sub cl, ch
                mov bx, word ptr 1
                shl bx, cl
                mov spec2, bx 
                mov cx, [ebp+16]
                
                and bx, cx
                
                cmp ax, bx
                je En
                
                
                mov dx,word ptr [ebp+16]
                xor dx, spec
                xor dx, spec2
                mov ecx, [ebp+20]
                mov [ecx], dx
                
En:                
                pop edx
                pop ecx
                pop ebx
                pop eax
                pop ebp
                ret 12
REPLACE_MUTATION endp           


;procedure Reverse_Mutation(var new_1:word; indiv:word; point:byte);
;                               +16             +12             +8
; +8 point
; +12 indiv
; +16 new

public REVERSE_MUTATION
REVERSE_MUTATION proc
                push ebp
                mov ebp, esp
                push eax
                push ebx
                push ecx
                push edx
                push esi
                ; do mask, also like double crossing
                mov ch, byte ptr[ebp+8]
                mov dx, word ptr 1
                mov cl, 16
                sub cl, ch
                inc cl
                shl dx, cl
                sub dx, 1
                dec cl
                movzx bx, cl
                mov cx, bx
                xor bx, bx
                mov ax, [ebp+12]
                and ax, dx
                
                ;use flag
reverse:        
                shr ax, 1
                rcl bx, 1
                loop reverse
                mov ax, [ebp+12]
                not dx
                and ax, dx
                or ax, bx
                ; output
                mov ebx, [ebp+16]
                mov [ebx], ax
                
En:             
                pop esi
                pop edx
                pop ecx
                pop ebx
                pop eax
                pop ebp
                ret 12
                
REVERSE_MUTATION endp
end
               
%macro swap 2 
    pusha
    mov eax, %1 
    mov ebx, %2

    mov ecx, [temp]
    push ecx    
    mov    eax, %1
    mov    ebx, %2

    mov    edx, dword[array+eax*4]
    mov    dword[temp], edx

    mov    edx, dword[array+ebx*4]
    mov    dword[array+eax*4], edx

    mov    edx, dword[temp]
    mov    dword[array+ebx*4], edx

    pop ecx
    mov [temp], ecx
    popa
   %endmacro

%macro pushPivotFirstLast 0
	push dword[p]
        push dword[first]
        push dword[last]
%endmacro

%macro popLastFirstPivot 0
	pop dword[last]
	pop dword[first]
	pop dword[p]
%endmacro


%macro printParameters 0
    pusha
    mov ecx, [pfirst]
    mov dword[temp], ecx
    add dword[temp], '0'
    mov ecx, temp
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    mov ecx, [plast]
    mov dword[temp], ecx
    add dword[temp], '0'
    mov ecx, temp
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    popa
    %endmacro

%macro print_array 0
    pusha
    push temp
    mov eax, 4
    mov ebx, 1
    mov edx, 40
    mov ecx, array
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    mov ecx, 10
    mov [temp], ecx
    mov ecx, temp
    int 0x80
    pop ecx
    mov [temp], ecx
    popa
   %endmacro

_pivot:
    pusha
 
    mov edx, dword[count]

    for: ; put comparator at top of for loop for safery
	cmp dword[counter], edx
	jge endfor

	mov ecx, dword[counter]
        mov eax, dword[array+ecx*4] ; this was causing the mess. need *4 since 4 bytes per dword
        cmp    eax, [pvalue]
        jl    if
        jmp endif 
        if:
            inc dword[pcounter]
            swap [pcounter], [counter]
        endif:
        inc dword[counter]
        jmp for
	endfor:

    swap [pfirst], [pcounter]

    mov edx, [pcounter] 
    mov [returnval], edx

    popa
    ret

%macro pivot 2
    pusha 
    mov eax, %1
    mov ebx, %2

    mov dword[pfirst], eax
    mov dword[plast], ebx

    mov dword[counter], eax
    add dword[counter], 1

    mov edx, dword[plast] 
    add edx, 1
    mov dword[count], edx

    printParameters
    mov dword[pcounter], eax

    mov ebx, dword[array+eax*4] ;used *4 here fucked up over der mane
    mov dword[pvalue], ebx

    call _pivot
    print_array
    popa
   %endmacro

%macro exit 0
    mov eax, 1
    int 0x80
   %endmacro

%macro set_array 0
    pusha
    mov dword[array+0], '3' 
    mov dword[array+4], '2'
    mov dword[array+8], '8'
    mov dword[array+12], '1'
    mov dword[array+16], '0'
    mov dword[array+20], '4'
    mov dword[array+24], '5'
    mov dword[array+28], '9'
    mov dword[array+32], '6'
    mov dword[array+36], '7'
    popa
   %endmacro

_quickSort:
	pusha

	mov dword[first], eax
    	mov dword[last], ebx

	cmp eax, ebx
	jg end

	pivot dword[first], dword[last]
	
	mov edx, dword[returnval]
	mov dword[p], edx
	
	pushPivotFirstLast

	mov eax, dword[first]
	mov ebx, dword[p]
	sub ebx, 1
	call _quickSort

	popLastFirstPivot
        
	mov eax, dword[p]
	add eax, 1
	mov ebx, dword[last]
	call _quickSort

	end:
	popa
	ret

%macro quickSort 2
    pusha
    mov eax, %1 
    mov ebx, %2
    call _quickSort
    popa
   %endmacro


section    .text
    global _start   
_start:           
    set_array 
    
    print_array
    quickSort 0, 9
    print_array

    exit
    
section    .data
msg db '4932705169', 0xa  
len equ $ - msg             

section .bss
temp: resd 1 ; nasm wants these to be double works since registers = 32 bits

array: resd 10
first: resd 1
last: resd 1

pfirst: resd 1
plast: resd 1

count: resd 1
p: resd 1
pcounter: resd 1
pvalue: resd 1
returnval: resd 1
counter: resd 1
newtemp: resd 1
reg: resd 1

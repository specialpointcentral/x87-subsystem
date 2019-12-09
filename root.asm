section .data

  trash TIMES 10 db 0
  format_double_in: db "%lf",0
  format_double_out: db "%lf",10,0
  format_int_in: db "%d",0
  format_int_out: db "%d",10,0
  format_string_in: db "%s",0
  format_string_out: db "%s",10,0
  format_long_in: db "%ld",0
  format_long_out: db "%ld",10,0
  format_result: db "root = %lf %lf",10,0
  trash_indexer: dd 0
  epsilon: dq 0.0
  order: dd 0
  order_float: dq 1.0
  sub_float: dq 1.0
  power: dd 0
  table: dq 0
  derivative: dq 0
  table_loop_index: dd 0
  curr_complex_tested: dq 0.0
                       dq 0.0
  temp1: dq 0.0
         dq 0.0
  temp2: dq 0.0
         dq 0.0
  temp3: dq 0.0
         dq 0.0
  temp4: dq 0.0
         dq 0.0
  result:dq 0.0
         dq 0.0
  f: dq 0.0
     dq 0.0
  f_deriv:dq 0.0
     dq 0.0
  conjugate TIMES 2 dq 0.0
  complex_length: dq 0
  switch_sign: dq -1.0
  zero_float: dq 0.0
  sign: db 0
  
  
extern printf
extern scanf
extern malloc
global main

section .text
 main:
	nop
	enter 0,0
	jmp trash_epsilon

trash_epsilon:
	cmp dword[trash_indexer],2
	je set_epsilon
	inc dword[trash_indexer]
    mov rdi, format_string_in
	mov rsi, trash
    call scanf
	;mov rdi,format_string_out
	;mov rsi,trash
	;call printf
	jmp trash_epsilon
      
set_epsilon:
	mov dword[trash_indexer],0
	mov rdi, format_double_in
	mov rsi, epsilon
    call scanf
    ;mov rdi, format_double_out
	;movsd xmm0, qword[epsilon]
	;mov rax,1
    ;call printf
	jmp trash_order

trash_order:
	cmp dword[trash_indexer],2
	je set_order
	inc dword[trash_indexer]
    mov rdi, format_string_in
	mov rsi, trash
    call scanf
	jmp trash_order
	;mov rdi,format_string_out
	;mov rsi,trash
	;call printf
set_order:
	mov rsi,0
	mov dword[trash_indexer],0
	mov rdi, format_int_in
	mov rsi, order
    call scanf
	finit
    ;mov rdi, format_int_out
	;mov esi, dword[order]
    ;call printf
	mov r8,1
	jmp set_float_order

set_float_order:
	finit
        fld qword[order_float]
	fst st1 ; st0 = st1 = 1
	.loop:
		cmp r8d,dword[order]
		je .init_float_order
		fadd st1
		inc  r8d
		jmp .loop
	
	.init_float_order:
		fst qword[order_float]
		;mov rdi, format_double_out
		;movsd xmm0, qword[order_float]
		;call printf
		je set_table

set_table:
	mov dword[trash_indexer],0
	mov ebx,dword[order]
	inc ebx
	mov eax,8
	mul ebx	
	;mov rdi,format_long_out
	;mov rsi,rax
	;call printf
	mov rdi,rax
	call malloc
    mov qword[table],rax; qword[table] - is an address to value 0

    ;mov rdi, format_long_out
	;mov rsi, qword[table]; **** printing purposes
	;call printf
	
	mov rbx,0
	mov ebx,dword[order]
	inc ebx
	
loop_malloc:
	cmp dword[table_loop_index],ebx
	je .pre_set
	mov rdi,16
	call malloc
	mov ecx,dword[table_loop_index]
	mov rdx, qword[table]
	mov qword[rdx+rcx*8],rax

	;mov rdi, format_int_out
	;mov esi, dword[table_loop_index]
	;call printf
    ;mov rdi, format_long_out
	;mov ecx,dword[table_loop_index]  ; **** printing purposes
	;mov rdx, qword[table]
	;mov rsi, qword[rdx+rcx*8]
	;call printf

	inc dword[table_loop_index]
	jmp loop_malloc	
	.pre_set:
		mov dword[table_loop_index],0
	.loop_set:
		cmp dword[table_loop_index],ebx
		je trash_init_complex
		jmp .loop_trash
	.loop_trash:
		cmp dword[trash_indexer],1
		je .set_power
		cmp dword[trash_indexer],3
		je .set_comp
		inc dword[trash_indexer]
		mov rdi, format_string_in
		mov rsi, trash
		call scanf
		jmp .loop_trash
	.set_power:
		mov rdi,format_int_in
		mov esi,power
		call scanf	
        ;mov rdi, format_int_out
	    ;mov esi, dword[power] ; **** printing purposes
	    ;call printf
		inc dword[trash_indexer]
		jmp .loop_trash
		
	.set_comp:
		mov rdi, format_double_in
		mov r8, qword[table]; 
		mov ecx, dword[power];
        mov rsi, [r8 + rcx*8]
		call scanf

		;mov rdi, format_double_out
		;mov r8, qword[table]; 
		;mov ecx, dword[power];
		;mov rdx, [r8+rcx*8]
        ;movsd xmm0, [rdx]
		;mov rax,1
		;call printf

		mov rdi, format_double_in
		mov r8, qword[table]; 
		mov ecx, dword[power];
                mov rsi, [r8 + rcx*8]
		add rsi,8
		call scanf

		;mov rdi, format_double_out
		;mov r8, qword[table]; 
		;mov ecx, dword[power];
		;mov rdx, [r8+rcx*8]
        ;movsd xmm0, [rdx+8]
		;mov rax,1
		;call printf

		;mov rdi, format_int_out
		;mov esi, dword[table_loop_index]; **** printing purposes
		;call printf

		inc dword[table_loop_index]
		mov dword[trash_indexer],0
		jmp .loop_set

trash_init_complex:
		cmp dword[trash_indexer],2
		je init_complex
		inc dword[trash_indexer]
		mov rdi, format_string_in
		mov rsi, trash
		call scanf
		jmp trash_init_complex

init_complex:
		mov rdi, format_double_in
		mov rsi, curr_complex_tested
		call scanf
		mov rdi, format_double_in
		mov rsi, curr_complex_tested
		add rsi,8
		call scanf
		
		;mov rdi, format_double_out
		;movsd xmm0,qword[curr_complex_tested]
		;mov rax,1
		;call printf

		;mov rdi,format_double_out
		;movsd xmm0, qword[curr_complex_tested+8]
		;mov rax,1
		;call printf
		
		jmp calculate_derivative
		
calculate_derivative:
        mov dword[trash_indexer],0
    	mov ebx,dword[order]
    	mov eax,8
    	mul ebx	
    	;mov rdi,format_long_out
    	;mov rsi,rax
    	;call printf
        ;jmp end_code
    	mov rdi,rax
    	call malloc
        mov qword[derivative],rax; qword[table] - is an address to value 0
        
        ;-----------------------------derivative[][]------------------------------
        mov rbx,0
    	mov ebx,dword[order]
    	mov dword[table_loop_index],0

        ;mov rdi, format_long_out
	    ;mov rsi, qword[table]; **** printing purposes
	    ;call printf
	   
loop_malloc_derivative:
        
        cmp dword[table_loop_index],ebx
    	je set_derivative
    	mov rdi,16
    	call malloc
    	mov ecx,dword[table_loop_index]
    	mov rdx,qword[derivative]
    	mov qword[rdx+rcx*8],rax

    	;mov rdi, format_int_out
    	;mov esi, dword[table_loop_index]
    	;call printf
        ;mov rdi, format_long_out
    	;mov ecx,dword[table_loop_index]  ; **** printing purposes
    	;mov rdx, qword[table]
    	;mov rsi, qword[rdx+rcx*8]
	    ;call printf
           
    
    	inc dword[table_loop_index]
    	jmp loop_malloc_derivative	
	
set_derivative:
        
       ;temp2 = n
	   mov r8,qword[order_float]
	   mov qword[temp2], r8
       mov r9,qword[temp3]
	   mov qword[temp2+8],r9



	.loop:
		finit
		cmp rbx,0
		je eval_comp_init
		;temp1 = c(n)
		mov r8,qword[table]
		mov r9,[r8+rbx*8]
		mov r10,[r9]
		mov qword[temp1],r10
		mov r10,[r9+8]
		mov qword[temp1+8],r10


		;mov rdi, format_result
		;movsd xmm0, qword[temp2]
		;movsd xmm1, qword[temp2+8]
		;mov rax,2
		;call printf
	  
		call comp_mult

        ;mov rdi, format_result
	    ;movsd xmm0, qword[result]
		;movsd xmm1, qword[result+8]
		;mov rax,2
		;call printf
        ;jmp end_code
	
        finit
		fld qword[sub_float]
		fld qword[temp2]
		fsub st1
		fst qword[temp2]
		
		;c(n)' = n*c(n)
		dec rbx

        finit
        fld qword[result]
		mov r8,qword[derivative]
		mov r9,[r8+rbx*8]
		fst qword[r9]
		fld qword[result+8]
		fst qword[r9+8]
		
		;mov rdi, format_result
		;movsd xmm0, qword[r9]
		;movsd xmm1, qword[r9+8]
		;mov rax,2
		;call printf
       
		jmp .loop
        
calculate_length:
      
    finit 
    fld qword[result]
    fst qword[f]
    fld qword[result+8]
    fst qword[f+8]
    
    
    mov byte[sign],1
    finit
	fld qword[f] ; st0 - real
	fmul st0,st0 ; st0 = real^2

	fld qword[f+8]; now st0 = img, st1 = real^2
	fmul st0,st0 ; st0 = img ^2

	fadd st0,st1; sum of squares
	fsqrt ; square root
    

	fst qword[complex_length]

    ;mov rdi, format_double_out
	;movsd xmm0, qword[complex_length]
	;mov rax,1
	;call printf
    ;jmp end_code

	;mov rdi, format_result
	;movsd xmm0, qword[f]
    ;movsd xmm1, qword[f+8]
	;mov rax,2
	;call printf
    ;jmp end_code
	
	jmp compare_to_epsilon

compare_to_epsilon:

    
	fld qword[epsilon]
	fld qword[complex_length]; st0 - complex_length, st1 - epsilon
	fcom st1
	fstsw ax
	fwait
	sahf
	jb end_code
	jz end_code

	jmp eval_comp_derivative_init

comp_sum:
        
        
        enter 0,0
        finit
        fld qword[temp1]
        fld qword[temp2]
        faddp 
        fst qword[result]
        
        fld qword[temp1+8]
        fld qword[temp2+8]
        faddp 
        fst qword[result+8]
        
        leave
        ret
        ;mov rdi, format_result
        ;movsd xmm0, qword[result]
        ;movsd xmm1, qword[result+8]
        ;mov rax,2
        ;call printf
        
comp_sub:
	enter 0,0
        finit
       
        fld qword[temp1]
        fld qword[temp2]
        fsub 
        fst qword[result]
        fld qword[temp1+8]
        fld qword[temp2+8]
        fsub
        fst qword[result+8]
        ;mov rdi, format_result
        ;movsd xmm0, qword[result]
        ;movsd xmm1, qword[result+8]
        ;mov rax,2
        ;call printf
	leave 
	ret
        
comp_mult:
       
        enter 0,0
	finit
        fld qword[temp1] 
        fld qword[temp2]
        fmulp; sto = img*img
        fld qword[temp1+8]
        fld qword[temp2+8]
        fmulp;
        fsubp;
        fst qword[result]
        
        
        fld qword[temp1+8]; num1 img
        fld qword[temp2]; num2 real
        fmulp; st0 - num1 img * num2 real
        fld qword[temp1]
        fld qword[temp2+8]
        fmulp; st2 - num2 img * num1 real
        faddp 
        fst qword[result+8]
        
        ;mov rdi, format_result
        ;movsd xmm0, qword[result]
        ;movsd xmm1, qword[result+8]
        ;mov rax,2
        ;call printf
        leave
        ret
        
comp_div:
	   enter 0,0
    	finit
        fld qword[temp2+8]
        fld qword[switch_sign]
        fmulp
        
        fst qword[conjugate+8]
        fld qword[temp2]
        fst qword[conjugate]

        
        ;nominator * conjugate
        fld qword[temp1] 
        fld qword[conjugate]
        fmulp; sto = img*img
        fld qword[temp1+8]
        fld qword[conjugate+8]
        fmulp;
        fsubp;
        fst qword[temp3]
        
        finit
        fld qword[temp1+8]; num1 img
        fld qword[conjugate]; num2 real
        fmulp; st0 - num1 img * num2 real
        fld qword[temp1]
        fld qword[conjugate+8]
        fmulp; st2 - num2 img * num1 real
        faddp 
        fst qword[temp3+8]

        
        ;print
        ;mov rdi, format_result
        ;movsd xmm0, qword[temp3]
        ;movsd xmm1, qword[temp3+8]
        ;mov rax,2
        ;call printf
        
        ;denominator * conjugate
        finit
        fld qword[temp2] 
        fld qword[conjugate]
        fmulp; sto = img*img
        fld qword[temp2+8]
        fld qword[conjugate+8]
        fmulp;
        fsubp;
        fst qword[temp4]
        fst qword[temp4+8]
                        
    
        finit    
        fld qword[temp3];nominator
        fld qword[temp4];denominator
        fdivp
        fst qword[result]
        
        
        fld qword[temp3+8]
        fld qword[temp4+8]
        fdivp
        fst qword[result+8]
           

        leave 
        ret

eval_comp_derivative_init:

        ;/////
    
        mov r11,0
        mov r11d, dword[order]
	    dec r11
        
        ;result = c(1)
        finit
        mov r8,qword[derivative]
        mov r9,[r8+r11*8]
        fld qword[r9]
        fst qword[result]
        fld qword[r9+8]
        fst qword[result+8]        
        
        
        jmp eval_comp_derivative
        
        ;temp1 = c(n) , temp2 = z

eval_comp_derivative:

        cmp r11,0
        je newton_method
        
        ;temp1 = result
        finit
        fld qword[result]
        fst qword[temp1]
        fld qword[result+8]
        fst qword[temp1+8]
        
        ;temp2 = curr_complex_tested
        finit
        fld qword[curr_complex_tested]
        fst qword[temp2]
        fld qword[curr_complex_tested+8]
        fst qword[temp2+8]
        
        
        call comp_mult
        dec r11
        ;result holds z*c(n)
        
        ;mov rdi, format_result
        ;movsd xmm0, qword[result]
        ;movsd xmm1, qword[result+8]
        ;mov rax,2
        ;call printf
        
        ;temp1 = result
        finit
        fld qword[result]
        fst qword[temp1]
        fld qword[result+8]
        fst qword[temp1+8]

        
        ;temp2 holds c(n-1)
        finit
        mov r8,qword[derivative]
        mov r9,[r8+r11*8]
        fld qword[r9]
        fst qword[temp2]
        fld qword[r9+8]
        fst qword[temp2+8]   
        
                     
        ;mov rdi, format_result
        ;movsd xmm0, qword[result]
        ;movsd xmm1, qword[result+8]
        ;mov rax,2
        ;call printf     
        call comp_sum
        jmp eval_comp_derivative

        
eval_comp_init:
        
        
        mov r11,0
        mov r11d, dword[order] 
        
        finit
        ;result = c(n)
        mov r8,qword[table]
        mov r9,[r8+r11*8]
        fld qword[r9]
        fst qword[result]
        fld qword[r9+8]
        fst qword[result+8]          
        jmp eval_comp
        
        ;temp1 = c(n) , temp2 = z
eval_comp:
        cmp r11,0
        je calculate_length
        
        ;temp1 = result
        finit
        fld qword[result]
        fst qword[temp1]
        fld qword[result+8]
        fst qword[temp1+8]
        
        
        ;temp2 = curr_complex_tested
        finit
        fld qword[curr_complex_tested]
        fst qword[temp2]
        fld qword[curr_complex_tested+8]
        fst qword[temp2+8]

        
        call comp_mult
        
                

        
        dec r11
        ;result holds z*c(n)
        
        ;temp1 = result
        finit
        fld qword[result]
        fst qword[temp1]
        fld qword[result+8]
        fst qword[temp1+8]

        
        ;temp2 holds c(n-1)
        finit
        mov r8,qword[table]
        mov r9,[r8+r11*8]
        fld qword[r9]
        fst qword[temp2]
        fld qword[r9+8]
        fst qword[temp2+8]        

        call comp_sum
      
        
        jmp eval_comp
        

newton_method:
	
    finit
    ;temp 1 = f(z)
	fld qword[f]
	fst qword[temp1]
	fld qword[f+8]
	fst qword[temp1+8]

    ;temp2 = f'(z)
	fld qword[result]
	fst qword[temp2]
	fld qword[result+8]
	fst qword[temp2+8]

	;mov rdi, format_result
    ;movsd xmm0, qword[result]
    ;movsd xmm1, qword[result+8]
    ;mov rax,2
    ;call printf
    ;jmp end_code
    
	call comp_div
    
    ;mov rdi, format_result
    ;movsd xmm0, qword[result]
    ;movsd xmm1, qword[result+8]
    ;mov rax,2
    ;call printf
    ;jmp end_code
    
    
	finit 
	fld qword[curr_complex_tested]
	fst qword[temp1]
	fld qword[curr_complex_tested+8]
	fst qword[temp1+8]
	fld qword[result]
	fst qword[temp2]
	fld qword[result+8]
	fst qword[temp2+8]

	call comp_sub
	fld qword[result]
	fst qword[curr_complex_tested]
    fld qword[result+8]
    fst qword[curr_complex_tested+8]

	jmp eval_comp_init
        
end_code:
	finit
	mov rdi, format_result
	movsd xmm0, qword[curr_complex_tested]
	movsd xmm1, qword[curr_complex_tested+8]
	mov rax,2
    call printf
    ;mov rdi, format_double_out
	;movsd xmm0, qword[complex_length]
	;mov rax,1
	;call printf
	leave
	ret

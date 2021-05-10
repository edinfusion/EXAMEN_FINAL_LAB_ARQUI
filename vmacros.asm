

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%% CONVERTIR A ASCII PARA VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;CONVERTIR A ASCII

prueba macro vector
    ;punteroDSaDatos
    push cx
    xor cx,cx
    mov cx,vector
    convertAscii cx
    ;imprimir NumPrint
    pop cx
   ; punteroDSaVideo
endm
convertAscii macro Numerito
    push ax
    mov ax,Numerito
    ConvertirPrint
    pop ax
endm

ConvertirPrint macro
    LOCAL Bucle2, toNum2,casoMinimo2,FIN2
    push bp                   
    mov  bp,sp                
    sub  sp,4                 
    mov word ptr[bp-4],0      
    pusha
    LimpiarArray NumPrint, SIZEOF NumPrint, 24h
    xor si,si                        
    cmp ax,0                        
    je casoMinimo2         
    mov  bx,0                       
    push bx                          
            Bucle2:  
                mov dx,0
                cmp ax,0                   
                je toNum2                                
                mov bx,10               
                div bx                    
                add dx,48d                
                push dx                    
                jmp Bucle2
            toNum2:
                pop bx                   
                mov word ptr[bp-4],bx    
                mov al, byte ptr[bp-4]
                cmp al,0                   
                je FIN2                  
                mov NumPrint[si],al          
                inc si                            
                jmp toNum2                 
            casoMinimo2:
                add al,48d                     
                mov NumPrint[si],al                
                jmp FIN2
            FIN2:
                popa
                mov sp,bp           
                pop bp                
endm

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LIMPIAR ARREGLO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;params: vector,tamaño,caracterparalimpiar
LimpiarArray macro buffer, NoBytes, Char
	LOCAL Repetir
    push si
    push cx
	xor si,si
	xor cx,cx
	mov cx,NoBytes
	Repetir:
	    mov buffer[si], Char
	    inc si
	loop Repetir
    pop cx
    pop si
endm

;esta macro sirve para almacenar
;lo que digite el usuario
;para posteriormente validar
;si es valido o no
;peram: vector donde se guarda lo digitado 
getInputKey macro buffer
    local CICLO, FIN
        PUSH SI
        PUSH AX
        xor si,si
        xor ax,ax
        CICLO:
            getCaracter
            cmp al,13
            je FIN
            cmp al,95
            je FIN
            mov buffer[si],al
            inc si
            jmp CICLO

        FIN:
            mov al,'$'
            mov buffer[si],al

        POP AX
        POP SI
endm

;convierte letras Mayus a minus
;params Vector, numBys
aMinuscula macro Vector, numBYs
    LOCAL cicloconverMinus, salto
        mov cx,numBYs
        xor si,si
        cicloconverMinus:
            cmp Vector[si],64;pongo limites inf de < para que salte todos esos
            jb salto;  < aqui incrementa el si en dado caso no sea letra
            cmp Vector[si],91; pongo limites superiores para saltar y no tome carcter diferente de letra
            ja salto; >

            mov al, Vector[si];hago una copia para poder trabjar en la suma
            add al,32;se suma 32 para obtener la minuscula de esa letra
            mov Vector[si],al;obtengo la letra ya en minuscula

            salto:;incremento si
                inc si;si+=si
            loop cicloconverMinus
endm
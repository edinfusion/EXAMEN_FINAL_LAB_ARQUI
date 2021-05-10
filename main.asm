.model small
.stack 200h
.data
    ;este vector se utiliza para mostrar el numero convertido a ascii
    NumPrint db 100 dup('$')
    encabezado db "Examen final - 1Sem2021 - Edin Emanuel Montenegro Vasquez - 201709311",10,'$'
    n1 db "Num1: ",'$'
    n2 db 10, "Num2: ",'$'
    num0 dw ?,'$'
    num1 dw ?,'$'
    resultado dw ?,'$'
    operandos db 300 dup('$')
    decena dw 10
    msgRes db 10,"RESULTADO: "
    nLinea db 10,'$'
    banderaNeg dw 0
    negativo db '-','$'
.code

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MACRO IMPRIMIR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;macro para impresion 
;con interrupcion 21H 
;recibe un "string"
imprimir macro cadena
    push ax
    push dx
    mov ah, 09h
    lea dx, cadena
    int 21h
    pop dx
    pop ax
endm



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Esperar Caracter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;devueleve codigo ASCII del
;caracter leido
getCaracter macro
    mov ah,01h
    int 21h
endm

;se utiliza int 10h/0e para mostrar y desplazar cursor
printDCalcu macro
    mov ah,0eh
    int 10h ; int 10h
endm

imprimirCaracter macro char
    PUSH AX;agregamos a pila ax
	MOV AL, char;movemos a al el caracter entrante
	MOV AH, 0Eh;funcion de salida teletipo
    INT 10h; interrupcion con funcion VGA
    POP AX;sacamos de pila ax
endm 

;devuelve el caracter ingresado
;se utiliza en calc
;debido a que genero problema
; la 21h
getNum macro
    mov ah,00h
	int 16h;o
endm

;se obtiene numero de pulsacion por teclado
getNumber macro
    
    Local getDigit, NumeroNegativo,cambiar, Prueba, Retroceso, Validar,i_Numero ,limpiarCar,Final,big_num,M2_digitos,normal,mine,V_num
    xor ax,ax
    ;ingreso a pila para almacenar digitos posteriormente*
    push dx; se ingresa a la pila por si hay un numero muy grande se compara*parte alta
    push ax; aca se acumulan los digitos*parte baja
    push si;

   
    mov cx,0000h;limpieza de registros
    mov cs:mine , 0;limpieza
    

    mine db ? ;etiqueta indefinida servira para almacenar estado de bandera signo -
    getDigit:
        
        getNum
        printDCalcu
        ;if al == '-'
        cmp al, '-' ;se verifica que el digito ingresado sea un menos
        ;then
        je NumeroNegativo;se prepara el digito para negativo
        ;else
        cmp al, 0dh;compara si caracter ingresado es enter
        jne Prueba; si es sigue codigo en getDigit ;sino sigue a prueba
        ;si es igual brinca al final de la macro:
        jmp Final
    NumeroNegativo:
;        mov cs:mine, 1; asignamos 1 para indicar num neg
        cmp banderaNeg,1
        je cambiar
        mov banderaNeg,1
        inc di
        jmp getDigit;ya que habilitamos el signo regresamos para obtener el digito
        cambiar:
        mov banderaNeg,0
        inc di
        jmp getDigit;ya que habilitamos el signo regresamos para obtener el digito


    Prueba:
        ;if al == '<--'
        cmp al,08h; se hace otra comparacion, para saber si el caracter ingresado no fue un backspace
        jne Validar
        jmp Retroceso
        ;then
        
    Validar:
        cmp al,30h ;compara si es un numero
        jae i_Numero;se utiliza salto JAE para mayor o igual ">=0"
        jmp limpiarCar; limpia si no es numero 
    
    i_Numero:
        cmp al, 39h
        jbe V_num


    limpiarCar:
        imprimirCaracter 08h
        imprimirCaracter ' '
        imprimirCaracter 08h
        jmp getDigit

    V_num:
        push ax
        mov ax,cx 
        mul decena ; ax=ax*10 cambia a la siguiente posicion
        mov cx,ax ;copia
        pop ax ;eliminamos

        cmp dx,0 ; si es numero mayor de 4 cifras
        jne big_num

        sub al,30h
        
        mov operandos[di],al
        inc di
        mov ah,00h
        mov dx,cx
        add cx,ax
        jc M2_digitos
        jmp getDigit

    Retroceso:
        mov dx,0000h;se limpia
        mov ax,cx;cambio
        div decena 
        mov cx,ax
        imprimirCaracter ' ';se limpia la posicion anterior
        imprimirCaracter 08h
        jmp getDigit
    
    

    big_num:
        mov ax,cx;movemos registros
		div decena; ax=Ax/10
		mov cx,ax;movemos registros
		imprimirCaracter 08h;retrocedemos al espacio anterior
		imprimirCaracter ' ';lo limpiamos 
		imprimirCaracter 08h;regresamos al espacio anterior
		jmp getDigit; saltamos hacia el siguiente digito
    
    M2_digitos:
        mov cx,dx;movemos registros
		mov dx,0000h;limpiamos dx
    Final:
        cmp cs:mine,0;comparamos el estado de la bandera
		je normal;si esta en 0 entonces es un numero positivo 
		neg cx ; le hace complemento a 2 a ax
    
    normal:
        pop si;sacamos de la pila el registro de indice 
		pop ax;sacamos de la pila el registro ax
		pop dx;sacamos de la pila el registro dx
        
    
endm
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


Multiplicar macro
    LOCAL ciclosuma
    xor cx,cx
    mov cx,num1;se mueve el numero de veces que se sumara 
    xor ax,ax
    ciclosuma:
        add ax,num0;el segundo numero 
    loop ciclosuma
    prueba ax;se obtiene resultado
endm

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main proc 
    mov ax,@data
    mov ds,ax
    Inicio:
        mov banderaNeg,0
        imprimir encabezado

    Numeros:
        imprimir n1
        getNumber
        mov num0,cx;almacena num en vec
        imprimir n2
        getNumber
        mov num1,cx;almacena num en vec
        imprimir nLinea
        Multiplicar
        cmp banderaNeg,1
        je ResultadoNeg
        imprimir msgRes
        ;prueba resultado
        imprimir NumPrint
        imprimir nLinea     
        jmp Inicio
    ResultadoNeg:
        imprimir msgRes
        imprimir negativo
        imprimir NumPrint
        
        
        imprimir nLinea     
    jmp Inicio

main endp
.exit 

end main




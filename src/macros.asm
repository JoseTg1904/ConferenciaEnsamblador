imprimir macro cadena, color
    mov ax, @data ;Moviendo el segmento de data al registro de proposito general
    mov ds, ax

    mov ah, 09h ;Tipo de operacion de 21h muestra caracteres, basicamente print
    mov bl, color ;Color del texto de salida
    mov cx, lengthof cadena - 1 ;Pintar el texto en su totalidad
    int 10h ;Interrupcion para dar color
    lea dx, cadena ;Mostrando la cadena
    int 21h ;Interrupcion para mostrar
endm

limpiarTerminal macro
    mov ax, 03h 
    int 10h
endm

leerHastaEnter macro entrada
    local salto, fin

    xor bx, bx ;Limpiando el registro
    salto:
        mov ah, 01h
        int 21h
        cmp al, 0dh ;Verificar si es un salto de linea lo que se esta leyendo
        je fin
        mov entrada[bx], al
        inc bx
        jmp salto

    fin:
        mov al, 24h ;Agregando un signo de dolar para eliminar el salto de linea
        mov entrada[bx], al
endm

imprimirMatriz macro
    local ciclo, ciclo2, ciclo3, ciclo4, reinicio, reinicio2

    imprimir espacio, 0d
    imprimir espacio, 0d 
    xor si, si
    ; Ciclo para imprimir las cabeceras de columnas de la matriz
    ciclo: 
        ; Se mueve hacia una variable que simula un caracter, porque el macro imprimir 
        ; realiza la impresion hasta que encuentra el simbolo de final de cadena
        mov bl, cabecerasC[si] 
        mov individual[0], bl
        imprimir individual, 15d 
        imprimir espacio, 0d
        imprimir espacio, 0d
        imprimir espacio, 0d
        inc si
        cmp si, 3d
        jnz ciclo

    imprimir salto, 0d
    xor si, si
    mov iteradorJ, 0d
    ciclo2: ; Ciclo que imprime las caberas de las filas
        mov bl, cabecerasF[si]
        mov individual[0], bl
        imprimir individual, 15d
        imprimir espacio, 0d

        mov iteradorI, 0d
        ciclo3: ;ciclo que imprime los valores de las filas
            mov di, iteradorJ
            verificarValor tablero[di]
            inc iteradorJ
            imprimir individual, color

            inc iteradorI ;validacion para hacer linea divisioria
            cmp iteradorI, 3d
            jz reinicio

            imprimir espacio, 0d
            mov bl, lineas[0]
            mov individual[0], bl
            imprimir individual, 15d
            imprimir espacio, 0d            
            jmp ciclo3

        reinicio: ;ciclo que imprimie la linea divisoria entre filas
            cmp si, 2d
            jz reinicio2
            mov iteradorI, 0d
            imprimir salto, 0d  
            imprimir espacio, 0d
            imprimir espacio, 0d
            ciclo4:
                mov bl, lineas[1]
                mov individual[0], bl
                imprimir individual, 15d
                inc iteradorI
                cmp iteradorI, 9d
                jnz ciclo4

        reinicio2:
            imprimir salto, 0d
            inc si
            cmp si, 3d
            jnz ciclo2
endm

verificarValor macro valor
    local cero, uno, dos, fin

    cmp valor, 0
    jz cero

    cmp valor, 1
    jz uno

    dos:
        mov color, 14d
        mov individual[0], "O"
        jmp fin

    uno:
        mov color, 11d
        mov individual[0], "X"
        jmp fin

    cero:
        mov color, 0d
        mov individual[0], " "

    fin:
endm

obtenerIndice macro row, column
    ;posicion[i][j] en el arreglo = i * numero columnas + j 
    mov ax, row
    mov bx, 3d 
    mul bx
    add ax, column
    mov indice, ax
endm

obtenerFilaColumna macro
    local ciclo, ciclo2, asignar, asignar2

    xor di, di
    mov bl, bufferTeclado[0]
    ciclo: ;ciclo para comparar el valor ingresado con las filas disponibles
        cmp cabecerasF[di], bl
        jz asignar
        inc di
        cmp di, 3d
        jnz ciclo

    mov di, 0d
    asignar:
        mov fila, di

    xor di, di
    mov bl, bufferTeclado[1]
    ciclo2: ;ciclo para comparar el valor ingresado con las columnas disponibles
        cmp cabecerasC[di], bl
        jz asignar2
        inc di
        cmp di, 3d
        jnz ciclo2

    mov di, 0d
    asignar2:
        mov columna, di
endm

validarTablero macro
    validarFila
    validarColumna
    validarDiagonalS
    validarDiagonalS2
endm

validarFila macro 
    local ciclo, ciclo2, valido, valido2, fin

    mov fila, 0d
    mov columna, 0d
    obtenerIndice fila, columna

    ciclo:
        mov di, indice
        cmp tablero[di], 0d ; if tablero[i] == 0 = posicion vacia
        jz valido2 ; si es vacia pasar a la siguiente fila
        jnz ciclo2 ; si no verificar la fila completa

    ciclo2:
        mov di, indice
        mov al, tablero[di]
        mov extra, al

        inc columna
        obtenerIndice fila, columna

        mov di, indice
        mov al, tablero[di]
        cmp al, extra
        jz valido
        jnz valido2

    valido:
        cmp columna, 2d
        jnz ciclo2
        mov banderaGanador, 1d
        jmp fin

    valido2:
        inc fila
        mov columna, 0d
        obtenerIndice fila, columna
        cmp fila, 3d
        jnz ciclo

    fin:
endm

validarColumna macro
    local ciclo, ciclo2, valido, valido2, fin

    mov fila, 0d
    mov columna, 0d
    obtenerIndice fila, columna
    ciclo:
        mov di, indice
        cmp tablero[di], 0d
        jz valido2
        jnz ciclo2

    ciclo2:
        mov di, indice
        mov al, tablero[di]
        mov extra, al

        inc fila
        obtenerIndice fila, columna

        mov di, indice
        mov al, tablero[di]
        cmp al, extra
        jz valido
        jnz valido2

    valido:
        cmp fila, 2d
        jnz ciclo2
        mov banderaGanador, 1d
        jmp fin

    valido2:
        inc columna
        mov fila, 0d
        obtenerIndice fila, columna
        cmp columna, 3d
        jnz ciclo

    fin:
endm

validarDiagonalS macro 
    local ciclo, ciclo2, valido, fin

    mov fila, 0d
    mov columna, 0d
    obtenerIndice fila, columna
    ciclo:
        mov di, indice
        cmp tablero[di], 0d
        jz fin
        jnz ciclo2

    ciclo2:
        mov di, indice
        mov al, tablero[di]
        mov extra, al

        inc fila
        inc columna
        obtenerIndice fila, columna

        mov di, indice
        mov al, tablero[di]
        cmp al, extra
        jz valido
        jmp fin

    valido:
        cmp fila, 2d
        jnz ciclo2
        mov banderaGanador, 1d
        jmp fin

    fin:
endm

validarDiagonalS2 macro 
    local ciclo, ciclo2, valido, fin

    mov fila, 0d
    mov columna, 2d
    obtenerIndice fila, columna
    ciclo:
        mov di, indice
        cmp tablero[di], 0d
        jz fin
        jnz ciclo2

    ciclo2:
        mov di, indice
        mov al, tablero[di]
        mov extra, al

        inc fila
        dec columna
        obtenerIndice fila, columna

        mov di, indice
        mov al, tablero[di]
        cmp al, extra
        jz valido
        jmp fin

    valido:
        cmp fila, 2d
        jnz ciclo2
        mov banderaGanador, 1d
        jmp fin

    fin:
endm

leerFila macro name
    local inicio, ciclo, asignar

    inicio:
        imprimir name, 15d
        imprimir ingresa, 15d
        leerHastaEnter bufferTeclado
        xor di, di
        mov bl, bufferTeclado[0]

    ciclo: ;ciclo para comparar el valor ingresado con las filas disponibles
        cmp cabecerasF[di], bl
        jz asignar
        inc di
        cmp di, 3d
        jnz ciclo

    imprimir salto, 0d
    imprimir name, 1100b
    imprimir valida, 1100b
    imprimir salto, 0d
    imprimir salto, 0d
    jmp inicio

    asignar:
        mov fila, di
endm

leerColumna macro name
    local inicio, ciclo, asignar

    inicio:
        imprimir name, 15d
        imprimir ingresa2, 15d
        leerHastaEnter bufferTeclado
        xor di, di
        mov bl, bufferTeclado[0]

    ciclo: ;ciclo para comparar el valor ingresado con las filas disponibles
        cmp cabecerasC[di], bl
        jz asignar
        inc di
        cmp di, 3d
        jnz ciclo

    imprimir name, 1100b
    imprimir valida, 1100b
    imprimir salto, 0d
    jmp inicio

    asignar:
        mov columna, di
endm

limpiarTablero macro
    local limpiar

    xor si, si
    limpiar:
        mov tablero[si], 0d
        inc si
        cmp si, 9d
        jnz limpiar
endm
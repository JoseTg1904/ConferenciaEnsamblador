include macros.asm

.model small
.stack 100h
.data
    nameJugador1 db "Jugador 1$"
    nameJugador2 db "Jugador 2$"
    opcion db " deseas jugar con X o O [1/2]: $"
    ingresa db " ingresa la fila de tu eleccion: $"
    ingresa2 db " ingresa la columna de tu eleccion: $"
    valida db " ingresa un valor valido$"
    salir db "Desea volver a jugar [y/n]: $"
    mensajeTablero db "Tablero de muestra: $"
    mensajeOcupada db "casilla ocupada, intenta otra vez$"
    cabecerasC db "123$"
    cabecerasF db "abc$"
    valores db " XO$"
    lineas db "|-$"
    individual db " $"
    mensajeGanador db "El ganador es el: $"
    mensajePerdedor db "Nadie a podido ganar :c$"
    
    tipoJugador1 db 0
    tipoJugador2 db 0
    tipoValor db 0
    color db 0
    iteradorI dw 0
    iteradorJ dw 0
    iteradorK dw 0
    banderaGanador db 0
    extra db 0
    ocupadas db 0
    fila dw 0
    columna dw 0
    ganadorB db 0
    indice dw 0
    tablero db 0, 0, 0, 0, 0, 0, 0, 0, 0, "$"
    bufferTeclado db 50 dup("$"), "$"
    espacio db " $"
    salto db 0ah, "$"
.code
    start:
        main proc
            limpiarTerminal
            imprimir nameJugador1, 15d
            imprimir opcion, 15d
            leerHastaEnter bufferTeclado
            limpiarTablero
            mov banderaGanador, 0d
            mov ocupadas, 0d

            cmp bufferTeclado[0], "1"
            jz desicion1
            jmp desicion2

            desicion1:
                mov tipoJugador1, 1d
                mov tipoJugador2, 2d
                jmp tableroM

            desicion2:
                mov tipoJugador1, 2d
                mov tipoJugador2, 1d

            tableroM:
                imprimir salto, 0d
                imprimir mensajeTablero, 15d
                imprimir salto, 0d
                imprimirMatriz
                imprimir salto, 0d
                imprimir salto, 0d
                leerHastaEnter bufferTeclado
                limpiarTerminal

            juego:
                leerFila nameJugador1
                leerColumna nameJugador1

                obtenerIndice fila, columna
                mov di, indice
                mov al, tipoJugador1
                cmp tablero[di], 0d
                jnz ocupada
                mov tablero[di], al

                imprimir salto, 0d
                imprimirMatriz
                imprimir salto, 0d
                imprimir salto, 0d
                validarTablero

                mov al, 1d
                mov ganadorB, al
                cmp banderaGanador, 1d
                jz ganador
                inc ocupadas
                cmp ocupadas, 9d
                jz perdedor

                jmp seguir

                ocupada:
                    imprimir salto, 0d
                    imprimir mensajeOcupada, 10001110b
                    imprimir salto, 0d
                    imprimir salto, 0d
                    jmp juego

                ocupada2:
                    imprimir salto, 0d
                    imprimir mensajeOcupada, 10001110b
                    imprimir salto, 0d
                    imprimir salto, 0d
                    jmp seguir

                ganador:
                    cmp ganadorB, 1d
                    jz ganador1
                    jmp ganador2
                
                ganador1:
                    imprimir mensajeGanador, 10001010b
                    imprimir nameJugador1, 10001010b
                    jmp repetir

                ganador2:
                    imprimir mensajeGanador, 10001010b
                    imprimir nameJugador2, 10001010b
                    jmp repetir

                perdedor:
                    imprimir mensajePerdedor, 1100b

                repetir:
                    imprimir salto, 0d
                    imprimir salto, 0d
                    imprimir salir, 15d
                    leerHastaEnter bufferTeclado
                    cmp bufferTeclado[0], "y"
                    jz start
                    .exit

                seguir:
                    leerFila nameJugador2
                    leerColumna nameJugador2

                    obtenerIndice fila, columna
                    mov di, indice
                    mov al, tipoJugador2
                    cmp tablero[di], 0d
                    jnz ocupada2
                    mov tablero[di], al

                    imprimir salto, 0d
                    imprimirMatriz
                    imprimir salto, 0d
                    imprimir salto, 0d
                    validarTablero

                    mov al, 2d
                    mov ganadorB, al
                    cmp banderaGanador, 1d
                    jz ganador
                    inc ocupadas
                    cmp ocupadas, 9d
                    jz perdedor

                    jmp juego
        main endp
    end start
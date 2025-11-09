; ========================================================================
; VentanaBasica.asm
; Ejemplo básico de una ventana Win32 en ensamblador x86 (32 bits)
; 
; Descripción:
;   Crea una ventana simple sin controles. Es la base para cualquier
;   aplicación GUI en Windows.
;
; Autor: Ejemplos GUI x86
; Arquitectura: x86 (32 bits)
; ========================================================================

.386                        ; Usar conjunto de instrucciones 80386
.model flat, stdcall        ; Modelo de memoria plano, convención stdcall
option casemap:none         ; Distinguir mayúsculas/minúsculas

; ========================================================================
; Prototipos de funciones de Windows API
; ========================================================================
ExitProcess proto stdcall :DWORD
GetModuleHandleA proto stdcall :DWORD
RegisterClassExA proto stdcall :DWORD
CreateWindowExA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ShowWindow proto stdcall :DWORD,:DWORD
UpdateWindow proto stdcall :DWORD
GetMessageA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
TranslateMessage proto stdcall :DWORD
DispatchMessageA proto stdcall :DWORD
DefWindowProcA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
PostQuitMessage proto stdcall :DWORD
DestroyWindow proto stdcall :DWORD
LoadIconA proto stdcall :DWORD,:DWORD
LoadCursorA proto stdcall :DWORD,:DWORD

; ========================================================================
; Incluir bibliotecas necesarias
; ========================================================================
includelib kernel32.lib     ; Funciones del sistema (ExitProcess, GetModuleHandle)
includelib user32.lib       ; Funciones de interfaz de usuario (ventanas, mensajes)

; ========================================================================
; Constantes
; ========================================================================
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h    ; Estilo: ventana con borde, título, botones
WS_VISIBLE          equ 10000000h   ; Ventana visible al crearse
CW_USEDEFAULT       equ 80000000h   ; Usar posición/tamaño por defecto
CS_HREDRAW          equ 2h          ; Redibujar si cambia el ancho
CS_VREDRAW          equ 1h          ; Redibujar si cambia el alto
COLOR_WINDOW        equ 5           ; Color de fondo: blanco
IDI_APPLICATION     equ 32512       ; Ícono por defecto de aplicación
IDC_ARROW           equ 32512       ; Cursor flecha estándar
SW_SHOWNORMAL       equ 1           ; Mostrar ventana normalmente

; Mensajes de Windows
WM_CLOSE            equ 10h         ; Usuario quiere cerrar la ventana
WM_DESTROY          equ 2h          ; Ventana está siendo destruida

; ========================================================================
; Estructura MSG (mensaje de Windows)
; ========================================================================
MSG STRUCT
    hwnd    DWORD ?         ; Handle de la ventana
    message DWORD ?         ; Código del mensaje
    wParam  DWORD ?         ; Parámetro adicional 1
    lParam  DWORD ?         ; Parámetro adicional 2
    time    DWORD ?         ; Tiempo en que se generó
    pt      QWORD ?         ; Posición del cursor (POINT: 2 DWORDs)
MSG ENDS

; ========================================================================
; Estructura WNDCLASSEX (define propiedades de la clase de ventana)
; ========================================================================
WNDCLASSEX STRUCT
    cbSize          DWORD ?     ; Tamaño de esta estructura
    style           DWORD ?     ; Estilos de la clase (CS_*)
    lpfnWndProc     DWORD ?     ; Puntero a la función WndProc
    cbClsExtra      DWORD ?     ; Bytes extra para la clase
    cbWndExtra      DWORD ?     ; Bytes extra para cada ventana
    hInstance       DWORD ?     ; Handle de la instancia de la aplicación
    hIcon           DWORD ?     ; Handle del ícono grande
    hCursor         DWORD ?     ; Handle del cursor
    hbrBackground   DWORD ?     ; Handle del brush para el fondo
    lpszMenuName    DWORD ?     ; Nombre del menú (NULL si no hay)
    lpszClassName   DWORD ?     ; Nombre de la clase de ventana
    hIconSm         DWORD ?     ; Handle del ícono pequeño
WNDCLASSEX ENDS

; ========================================================================
; Sección de datos
; ========================================================================
.data
    ; Nombre de la clase de ventana (debe ser único)
    szClassName db "VentanaBasicaClass",0
    
    ; Título de la ventana
    szWindowName db "Mi Primera Ventana",0

; ========================================================================
; Sección de datos no inicializados
; ========================================================================
.data?
    hInstance   DWORD ?     ; Handle de la instancia de la aplicación
    hWnd        DWORD ?     ; Handle de la ventana principal
    msg         MSG <>      ; Estructura para mensajes
    wc          WNDCLASSEX <> ; Estructura de clase de ventana

; ========================================================================
; Sección de código
; ========================================================================
.code

; ========================================================================
; Procedimiento principal (punto de entrada)
; ========================================================================
start:
    ; ----------------------------------------------------------------
    ; 1. Obtener el handle de la instancia actual
    ; ----------------------------------------------------------------
    invoke GetModuleHandleA, NULL   ; NULL = módulo actual
    mov hInstance, eax              ; Guardar handle en variable global
    
    ; ----------------------------------------------------------------
    ; 2. Llenar la estructura WNDCLASSEX
    ; ----------------------------------------------------------------
    mov wc.cbSize, sizeof WNDCLASSEX            ; Tamaño de la estructura
    mov wc.style, CS_HREDRAW or CS_VREDRAW      ; Redibujar si cambia tamaño
    mov wc.lpfnWndProc, offset WndProc          ; Dirección de WndProc
    mov wc.cbClsExtra, 0                        ; Sin bytes extra para clase
    mov wc.cbWndExtra, 0                        ; Sin bytes extra por ventana
    mov eax, hInstance
    mov wc.hInstance, eax                       ; Handle de instancia
    
    ; Cargar ícono y cursor estándar
    invoke LoadIconA, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax                         ; Mismo ícono para pequeño
    invoke LoadCursorA, NULL, IDC_ARROW
    mov wc.hCursor, eax
    
    ; Color de fondo (gris claro)
    mov wc.hbrBackground, COLOR_WINDOW+1        ; +1 es requerido por Windows
    mov wc.lpszMenuName, NULL                   ; Sin menú
    mov wc.lpszClassName, offset szClassName    ; Nombre de la clase
    
    ; ----------------------------------------------------------------
    ; 3. Registrar la clase de ventana
    ; ----------------------------------------------------------------
    invoke RegisterClassExA, addr wc
    .if eax == 0
        ; Error al registrar la clase
        invoke ExitProcess, 1
    .endif
    
    ; ----------------------------------------------------------------
    ; 4. Crear la ventana
    ; ----------------------------------------------------------------
    invoke CreateWindowExA,
        0,                              ; Estilos extendidos (ninguno)
        addr szClassName,               ; Nombre de la clase
        addr szWindowName,              ; Título de la ventana
        WS_OVERLAPPEDWINDOW or WS_VISIBLE, ; Estilos de la ventana
        CW_USEDEFAULT,                  ; Posición X (automática)
        CW_USEDEFAULT,                  ; Posición Y (automática)
        640,                            ; Ancho en píxeles
        480,                            ; Alto en píxeles
        NULL,                           ; Handle de ventana padre (ninguna)
        NULL,                           ; Handle de menú (ninguno)
        hInstance,                      ; Handle de instancia
        NULL                            ; Parámetro de creación (ninguno)
    
    mov hWnd, eax                       ; Guardar handle de la ventana
    
    .if eax == 0
        ; Error al crear la ventana
        invoke ExitProcess, 2
    .endif
    
    ; ----------------------------------------------------------------
    ; 5. Mostrar y actualizar la ventana
    ; ----------------------------------------------------------------
    invoke ShowWindow, hWnd, SW_SHOWNORMAL  ; Mostrar ventana
    invoke UpdateWindow, hWnd                ; Forzar redibujado inmediato
    
    ; ----------------------------------------------------------------
    ; 6. Bucle de mensajes (mantiene la aplicación ejecutándose)
    ; ----------------------------------------------------------------
MessageLoop:
    ; Obtener siguiente mensaje de la cola
    invoke GetMessageA, addr msg, NULL, 0, 0
    
    .if eax == 0
        ; GetMessage retorna 0 cuando recibe WM_QUIT
        jmp EndProgram
    .endif
    
    ; Traducir teclas virtuales
    invoke TranslateMessage, addr msg
    
    ; Enviar mensaje al procedimiento de ventana (WndProc)
    invoke DispatchMessageA, addr msg
    
    ; Repetir el bucle
    jmp MessageLoop

EndProgram:
    ; Salir del programa con código de retorno
    invoke ExitProcess, msg.wParam

; ========================================================================
; WndProc - Procedimiento de ventana (maneja mensajes)
; ========================================================================
; Parámetros:
;   hWnd    - Handle de la ventana
;   uMsg    - Código del mensaje
;   wParam  - Parámetro adicional (depende del mensaje)
;   lParam  - Parámetro adicional (depende del mensaje)
; Retorna:
;   EAX - Resultado del procesamiento (depende del mensaje)
; ========================================================================
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    
    ; ----------------------------------------------------------------
    ; Procesar mensaje WM_CLOSE (usuario quiere cerrar)
    ; ----------------------------------------------------------------
    .if uMsg == WM_CLOSE
        ; Destruir la ventana
        invoke DestroyWindow, hWnd
        xor eax, eax        ; Retornar 0 (mensaje procesado)
        ret
    
    ; ----------------------------------------------------------------
    ; Procesar mensaje WM_DESTROY (ventana destruida)
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_DESTROY
        ; Publicar mensaje WM_QUIT para terminar el bucle
        invoke PostQuitMessage, 0
        xor eax, eax        ; Retornar 0 (mensaje procesado)
        ret
    .endif
    
    ; ----------------------------------------------------------------
    ; Procesamiento por defecto para mensajes no manejados
    ; ----------------------------------------------------------------
    invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
    
WndProc endp

; ========================================================================
; Fin del programa
; ========================================================================
end start

; ========================================================================
; CheckBoxEjemplo.asm - Ejemplo de varios checkboxes y lectura de estado
; ========================================================================

.386
.model flat, stdcall
option casemap:none

; Prototipos
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
LoadIconA proto stdcall :DWORD,:DWORD
LoadCursorA proto stdcall :DWORD,:DWORD
SendMessageA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
SetWindowTextA proto stdcall :DWORD,:DWORD

includelib kernel32.lib
includelib user32.lib

; Constantes generales
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h
WS_TABSTOP          equ 00010000h
WS_BORDER           equ 00800000h
CW_USEDEFAULT       equ 80000000h
CS_HREDRAW          equ 2h
CS_VREDRAW          equ 1h
COLOR_WINDOW        equ 5
IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512
SW_SHOWNORMAL       equ 1

WM_CREATE           equ 1h
WM_COMMAND          equ 111h
WM_DESTROY          equ 2h

; Estilos y mensajes para checkbox
BS_CHECKBOX         equ 2h
BS_AUTOCHECKBOX     equ 3h
BS_3STATE           equ 5h
BS_AUTO3STATE       equ 6h
BM_GETCHECK         equ 0F0h
BM_SETCHECK         equ 0F1h
BST_UNCHECKED       equ 0
BST_CHECKED         equ 1
BST_INDETERMINATE   equ 2

; IDs
ID_CHK_OPC1         equ 5001
ID_CHK_OPC2         equ 5002
ID_CHK_3STATE       equ 5003
ID_BTN_LEER         equ 5004
ID_LBL_ESTADOS      equ 5005

; Estructuras
MSG STRUCT
    hwnd    DWORD ?
    message DWORD ?
    wParam  DWORD ?
    lParam  DWORD ?
    time    DWORD ?
    pt      QWORD ?
MSG ENDS

WNDCLASSEX STRUCT
    cbSize          DWORD ?
    style           DWORD ?
    lpfnWndProc     DWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance       DWORD ?
    hIcon           DWORD ?
    hCursor         DWORD ?
    hbrBackground   DWORD ?
    lpszMenuName    DWORD ?
    lpszClassName   DWORD ?
    hIconSm         DWORD ?
WNDCLASSEX ENDS

.data
    szClassName     db "CheckBoxEjClass",0
    szWindowName    db "Ejemplo de CheckBox",0
    szButtonClass   db "BUTTON",0
    szStaticClass   db "STATIC",0

    szChk1Text      db "Opción 1 (Auto)",0
    szChk2Text      db "Opción 2 (Auto)",0
    szChk3Text      db "3-State Manual",0
    szBtnLeer       db "Leer estados",0
    szLblEstados    db "Estados: ",0

    szEstadoFmt     db "Estados: C1=%c  C2=%c  C3=%c",0

    szEstadoBuffer  db 64 dup(0)

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hChk1           DWORD ?
    hChk2           DWORD ?
    hChk3           DWORD ?
    hBtnLeer        DWORD ?
    hLblEstados     DWORD ?
    msg             MSG <>
    wc              WNDCLASSEX <>

.code
start:
    invoke GetModuleHandleA, NULL
    mov hInstance, eax

    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInstance
    mov wc.hInstance, eax
    invoke LoadIconA, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursorA, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset szClassName

    invoke RegisterClassExA, addr wc
    test eax, eax
    jz exit_error

    invoke CreateWindowExA,
        0, addr szClassName, addr szWindowName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, 520, 240,
        NULL, NULL, hInstance, NULL
    mov hWnd, eax
    test eax, eax
    jz exit_error

    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd

MessageLoop:
    invoke GetMessageA, addr msg, NULL, 0, 0
    test eax, eax
    jz EndProgram
    invoke TranslateMessage, addr msg
    invoke DispatchMessageA, addr msg
    jmp MessageLoop

EndProgram:
    invoke ExitProcess, msg.wParam

exit_error:
    invoke ExitProcess, 1

; Helper para escribir char en buffer por índice
; ECX = índice, AL = char
WriteChar proc uses edi ecx eax
    mov edi, offset szEstadoBuffer
    add edi, ecx
    mov [edi], al
    ret
WriteChar endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        ; CheckBox 1 - automático
        invoke CreateWindowExA, 0, addr szButtonClass, addr szChk1Text,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX,
            20, 20, 180, 22,
            hWnd, ID_CHK_OPC1, hInstance, NULL
        mov hChk1, eax

        ; CheckBox 2 - automático
        invoke CreateWindowExA, 0, addr szButtonClass, addr szChk2Text,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX,
            20, 50, 180, 22,
            hWnd, ID_CHK_OPC2, hInstance, NULL
        mov hChk2, eax

        ; CheckBox 3 - 3-state manual
        invoke CreateWindowExA, 0, addr szButtonClass, addr szChk3Text,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_3STATE,
            20, 80, 180, 22,
            hWnd, ID_CHK_3STATE, hInstance, NULL
        mov hChk3, eax
        ; Inicial: indeterminado
        invoke SendMessageA, hChk3, BM_SETCHECK, BST_INDETERMINATE, 0

        ; Label estados
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLblEstados,
            WS_CHILD or WS_VISIBLE,
            20, 120, 320, 24,
            hWnd, ID_LBL_ESTADOS, hInstance, NULL
        mov hLblEstados, eax

        ; Botón leer
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnLeer,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            20, 160, 120, 28,
            hWnd, ID_BTN_LEER, hInstance, NULL
        mov hBtnLeer, eax

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh

        .if eax == ID_BTN_LEER
            ; Leer estados
            invoke SendMessageA, hChk1, BM_GETCHECK, 0, 0
            mov ecx, eax
            ; Convertir a caracter
            cmp ecx, BST_CHECKED
            je chk1_checked
            cmp ecx, BST_INDETERMINATE
            je chk1_indet
            mov al, '0'
            jmp store_chk1
        chk1_checked:
            mov al, '1'
            jmp store_chk1
        chk1_indet:
            mov al, 'X'
        store_chk1:
            ; posición 11 dentro de la cadena base "Estados: C1=%c  C2=%c  C3=%c"
            mov ecx, 11
            call WriteChar

            invoke SendMessageA, hChk2, BM_GETCHECK, 0, 0
            mov ecx, eax
            cmp ecx, BST_CHECKED
            je chk2_checked
            cmp ecx, BST_INDETERMINATE
            je chk2_indet
            mov al, '0'
            jmp store_chk2
        chk2_checked:
            mov al, '1'
            jmp store_chk2
        chk2_indet:
            mov al, 'X'
        store_chk2:
            mov ecx, 19
            call WriteChar

            invoke SendMessageA, hChk3, BM_GETCHECK, 0, 0
            mov ecx, eax
            cmp ecx, BST_CHECKED
            je chk3_checked
            cmp ecx, BST_INDETERMINATE
            je chk3_indet
            mov al, '0'
            jmp store_chk3
        chk3_checked:
            mov al, '1'
            jmp store_chk3
        chk3_indet:
            mov al, 'X'
        store_chk3:
            mov ecx, 27
            call WriteChar

            ; Copiar plantilla base si buffer vacío
            ; Inicializar si primera vez
            mov al, [szEstadoBuffer]
            cmp al, 0
            jne skip_init_template
            ; Copiar la plantilla inicial
            mov esi, offset szEstadoFmt
            mov edi, offset szEstadoBuffer
        copy_loop:
            mov al, [esi]
            mov [edi], al
            inc esi
            inc edi
            test al, al
            jnz copy_loop
        skip_init_template:

            ; Escribir en label
            invoke SetWindowTextA, hLblEstados, offset szEstadoBuffer
        .endif

        ; Click manual en 3-state para rotar estado
        .if eax == ID_CHK_3STATE
            invoke SendMessageA, hChk3, BM_GETCHECK, 0, 0
            mov ecx, eax
            cmp ecx, BST_UNCHECKED
            je set_chk_checked
            cmp ecx, BST_CHECKED
            je set_chk_indet
            ; else indeterminate -> unchecked
            invoke SendMessageA, hChk3, BM_SETCHECK, BST_UNCHECKED, 0
            jmp end_cmd
        set_chk_checked:
            invoke SendMessageA, hChk3, BM_SETCHECK, BST_CHECKED, 0
            jmp end_cmd
        set_chk_indet:
            invoke SendMessageA, hChk3, BM_SETCHECK, BST_INDETERMINATE, 0
        end_cmd:
        .endif

        xor eax, eax
        ret

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .endif

    invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
WndProc endp

end start

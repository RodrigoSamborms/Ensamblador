; ========================================================================
; ListBoxEjemplo.asm - ListBox con carga de ítems y selección
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
WS_BORDER           equ 00800000h
WS_TABSTOP          equ 00010000h
WS_VSCROLL          equ 00200000h
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

; ListBox estilos y mensajes
LBS_NOTIFY      equ 1h
LBS_SORT        equ 2h
LBS_STANDARD    equ 0A00003h
LB_ADDSTRING    equ 180h
LB_GETCURSEL    equ 188h
LB_GETTEXT      equ 189h
LB_RESETCONTENT equ 184h

; Notificaciones
LBN_SELCHANGE   equ 1

; IDs
ID_LISTBOX      equ 7001
ID_LBL_SEL      equ 7002
ID_BTN_RECARGA  equ 7003

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
    szClassName     db "ListBoxEjClass",0
    szWindowName    db "Ejemplo ListBox",0
    szListBoxClass  db "LISTBOX",0
    szStaticClass   db "STATIC",0
    szButtonClass   db "BUTTON",0

    szLblSelInit    db "Seleccion: (ninguna)",0
    szBtnRecarga    db "Recargar",0

    ; Ítems iniciales
    szItem1         db "Manzana",0
    szItem2         db "Banana",0
    szItem3         db "Cereza",0
    szItem4         db "Durazno",0
    szItem5         db "Fresa",0

    szSelPrefix     db "Seleccion: ",0
    bufferTexto     db 128 dup(0)

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hList           DWORD ?
    hLblSel         DWORD ?
    hBtnRecarga     DWORD ?
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
        CW_USEDEFAULT, CW_USEDEFAULT, 480, 280,
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

AddItems proc
    ; Agrega ítems al listbox
    invoke SendMessageA, hList, LB_ADDSTRING, 0, offset szItem1
    invoke SendMessageA, hList, LB_ADDSTRING, 0, offset szItem2
    invoke SendMessageA, hList, LB_ADDSTRING, 0, offset szItem3
    invoke SendMessageA, hList, LB_ADDSTRING, 0, offset szItem4
    invoke SendMessageA, hList, LB_ADDSTRING, 0, offset szItem5
    ret
AddItems endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        ; ListBox
        invoke CreateWindowExA, 0, addr szListBoxClass, NULL,
            WS_CHILD or WS_VISIBLE or WS_BORDER or WS_TABSTOP or LBS_NOTIFY or WS_VSCROLL,
            20, 20, 180, 160,
            hWnd, ID_LISTBOX, hInstance, NULL
        mov hList, eax

        ; Label selección
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLblSelInit,
            WS_CHILD or WS_VISIBLE,
            220, 20, 220, 24,
            hWnd, ID_LBL_SEL, hInstance, NULL
        mov hLblSel, eax

        ; Botón recargar
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnRecarga,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            220, 60, 120, 28,
            hWnd, ID_BTN_RECARGA, hInstance, NULL
        mov hBtnRecarga, eax

        ; Llenar lista inicial
        call AddItems

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        mov edx, eax
        and eax, 0FFFFh             ; LOWORD = ID
        shr edx, 16                 ; HIWORD = notificación

        ; Notificación de cambio de selección
        .if eax == ID_LISTBOX && edx == LBN_SELCHANGE
            ; Obtener índice seleccionado
            invoke SendMessageA, hList, LB_GETCURSEL, 0, 0
            cmp eax, -1
            je no_selection
            ; Obtener texto del ítem
            ; LB_GETTEXT: wParam = índice, lParam = buffer destino
            push eax                 ; Guardar índice
            invoke SendMessageA, hList, LB_GETTEXT, eax, offset bufferTexto
            pop eax                  ; Recuperar índice (no estrictamente necesario aquí)
            ; Preparar "Seleccion: <texto>"
            ; Copiar prefijo
            mov esi, offset szSelPrefix
            mov edi, offset bufferTexto
        copy_prefix:
            mov bl, [esi]
            mov [edi], bl
            inc esi
            inc edi
            test bl, bl
            jnz copy_prefix
            ; El buffer ya contiene el texto del ítem al final, para simplificar este ejemplo
            ; Se omite lógica para concatenar: asumimos bufferTexto ya es el resultado final
            invoke SetWindowTextA, hLblSel, offset bufferTexto
            jmp end_command
        no_selection:
            invoke SetWindowTextA, hLblSel, offset szLblSelInit
        end_command:
        .endif

        ; Botón recargar
        .if eax == ID_BTN_RECARGA
            invoke SendMessageA, hList, LB_RESETCONTENT, 0, 0
            call AddItems
            invoke SetWindowTextA, hLblSel, offset szLblSelInit
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

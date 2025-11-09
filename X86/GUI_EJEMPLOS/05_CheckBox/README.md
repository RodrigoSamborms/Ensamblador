# CheckBox (BUTTON / BS_CHECKBOX)

## Introducción
Las casillas de verificación permiten seleccionar opciones independientes (on/off). Se implementan usando la clase `BUTTON` con estilos de tipo checkbox.

## Objetivos
- Crear uno o varios checkboxes
- Consultar y cambiar su estado (marcado / desmarcado)
- Usar mensajes `BM_GETCHECK` y `BM_SETCHECK`
- Manejar notificaciones vía `WM_COMMAND`

## Estilos principales
| Estilo | Valor | Descripción |
|--------|-------|-------------|
| BS_CHECKBOX | 0x00000002 | Casilla básica manual |
| BS_AUTOCHECKBOX | 0x00000003 | Alterna automáticamente al clic |
| BS_3STATE | 0x00000005 | Tres estados (INDETERMINATE) |
| BS_AUTO3STATE | 0x00000006 | Tres estados automático |

### Estados (para BM_GETCHECK / BM_SETCHECK)
| Constante | Valor | Significado |
|-----------|-------|-------------|
| BST_UNCHECKED | 0x0000 | No marcado |
| BST_CHECKED | 0x0001 | Marcado |
| BST_INDETERMINATE | 0x0002 | Estado intermedio (3-state) |

## Crear un CheckBox
```assembly
invoke CreateWindowExA,
    0,
    addr szButtonClass,         ; "BUTTON"
    addr szChkTexto,            ; Texto visible
    WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX,
    20, 20, 160, 22,
    hWnd,
    ID_CHK_1,
    hInstance,
    NULL
mov hChk1, eax
```

## Obtener estado
```assembly
BM_GETCHECK     equ 0x00F0
invoke SendMessageA, hChk1, BM_GETCHECK, 0, 0 ; EAX = estado
```

## Modificar estado
```assembly
BM_SETCHECK     equ 0x00F1
invoke SendMessageA, hChk1, BM_SETCHECK, BST_CHECKED, 0 ; Marcar
invoke SendMessageA, hChk1, BM_SETCHECK, BST_UNCHECKED, 0 ; Desmarcar
```

## Evento de clic
El checkbox envía `WM_COMMAND` con:
- LOWORD(wParam) = ID del control
- HIWORD(wParam) = código de notificación (generalmente BN_CLICKED)

```assembly
.elseif uMsg == WM_COMMAND
    mov eax, wParam
    and eax, 0FFFFh
    .if eax == ID_CHK_1
        ; Consultar estado y actualizar un label
    .endif
```

## Ejemplo completo
Ver `CheckBoxEjemploWindow.asm` para:
- Dos checkboxes automáticos
- Un checkbox 3-state manual
- Botón para leer estados y mostrarlos

## Ejercicios
1. Crear un checkbox que habilite/deshabilite un TextBox.
2. Usar un checkbox 3-state para representar: Apagado / Encendido / Modo automático.
3. Al desmarcar cierta casilla, limpiar el contenido de otro control.

## Referencias rápidas
```assembly
BS_CHECKBOX         equ 2h
BS_AUTOCHECKBOX     equ 3h
BS_3STATE           equ 5h
BS_AUTO3STATE       equ 6h
BM_GETCHECK         equ 0F0h
BM_SETCHECK         equ 0F1h
BST_UNCHECKED       equ 0
BST_CHECKED         equ 1
BST_INDETERMINATE   equ 2
```

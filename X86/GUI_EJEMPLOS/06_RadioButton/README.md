# RadioButton (BUTTON / BS_RADIOBUTTON)

## Introducción
Los radio buttons permiten seleccionar **una sola opción dentro de un grupo**. Se basan en la clase `BUTTON` con estilos de tipo radio.

## Objetivos
- Agrupar radio buttons para exclusión mutua
- Detectar selección en `WM_COMMAND`
- Obtener el radio seleccionado

## Estilos
| Estilo | Valor | Descripción |
|--------|-------|-------------|
| BS_RADIOBUTTON | 0x00000004 | Radio básico manual |
| BS_AUTORADIOBUTTON | 0x00000009 | Radio auto-exclusivo |

### Estilos adicionales útiles
- `WS_GROUP`: Marca inicio de un grupo (el primer radio del conjunto)
- `WS_TABSTOP`: Permite foco con Tab (solo el primero normalmente)

## Crear un grupo de radios
```assembly
; Primer radio: inicio del grupo (WS_GROUP | WS_TABSTOP)
invoke CreateWindowExA, 0, addr szButtonClass, addr szR1,
    WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or BS_AUTORADIOBUTTON,
    20, 20, 160, 20,
    hWnd, ID_RB_1, hInstance, NULL

; Radios siguientes sin WS_GROUP
invoke CreateWindowExA, 0, addr szButtonClass, addr szR2,
    WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
    20, 45, 160, 20,
    hWnd, ID_RB_2, hInstance, NULL
```

## Obtener radio seleccionado
Mensaje `BM_GETCHECK` también funciona con radios:
```assembly
BM_GETCHECK equ 0x00F0
invoke SendMessageA, hRb1, BM_GETCHECK, 0, 0 ; Si devuelve 1 => seleccionado
```

## Manejo en WM_COMMAND
```assembly
.elseif uMsg == WM_COMMAND
    mov eax, wParam
    and eax, 0FFFFh ; LOWORD = ID
    .if eax == ID_RB_1
        ; Radio 1 seleccionado
    .elseif eax == ID_RB_2
        ; Radio 2 seleccionado
    .endif
```

## Ejemplo completo
Ver `RadioButtonEjemploWindow.asm` para:
- Tres radios (Rojo, Verde, Azul)
- Un label que muestra la selección actual

## Ejercicios
1. Crear grupo de dificultad: Fácil / Medio / Difícil.
2. Usar radios para elegir modo de cálculo y aplicar en un botón.
3. Cambiar color de fondo según selección (requiere GDI / WM_CTLCOLORSTATIC avanzado).

## Referencia rápida
```assembly
BS_RADIOBUTTON      equ 4h
BS_AUTORADIOBUTTON  equ 9h
BM_GETCHECK         equ 0F0h
BM_SETCHECK         equ 0F1h
BST_UNCHECKED       equ 0
BST_CHECKED         equ 1
WS_GROUP            equ 20000h
WS_TABSTOP          equ 10000h
```

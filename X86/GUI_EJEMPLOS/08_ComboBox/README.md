# ComboBox (COMBOBOX)

## Introducción
El control `COMBOBOX` combina un campo de edición (opcional) con una lista desplegable. Permite seleccionar un ítem o escribir texto (según estilo).

## Objetivos
- Crear un combobox desplegable
- Agregar ítems con `CB_ADDSTRING`
- Obtener selección vía `CB_GETCURSEL` y `CB_GETLBTEXT`
- Manejar notificaciones `CBN_SELCHANGE` y `CBN_EDITCHANGE`

## Estilos comunes
| Estilo | Valor | Descripción |
|--------|-------|-------------|
| CBS_SIMPLE | 0x0001 | Lista siempre visible |
| CBS_DROPDOWN | 0x0002 | Lista desplegable + edición |
| CBS_DROPDOWNLIST | 0x0003 | Desplegable solo selección (sin editar texto) |
| CBS_SORT | 0x0008000 | Orden automático al agregar |

Recomendado para empezar: `CBS_DROPDOWNLIST`.

## Mensajes (SendMessageA)
| Mensaje | Valor | Descripción |
|---------|-------|-------------|
| CB_ADDSTRING | 0x0143 | Agrega un ítem de texto |
| CB_GETCURSEL | 0x0147 | Índice seleccionado |
| CB_GETLBTEXT | 0x0148 | Obtiene texto de índice |
| CB_RESETCONTENT | 0x014B | Limpia ítems |

## Notificaciones (WM_COMMAND)
| Notificación | Valor | Cuándo |
|--------------|-------|--------|
| CBN_SELCHANGE | 1 | Cambió la selección |
| CBN_EDITCHANGE | 5 | Texto editado (CBS_DROPDOWN) |

HIWORD(wParam) = notificación, LOWORD(wParam) = ID del combobox.

## Crear un ComboBox
```assembly
invoke CreateWindowExA, 0, addr szComboClass, NULL,
    WS_CHILD or WS_VISIBLE or WS_TABSTOP or CBS_DROPDOWNLIST,
    20, 20, 200, 140, ; Altura incluye lista desplegable
    hWnd, ID_CBO_1, hInstance, NULL
mov hCombo, eax
```

## Agregar ítems
```assembly
CB_ADDSTRING equ 143h
invoke SendMessageA, hCombo, CB_ADDSTRING, 0, addr szItem1
invoke SendMessageA, hCombo, CB_ADDSTRING, 0, addr szItem2
```

## Obtener selección
```assembly
CB_GETCURSEL equ 147h
invoke SendMessageA, hCombo, CB_GETCURSEL, 0, 0 ; EAX = índice o -1
```

## Obtener texto del índice
```assembly
CB_GETLBTEXT equ 148h
invoke SendMessageA, hCombo, CB_GETLBTEXT, eax, addr bufferTexto
```

## Ejemplo
Ver `ComboBoxEjemploWindow.asm` para:
- Lista de frutas
- Label que muestra selección actual
- Botón para recargar y resetear

## Compilación
```powershell
cd .\X86\GUI_EJEMPLOS\08_ComboBox
..\..\build.ps1 ComboBoxEjemploWindow.asm -OutDir ..\build
..\build\ComboBoxEjemplo.exe
```

## Ejercicios
1. ComboBox de países y mostrar código ISO al seleccionar.
2. ComboBox editable con autocompletado (avanzado, requiere lógica manual).
3. Al cambiar selección, cargar descripción en un TextBox.

## Referencia rápida
```assembly
CBS_SIMPLE          equ 1h
CBS_DROPDOWN        equ 2h
CBS_DROPDOWNLIST    equ 3h
CBS_SORT            equ 8000h
CB_ADDSTRING        equ 143h
CB_GETCURSEL        equ 147h
CB_GETLBTEXT        equ 148h
CB_RESETCONTENT     equ 14Bh
CBN_SELCHANGE       equ 1
CBN_EDITCHANGE      equ 5
```

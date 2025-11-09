# ListBox (LISTBOX)

## Introducción
El control `LISTBOX` muestra una lista de ítems de texto y permite seleccionar uno o varios, según el estilo. Es útil para listas de opciones, archivos, etc.

## Objetivos
- Crear un listbox y llenarlo con ítems
- Manejar la selección usando `WM_COMMAND` y `LBN_SELCHANGE`
- Leer ítems con `LB_GETTEXT` y `LB_GETCURSEL`

## Estilos comunes
| Estilo | Valor | Descripción |
|--------|-------|-------------|
| LBS_NOTIFY | 0x0001 | Envía notificaciones a la ventana padre |
| LBS_SORT | 0x0002 | Ordena automáticamente al insertar |
| LBS_STANDARD | 0x00A00003 | LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER |
| LBS_EXTENDEDSEL | 0x0800 | Selección múltiple extendida |

Usualmente: `LBS_STANDARD` para listas simples.

## Mensajes (SendMessageA)
| Mensaje | Valor | Descripción |
|---------|-------|-------------|
| LB_ADDSTRING | 0x0180 | Agrega un ítem de texto |
| LB_GETCURSEL | 0x0188 | Obtiene índice seleccionado (single select) |
| LB_GETTEXT | 0x0189 | Obtiene texto de un índice |
| LB_RESETCONTENT | 0x0184 | Limpia todos los ítems |

## Notificaciones (WM_COMMAND)
| Notificación | Valor | Cuándo |
|--------------|-------|--------|
| LBN_SELCHANGE | 1 | El usuario cambió la selección |

HIWORD(wParam) = notificación, LOWORD(wParam) = ID del listbox.

## Ejemplo
Ver `ListBoxEjemploWindow.asm` para:
- Llenar la lista con `LB_ADDSTRING`
- Mostrar en un label el ítem seleccionado
- Botón para limpiar y recargar

## Compilación
```powershell
cd .\X86\GUI_EJEMPLOS\07_ListBox
..\..\build.ps1 ListBoxEjemploWindow.asm -OutDir ..\build
..\build\ListBoxEjemplo.exe
```

## Referencia rápida
```assembly
LBS_NOTIFY      equ 1h
LBS_SORT        equ 2h
LBS_STANDARD    equ 0A00003h
LB_ADDSTRING    equ 180h
LB_GETCURSEL    equ 188h
LB_GETTEXT      equ 189h
LBN_SELCHANGE   equ 1
```

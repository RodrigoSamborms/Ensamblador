# TextBox (EDIT)

## Introducción
El control `EDIT` permite entrada de texto por parte del usuario. Se utiliza para campos de texto simples o múltiples líneas.

## Objetivos de Aprendizaje
- Crear controles EDIT de una sola línea y multilínea
- Leer y establecer texto mediante mensajes y funciones
- Gestionar límites de longitud y validación básica

## Conceptos Clave

### Clase de Control
- Nombre: `"EDIT"`
- Tipo: Entrada de texto

### Estilos Comunes (ES_*)
| Estilo | Valor | Descripción |
|--------|-------|-------------|
| ES_LEFT | 0x0000 | Alineación a la izquierda |
| ES_CENTER | 0x0001 | Texto centrado |
| ES_RIGHT | 0x0002 | Alineación derecha |
| ES_MULTILINE | 0x0004 | Permite múltiples líneas |
| ES_PASSWORD | 0x0020 | Muestra * en lugar de caracteres |
| ES_AUTOVSCROLL | 0x0040 | Scroll vertical automático al exceder |
| ES_AUTOHSCROLL | 0x0080 | Scroll horizontal automático |
| ES_READONLY | 0x0800 | Solo lectura |

### Estilos de ventana
Siempre: `WS_CHILD or WS_VISIBLE`
Opcionales:
- `WS_BORDER` para borde
- `WS_TABSTOP` para navegar con Tab
- `WS_VSCROLL` / `WS_HSCROLL` para barras

## Crear un TextBox simple
```assembly
invoke CreateWindowExA,
    0,
    addr szEditClass,       ; "EDIT"
    addr szInitText,        ; Texto inicial
    WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,
    20, 20, 200, 24,
    hWnd,
    ID_EDIT_SIMPLE,
    hInstance,
    NULL
mov hEditSimple, eax
```

## Crear un TextBox multilínea
```assembly
invoke CreateWindowExA,
    0,
    addr szEditClass, NULL,
    WS_CHILD or WS_VISIBLE or WS_BORDER or ES_MULTILINE or ES_AUTOVSCROLL or ES_LEFT or WS_VSCROLL,
    250, 20, 240, 120,
    hWnd,
    ID_EDIT_MULTI,
    hInstance,
    NULL
mov hEditMulti, eax
```

## Obtener texto
### Método 1: GetWindowTextA
```assembly
GetWindowTextA proto stdcall :DWORD,:DWORD,:DWORD
invoke GetWindowTextA, hEditSimple, addr buffer, 128
```

### Método 2: EM_GETLINE / EM_GETSEL (avanzado)
```assembly
SendMessageA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
EM_GETSEL      equ 0x00B0
EM_GETLINE     equ 0x00C4
EM_SETSEL      equ 0x00B1
```

## Establecer texto
```assembly
SetWindowTextA proto stdcall :DWORD,:DWORD
invoke SetWindowTextA, hEditSimple, addr szNuevo
```

## Limitar la longitud
```assembly
EM_LIMITTEXT equ 0x00C5
invoke SendMessageA, hEditSimple, EM_LIMITTEXT, 32, 0 ; Máx 32 chars
```

## Detectar cambios (EN_CHANGE)
El control envía `WM_COMMAND` a la ventana padre:
- HIWORD(wParam) = código de notificación
- LOWORD(wParam) = ID del control

Códigos comunes:
| Código | Valor | Descripción |
|--------|-------|-------------|
| EN_CHANGE | 0x0300 | Texto modificado |
| EN_UPDATE | 0x0400 | Texto se va a actualizar |
| EN_SETFOCUS | 0x0100 | Recibió foco |
| EN_KILLFOCUS | 0x0200 | Perdió foco |
| EN_MAXTEXT | 0x0501 | Se alcanzó longitud máxima |

## Ejemplo completo
Consulta `TextBoxSimpleWindow.asm` y `TextBoxMultilineWindow.asm` para ejemplos prácticos:
- Simple: captura texto y lo muestra en un label
- Multilínea: añade líneas y limita longitud

## Compilación
```powershell
cd .\X86\GUI_EJEMPLOS\04_TextBox
..\..\build.ps1 TextBoxSimpleWindow.asm -OutDir ..\build
..\..\build.ps1 TextBoxMultilineWindow.asm -OutDir ..\build
```

## Ejercicios
1. Crear un campo de contraseña (`ES_PASSWORD`) y validar longitud mínima.
2. Crear un contador de caracteres que se actualice en `EN_CHANGE`.
3. Implementar un botón "Limpiar" que borre el contenido.
4. Guardar el texto multilínea en un archivo (futuro).

## Referencia rápida
```assembly
ES_LEFT         equ 0h
ES_CENTER       equ 1h
ES_RIGHT        equ 2h
ES_MULTILINE    equ 4h
ES_PASSWORD     equ 20h
ES_AUTOVSCROLL  equ 40h
ES_AUTOHSCROLL  equ 80h
ES_READONLY     equ 800h
EM_LIMITTEXT    equ 0C5h
EN_CHANGE       equ 300h
```

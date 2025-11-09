# Label (STATIC)

## Introducción
Las etiquetas de texto (labels) muestran información estática en la interfaz. En Win32 se crean con la clase `STATIC` y no reciben entrada del usuario.

## Objetivos de Aprendizaje
- Crear etiquetas con la clase `STATIC`
- Usar estilos SS_* para alineación y borde
- Actualizar el texto de una etiqueta en tiempo de ejecución

## Conceptos Clave

### Clase de Control
- Nombre: `"STATIC"`
- Tipo: Texto estático, iconos o frames

### Estilos comunes (SS_*)

| Estilo | Valor | Descripción |
|--------|-------|-------------|
| SS_LEFT | 0x00000000 | Alineación a la izquierda |
| SS_CENTER | 0x00000001 | Texto centrado |
| SS_RIGHT | 0x00000002 | Alineación a la derecha |
| SS_SIMPLE | 0x0000000B | Texto simple (sin notificaciones) |
| SS_SUNKEN | 0x00001000 | Apariencia hundida (bisel) |
| SS_BLACKFRAME | 0x00000007 | Marco negro |

### Estilos de ventana
Usa siempre: `WS_CHILD or WS_VISIBLE`

Opcionales:
- `WS_GROUP` para iniciar un grupo de tabulación
- `WS_TABSTOP` (no recomendado en labels, no son focuseables)

## Crear una etiqueta

```assembly
invoke CreateWindowExA,
    0,
    addr szStaticClass,      ; "STATIC"
    addr szLabelText,        ; Texto inicial
    WS_CHILD or WS_VISIBLE or SS_LEFT,
    10, 10, 200, 20,         ; x, y, ancho, alto
    hWnd,                    ; ventana padre
    1001,                    ; ID (no crítico si no se maneja)
    hInstance,
    NULL
```

## Actualizar el texto (SetWindowTextA)

```assembly
SetWindowTextA proto stdcall :DWORD, :DWORD

invoke SetWindowTextA, hLabel, addr szNuevoTexto
```

## Ejemplo completo
Consulta `LabelEjemploWindow.asm` para ver varias etiquetas con estilos distintos y actualización dinámica.

## Compilación

```powershell
cd .\X86\GUI_EJEMPLOS\03_Label
..\..\build.ps1 LabelEjemploWindow.asm -OutDir ..\build
..\build\LabelEjemploWindow.exe
```

## Ejercicios
1. Crea tres labels alineados (izq/centro/der) en la misma fila.
2. Cambia el texto de un label al presionar un botón (usa `WM_COMMAND`).
3. Muestra un valor numérico formateado en un label.

## Referencia rápida

```assembly
SS_LEFT         equ 0h
SS_CENTER       equ 1h
SS_RIGHT        equ 2h
SS_SIMPLE       equ 0Bh
SS_SUNKEN       equ 1000h
SS_BLACKFRAME   equ 7h
```

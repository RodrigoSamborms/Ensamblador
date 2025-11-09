# Botón (BUTTON)

## Introducción
Los botones son controles interactivos que permiten al usuario ejecutar acciones. Son los controles más comunes en aplicaciones GUI.

## Objetivos de Aprendizaje
- Crear botones usando la clase "BUTTON"
- Manejar clics de botón mediante WM_COMMAND
- Trabajar con identificadores de controles (IDs)
- Gestionar múltiples botones en una ventana

## Conceptos Clave

### Clase de Control
- **Nombre de clase**: `"BUTTON"`
- **Tipo**: Control predefinido de Windows
- **Padre**: Debe tener una ventana padre

### Estilos Comunes (BS_*)

| Estilo | Valor | Descripción |
|--------|-------|-------------|
| BS_PUSHBUTTON | 0x00000000 | Botón estándar (default) |
| BS_DEFPUSHBUTTON | 0x00000001 | Botón por defecto (más grueso) |
| BS_CHECKBOX | 0x00000002 | Casilla de verificación |
| BS_AUTOCHECKBOX | 0x00000003 | Casilla automática |
| BS_RADIOBUTTON | 0x00000004 | Botón de radio |
| BS_AUTORADIOBUTTON | 0x00000009 | Botón de radio automático |
| BS_FLAT | 0x00008000 | Apariencia plana |

### Estilos de Ventana para Botones

Los botones necesitan ciertos estilos para funcionar correctamente:

```assembly
WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
```

- **WS_CHILD**: Indica que es control hijo de una ventana
- **WS_VISIBLE**: Visible desde su creación
- **BS_PUSHBUTTON**: Estilo específico del botón

## Crear un Botón

### Sintaxis de CreateWindowExA para Botones

```assembly
invoke CreateWindowExA,
    0,                      ; dwExStyle (estilos extendidos)
    addr szButtonClass,     ; "BUTTON"
    addr szButtonText,      ; Texto del botón
    WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, ; Estilos
    10,                     ; x (posición horizontal)
    10,                     ; y (posición vertical)
    100,                    ; ancho
    30,                     ; alto
    hWnd,                   ; Handle de ventana padre
    ID_BUTTON,              ; ID del control
    hInstance,              ; Handle de instancia
    NULL                    ; Parámetro de creación
```

### Elementos Importantes

1. **ID del Control**: Número único que identifica al botón
   ```assembly
   ID_BTN_ACEPTAR  equ 1001
   ID_BTN_CANCELAR equ 1002
   ```

2. **Handle del Padre**: El handle de la ventana que contiene el botón

3. **Posición y Tamaño**: En píxeles, relativo a la ventana padre

## Manejo de Eventos WM_COMMAND

Cuando el usuario hace clic en un botón, Windows envía el mensaje **WM_COMMAND** a la ventana padre.

### Estructura del Mensaje

```assembly
.elseif uMsg == WM_COMMAND
    ; LOWORD(wParam) = ID del control
    ; HIWORD(wParam) = Código de notificación
    ; lParam = Handle del control
    
    mov eax, wParam
    and eax, 0FFFFh         ; Obtener LOWORD (ID del control)
    
    .if eax == ID_BTN_ACEPTAR
        ; Código para botón "Aceptar"
    .elseif eax == ID_BTN_CANCELAR
        ; Código para botón "Cancelar"
    .endif
.endif
```

### Códigos de Notificación para Botones

| Código | Valor | Descripción |
|--------|-------|-------------|
| BN_CLICKED | 0 | Botón fue clickeado |
| BN_PAINT | 1 | Botón necesita redibujarse |
| BN_HILITE | 2 | Usuario presionó el botón |
| BN_UNHILITE | 3 | Usuario soltó el botón |
| BN_DISABLE | 4 | Botón fue deshabilitado |
| BN_DOUBLECLICKED | 5 | Doble clic en el botón |

**Nota**: Para la mayoría de los casos, solo necesitas manejar BN_CLICKED (código 0).

## Ejemplo Completo

Ver el archivo `ButtonSimpleWindow.asm` para un ejemplo con un solo botón que muestra un MessageBox.

Ver el archivo `ButtonMultipleWindow.asm` para un ejemplo con múltiples botones.

## Funciones Útiles para Botones

### EnableWindow
Habilita o deshabilita un botón:
```assembly
EnableWindow proto stdcall :DWORD, :DWORD

; Deshabilitar botón
invoke EnableWindow, hButton, FALSE

; Habilitar botón
invoke EnableWindow, hButton, TRUE
```

### SetWindowTextA
Cambia el texto del botón:
```assembly
SetWindowTextA proto stdcall :DWORD, :DWORD

invoke SetWindowTextA, hButton, addr szNuevoTexto
```

### GetDlgItem
Obtiene el handle de un control por su ID:
```assembly
GetDlgItem proto stdcall :DWORD, :DWORD

invoke GetDlgItem, hWnd, ID_BUTTON
mov hButton, eax
```

## Compilación

### Opción 1: VS Code (Ctrl+Shift+B)
1. Abrir `ButtonSimpleWindow.asm` o `ButtonMultipleWindow.asm`
2. Presionar `Ctrl+Shift+B`
3. Seleccionar "ASM: Build current file"

### Opción 2: PowerShell
```powershell
cd .\X86\GUI_EJEMPLOS\02_Button\
..\..\..\X86\build.ps1 ButtonSimpleWindow.asm -OutDir .\build
```

### Opción 3: WSL
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/Ensamblador
make -f X86/Makefile
```

### Opción 4: Manual
```powershell
# Ensamblar
ml /c /coff /Zi ButtonSimpleWindow.asm

# Enlazar
link /subsystem:windows /entry:start /out:ButtonSimpleWindow.exe ButtonSimpleWindow.obj kernel32.lib user32.lib
```

## Resultado Esperado

Al ejecutar `ButtonSimpleWindow.exe`:
- Ventana con un botón "Hacer Clic"
- Al hacer clic, aparece un MessageBox
- Botón responde visualmente al pasar el mouse

Al ejecutar `ButtonMultipleWindow.exe`:
- Ventana con tres botones
- Cada botón muestra un mensaje diferente
- Los botones están organizados verticalmente

## Estructura del Código

```
┌─────────────────────────────────┐
│  Definir constantes de IDs      │
│  ID_BTN_1 equ 1001              │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  Crear ventana principal        │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  En WM_CREATE:                  │
│  - Crear botones con            │
│    CreateWindowExA              │
│  - Clase "BUTTON"               │
│  - Asignar IDs únicos           │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  En WM_COMMAND:                 │
│  - Obtener ID del control       │
│    (LOWORD de wParam)           │
│  - Comparar con IDs conocidos   │
│  - Ejecutar acción              │
└─────────────────────────────────┘
```

## Ejercicios Propuestos

1. **Calculadora Simple**: Crea una ventana con botones para números 0-9 y operaciones básicas (+, -, *, /)

2. **Cambio de Color**: Crea botones para cambiar el color de fondo de la ventana

3. **Habilitar/Deshabilitar**: Crea un botón que habilite/deshabilite otros botones

4. **Contador**: Crea botones de incrementar/decrementar que actualicen un contador visible

5. **Botones Dinámicos**: Crea botones que se creen/destruyan en tiempo de ejecución

## Mensajes Importantes

| Mensaje | Valor | Cuándo se Envía |
|---------|-------|-----------------|
| WM_COMMAND | 0x0111 | Usuario interactúa con control |
| BN_CLICKED | 0 | Usuario hace clic en botón |

## Constantes de Referencia

```assembly
; Estilos de botón
BS_PUSHBUTTON       equ 0h
BS_DEFPUSHBUTTON    equ 1h
BS_CHECKBOX         equ 2h
BS_AUTOCHECKBOX     equ 3h
BS_RADIOBUTTON      equ 4h
BS_3STATE           equ 5h
BS_AUTO3STATE       equ 6h
BS_GROUPBOX         equ 7h
BS_USERBUTTON       equ 8h
BS_AUTORADIOBUTTON  equ 9h
BS_FLAT             equ 8000h

; Notificaciones de botón
BN_CLICKED          equ 0
BN_PAINT            equ 1
BN_HILITE           equ 2
BN_UNHILITE         equ 3
BN_DISABLE          equ 4
BN_DOUBLECLICKED    equ 5
BN_PUSHED           equ 2    ; Igual que BN_HILITE
BN_UNPUSHED         equ 3    ; Igual que BN_UNHILITE
BN_DBLCLK           equ 5    ; Igual que BN_DOUBLECLICKED
BN_SETFOCUS         equ 6
BN_KILLFOCUS        equ 7

; Valores booleanos
TRUE                equ 1
FALSE               equ 0
```

## Siguiente Paso

Una vez que domines los botones, continúa con **03_Label** para aprender a mostrar texto estático.

## Recursos Adicionales

- [Button Control Styles (Microsoft Docs)](https://learn.microsoft.com/en-us/windows/win32/controls/button-styles)
- [Button Messages (Microsoft Docs)](https://learn.microsoft.com/en-us/windows/win32/controls/bumper-button-control-reference-messages)
- [WM_COMMAND Message](https://learn.microsoft.com/en-us/windows/win32/menurc/wm-command)

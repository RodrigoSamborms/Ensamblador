# 🪟 01 - Ventana Básica

## 📝 Descripción

Este es el ejemplo más fundamental: crear una ventana vacía en Windows. Aprenderás la estructura básica de cualquier aplicación GUI en Win32 usando ensamblador.

---V

## 🎯 Objetivos de Aprendizaje

- Entender la estructura mínima de una aplicación Win32
- Registrar una clase de ventana (`WNDCLASSEX`)
- Crear y mostrar una ventana
- Implementar el bucle de mensajes
- Procesar mensajes básicos en el `WndProc`

---

## 📋 Conceptos Clave

### 1. **Estructura WNDCLASSEX**

Define las propiedades de una "clase" de ventana (no confundir con clases de POO):

```assembly
WNDCLASSEX STRUCT
    cbSize           DWORD      ; Tamaño de la estructura
    style            DWORD      ; Estilo de la clase
    lpfnWndProc      DWORD      ; Puntero a WndProc
    cbClsExtra       DWORD      ; Bytes extra para la clase
    cbWndExtra       DWORD      ; Bytes extra para cada ventana
    hInstance        DWORD      ; Handle de la instancia
    hIcon            DWORD      ; Handle del ícono
    hCursor          DWORD      ; Handle del cursor
    hbrBackground    DWORD      ; Brush para el fondo
    lpszMenuName     DWORD      ; Nombre del menú
    lpszClassName    DWORD      ; Nombre de la clase
    hIconSm          DWORD      ; Handle del ícono pequeño
WNDCLASSEX ENDS
```

### 2. **WndProc (Window Procedure)**

Es la función que procesa **todos** los mensajes que recibe la ventana:

- `WM_CREATE`: Ventana creada, inicializar controles
- `WM_PAINT`: Redibujar contenido
- `WM_CLOSE`: Usuario quiere cerrar
- `WM_DESTROY`: Ventana destruida, salir del programa

```assembly
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CLOSE
        invoke DestroyWindow, hWnd
        ret
    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        ret
    .endif
    
    ; Procesamiento por defecto
    invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
WndProc endp
```

### 3. **Bucle de Mensajes**

El bucle que mantiene la aplicación ejecutándose:

```assembly
MessageLoop:
    invoke GetMessageA, addr msg, NULL, 0, 0
    .if eax == 0    ; WM_QUIT recibido
        jmp EndProgram
    .endif
    
    invoke TranslateMessage, addr msg
    invoke DispatchMessageA, addr msg
    jmp MessageLoop
```

---

## 🔨 Compilar y Ejecutar

### Opción 1: VS Code
```
Ctrl + Shift + B → "ASM: Build current file"
```

### Opción 2: PowerShell
```powershell
# Desde la carpeta X86
.\build.ps1 GUI_EJEMPLOS\01_VentanaBasica\VentanaBasicaWindow.asm -OutDir .\build
```

### Opción 3: WSL
```bash
wsl make PROG=GUI_EJEMPLOS/01_VentanaBasica/VentanaBasicaWindow OUTDIR=build
```

---

## 🎨 Resultado Esperado

Al ejecutar `VentanaBasica.exe`, deberías ver:

- Una ventana de 640x480 píxeles
- Título: "Mi Primera Ventana"
- Fondo gris claro
- Botones de minimizar, maximizar y cerrar funcionales
- Se puede mover y redimensionar

---

## 📚 Estructura del Código

### Secciones principales:

1. **Directivas y prototipos** (`.386`, `.model`, prototipos de API)
2. **Sección de datos** (`.data`): Cadenas, variables globales, estructuras
3. **Sección de código** (`.code`):
   - `start`: Punto de entrada
   - `WndProc`: Procesador de mensajes

### Flujo de ejecución:

```
start
  ↓
Obtener hInstance (GetModuleHandleA)
  ↓
Llenar estructura WNDCLASSEX
  ↓
Registrar clase (RegisterClassExA)
  ↓
Crear ventana (CreateWindowExA)
  ↓
Mostrar ventana (ShowWindow, UpdateWindow)
  ↓
Bucle de mensajes (GetMessageA...)
  ↓
Salir (ExitProcess)
```

---

## 💡 Ejercicios Propuestos

1. **Cambiar el título**: Modifica `szWindowName` para cambiar el título
2. **Cambiar el tamaño**: Modifica los parámetros de `CreateWindowExA`
3. **Cambiar el color de fondo**: Usa otro valor en `hbrBackground`
   - `COLOR_WINDOW+1` (blanco)
   - `COLOR_BTNFACE+1` (gris botón)
   - `CreateSolidBrush` para color personalizado
4. **Centrar la ventana**: Calcula la posición con `GetSystemMetrics`
5. **Agregar un ícono personalizado**: Usa `LoadIconA` con un archivo .ico

---

## 🔍 Mensajes Importantes

| Mensaje | Cuándo se envía | Uso común |
|---------|-----------------|-----------|
| `WM_CREATE` | Al crear la ventana | Inicializar controles |
| `WM_PAINT` | Al redibujar | Dibujar con GDI |
| `WM_SIZE` | Al redimensionar | Reposicionar controles |
| `WM_CLOSE` | Al cerrar | Confirmar cierre |
| `WM_DESTROY` | Al destruir | Limpiar recursos |

---

## 📖 Constantes Utilizadas

```assembly
; Estilos de ventana
WS_OVERLAPPEDWINDOW equ 0CF0000h   ; Ventana estándar
WS_VISIBLE          equ 10000000h  ; Visible al crear

; Estilos de clase
CS_HREDRAW          equ 2h         ; Redibujar si cambia ancho
CS_VREDRAW          equ 1h         ; Redibujar si cambia alto

; Valores especiales
NULL                equ 0
CW_USEDEFAULT       equ 80000000h  ; Posición automática

; Mensajes
WM_CREATE           equ 1h
WM_CLOSE            equ 10h
WM_DESTROY          equ 2h
WM_PAINT            equ 0Fh

; Comandos
SW_SHOWNORMAL       equ 1          ; Mostrar ventana normal
```

---

## 🚀 Siguiente Paso

Una vez que entiendas este código, pasa a **02_Button** para agregar interactividad con botones.

---

## 📝 Notas

- Este es código **educativo**, prioriza claridad sobre optimización
- Todos los comentarios están en español para facilitar el aprendizaje
- El código sigue las convenciones estándar de Win32 API
- Compatible con Windows 7 en adelante

---

**¡Compila, ejecuta y experimenta! 🎓**

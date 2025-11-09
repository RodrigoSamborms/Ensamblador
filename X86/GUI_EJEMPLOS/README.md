# 🖼️ Ejemplos de GUI en Ensamblador x86 (32 bits)

Colección de ejemplos prácticos para crear interfaces gráficas de usuario (GUI) en Windows usando MASM de 32 bits.

---

## 📚 Índice de Contenidos

- [Introducción](#introducción)
- [Requisitos](#requisitos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Cómo Compilar](#cómo-compilar)
- [Estado actual](#estado-actual)
- [Prueba rápida](#prueba-rápida)
- [Controles Disponibles](#controles-disponibles)
- [Conceptos Fundamentales](#conceptos-fundamentales)
- [Recursos de Aprendizaje](#recursos-de-aprendizaje)

---

## 🎯 Introducción

Esta carpeta contiene ejemplos educativos de cómo crear aplicaciones GUI en Windows usando ensamblador x86 (32 bits) con MASM. Cada subcarpeta se enfoca en un control específico de Windows con:

- ✅ Código fuente completo y comentado
- 📖 Documentación detallada (README.md)
- 🎓 Explicación de conceptos clave
- 💡 Ejemplos prácticos funcionales

**Arquitectura:** x86 (32 bits)  
**API:** Win32 API  
**Compilador:** MASM (ml.exe) de Visual Studio Build Tools

---

## ⚙️ Requisitos

1. **Visual Studio Build Tools** o Visual Studio completo
   - Componente "Desarrollo para el escritorio con C++"
   - Incluye MASM (ml.exe, link.exe)

2. **Script de compilación** (ya incluido en el proyecto):
   - `build.ps1` - PowerShell (Windows)
   - `Makefile` - GNU Make (WSL)

3. **VS Code** (opcional pero recomendado):
   - Atajos de teclado configurados (`Ctrl+Shift+B`)

---

## 📁 Estructura del Proyecto

```
GUI_EJEMPLOS/
│
├── README.md                    # Este archivo
│
├── 01_VentanaBasica/           # Ventana simple sin controles
│   ├── README.md               # Explicación de ventanas Win32
│   └── VentanaBasicaWindow.asm       # Código ejemplo
│
├── 02_Button/                  # Botones (BUTTON)
│   ├── README.md               # Guía completa de botones
│   ├── ButtonSimpleWindow.asm        # Botón simple
│   └── ButtonMultipleWindow.asm      # Múltiples botones
│
├── 03_Label/                   # Etiquetas de texto (STATIC)
│   ├── README.md               # Guía de labels/static
│   └── LabelEjemploWindow.asm        # Etiquetas de texto
│
├── 04_TextBox/                 # Cuadros de texto (EDIT)
│   ├── README.md               # Guía de textbox/edit
│   ├── TextBoxSimpleWindow.asm       # Input simple
│   └── TextBoxMultilineWindow.asm    # Texto multilínea
│
├── 05_CheckBox/                # Casillas de verificación
│   ├── README.md               # Guía de checkbox
│   └── CheckBoxEjemploWindow.asm     # Checkboxes
│
├── 06_RadioButton/             # Botones de opción
│   ├── README.md               # Guía de radio buttons
│   └── RadioButtonEjemploWindow.asm  # Opciones exclusivas
│
├── 07_ListBox/                 # Listas de selección
│   ├── README.md               # Guía de listbox
│   └── ListBoxEjemploWindow.asm      # Lista de items
│
├── 08_ComboBox/                # Listas desplegables
│   ├── README.md               # Guía de combobox
│   └── ComboBoxEjemploWindow.asm     # Dropdown lists
│
└── 09_MessageBox/              # Cuadros de diálogo
    ├── README.md               # Guía de MessageBox
    └── MessageBoxEjemploWindow.asm   # Diferentes tipos de diálogos
```

---

## 🔨 Cómo Compilar

### Opción 1: VS Code (Recomendado)

1. Abre cualquier archivo `.asm` de los ejemplos
2. Presiona **`Ctrl + Shift + B`**
3. Selecciona **"ASM: Build current file (MASM via build.ps1)"**
4. El ejecutable se genera en `./build/`

### Opción 2: PowerShell (Línea de comandos)

```powershell
# Desde la raíz del proyecto (./X86)
cd GUI_EJEMPLOS/01_VentanaBasica
..\..\build.ps1 VentanaBasicaWindow.asm -OutDir ..\build

# O desde ./X86
.\build.ps1 GUI_EJEMPLOS\01_VentanaBasica\VentanaBasicaWindow.asm -OutDir .\build
```

### Opción 3: WSL con Makefile

```bash
# Desde ./X86
wsl make PROG=GUI_EJEMPLOS/01_VentanaBasica/VentanaBasica OUTDIR=build
```

### Opción 4: Compilación manual

```cmd
:: Configurar entorno de Visual Studio
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

:: Compilar
ml.exe /c /coff VentanaBasicaWindow.asm
link.exe /subsystem:windows /entry:WinMainCRTStartup VentanaBasica.obj kernel32.lib user32.lib gdi32.lib
```

### Nota sobre el script de build

El script `X86/build.ps1` detecta automáticamente si debe enlazar como aplicación de consola o GUI:

- Si el nombre del archivo contiene la palabra `Window`, usa `/subsystem:windows` y enlaza con `user32.lib` y `gdi32.lib`.
- En caso contrario, usa `/subsystem:console` y enlaza sólo con `kernel32.lib`.

Esto permite que `SumaMejoradaWindow.asm` y otros ejemplos con "Window" en el nombre se construyan como aplicaciones de ventana sin argumentos adicionales.

---

## ✅ Estado actual

Ejemplos listos para usar:

- [x] 01_VentanaBasica
    - Código: `GUI_EJEMPLOS/01_VentanaBasica/VentanaBasicaWindow.asm`
    - Descripción: Ventana Win32 mínima con bucle de mensajes y manejo de WM_CLOSE/WM_DESTROY.

- [x] 02_Button
    - Código: `GUI_EJEMPLOS/02_Button/ButtonSimpleWindow.asm` (un botón)
    - Código: `GUI_EJEMPLOS/02_Button/ButtonMultipleWindow.asm` (tres botones, acciones distintas)
    - Descripción: Creación de controles BUTTON y manejo de `WM_COMMAND`/`BN_CLICKED`.

- [x] 03_Label
    - Código: `GUI_EJEMPLOS/03_Label/LabelEjemploWindow.asm`
    - Descripción: Varias etiquetas (SS_LEFT/CENTER/RIGHT/SUNKEN) y actualización dinámica.
- [x] 04_TextBox
    - Código: `GUI_EJEMPLOS/04_TextBox/TextBoxSimpleWindow.asm`
    - Código: `GUI_EJEMPLOS/04_TextBox/TextBoxMultilineWindow.asm`
    - Descripción: Entrada simple, multilínea con scroll, límite de longitud y eventos EN_CHANGE.
- [x] 05_CheckBox
    - Código: `GUI_EJEMPLOS/05_CheckBox/CheckBoxEjemploWindow.asm`
    - Descripción: Casillas automáticas y 3-state, lectura y escritura de estado.
- [x] 06_RadioButton
    - Código: `GUI_EJEMPLOS/06_RadioButton/RadioButtonEjemploWindow.asm`
    - Descripción: Grupo de radios con WS_GROUP, selección y label de estado.
- [x] 07_ListBox
    - Código: `GUI_EJEMPLOS/07_ListBox/ListBoxEjemploWindow.asm`
    - Descripción: Lista con LB_ADDSTRING, selección LBN_SELCHANGE y recarga.
- [x] 08_ComboBox
    - Código: `GUI_EJEMPLOS/08_ComboBox/ComboBoxEjemploWindow.asm`
    - Descripción: Dropdown list, lectura de selección y recarga de ítems.
- [x] 09_MessageBox
    - Código: `GUI_EJEMPLOS/09_MessageBox/MessageBoxEjemploWindow.asm`
    - Descripción: Diferentes cuadros (Info, Pregunta Yes/No, Error) y manejo de respuesta.

Ejemplo más grande de referencia en x86:

- `X86/SumaMejoradaWindow.asm` — App GUI con varios controles integrados (útil para comparar patrones completos).

---

## 🚀 Prueba rápida

### Ventana básica

```powershell
# Desde la raíz del repo (./X86)
cd .\X86\GUI_EJEMPLOS\01_VentanaBasica
..\..\build.ps1 VentanaBasicaWindow.asm -OutDir ..\build
..\build\VentanaBasicaWindow.exe
```

### Botones

```powershell
# Ejemplo simple
cd .\X86\GUI_EJEMPLOS\02_Button
..\..\build.ps1 ButtonSimpleWindow.asm -OutDir ..\build
..\build\ButtonSimpleWindow.exe

# Ejemplo con múltiples botones
..\..\build.ps1 ButtonMultipleWindow.asm -OutDir ..\build
..\build\ButtonMultipleWindow.exe
```

### Compilar y ejecutar cada ejemplo

Desde la carpeta `X86` (raíz de estos ejemplos) puedes compilar y ejecutar cada archivo así:

```powershell
# 01 - Ventana básica
./build.ps1 GUI_EJEMPLOS/01_VentanaBasica/VentanaBasicaWindow.asm -OutDir ./build
./build/VentanaBasicaWindow.exe

# 02 - Botones (simple y múltiple)
./build.ps1 GUI_EJEMPLOS/02_Button/ButtonSimpleWindow.asm -OutDir ./build
./build/ButtonSimpleWindow.exe
./build.ps1 GUI_EJEMPLOS/02_Button/ButtonMultipleWindow.asm -OutDir ./build
./build/ButtonMultipleWindow.exe

# 03 - Label
./build.ps1 GUI_EJEMPLOS/03_Label/LabelEjemploWindow.asm -OutDir ./build
./build/LabelEjemploWindow.exe

# 04 - TextBox (simple y multilínea)
./build.ps1 GUI_EJEMPLOS/04_TextBox/TextBoxSimpleWindow.asm -OutDir ./build
./build/TextBoxSimpleWindow.exe
./build.ps1 GUI_EJEMPLOS/04_TextBox/TextBoxMultilineWindow.asm -OutDir ./build
./build/TextBoxMultilineWindow.exe

# 05 - CheckBox
./build.ps1 GUI_EJEMPLOS/05_CheckBox/CheckBoxEjemploWindow.asm -OutDir ./build
./build/CheckBoxEjemploWindow.exe

# 06 - RadioButton
./build.ps1 GUI_EJEMPLOS/06_RadioButton/RadioButtonEjemploWindow.asm -OutDir ./build
./build/RadioButtonEjemploWindow.exe

# 07 - ListBox
./build.ps1 GUI_EJEMPLOS/07_ListBox/ListBoxEjemploWindow.asm -OutDir ./build
./build/ListBoxEjemploWindow.exe

# 08 - ComboBox
./build.ps1 GUI_EJEMPLOS/08_ComboBox/ComboBoxEjemploWindow.asm -OutDir ./build
./build/ComboBoxEjemploWindow.exe

# 09 - MessageBox
./build.ps1 GUI_EJEMPLOS/09_MessageBox/MessageBoxEjemploWindow.asm -OutDir ./build
./build/MessageBoxEjemploWindow.exe

# Ejemplo mayor de referencia
./build.ps1 SumaMejoradaWindow.asm -OutDir ./build
./build/SumaMejoradaWindow.exe
```

Nota: Si aparece una consola adicional es porque el script detectó "console" (el nombre del archivo no contiene "Window"). Para evitarlo puedes:

1. Renombrar el archivo agregando "Window" (ej: `ListBoxWindow.asm`).
2. Ajustar la condición en `build.ps1` para forzar `/subsystem:windows` si la ruta contiene `GUI_EJEMPLOS`.
3. Ignorar la consola (no afecta el funcionamiento de la ventana principal).

---

## 🎨 Controles Disponibles

| # | Control | Clase Windows | Descripción | Dificultad |
|---|---------|---------------|-------------|------------|
| 1 | **Ventana Básica** | - | Ventana principal sin controles | ⭐ Básico |
| 2 | **Button** | `BUTTON` | Botones clickeables | ⭐ Básico |
| 3 | **Label** | `STATIC` | Texto estático (etiquetas) | ⭐ Básico |
| 4 | **TextBox** | `EDIT` | Entrada de texto | ⭐⭐ Intermedio |
| 5 | **CheckBox** | `BUTTON` (BS_CHECKBOX) | Casillas de verificación | ⭐⭐ Intermedio |
| 6 | **RadioButton** | `BUTTON` (BS_RADIOBUTTON) | Opciones exclusivas | ⭐⭐ Intermedio |
| 7 | **ListBox** | `LISTBOX` | Lista de selección | ⭐⭐⭐ Avanzado |
| 8 | **ComboBox** | `COMBOBOX` | Lista desplegable | ⭐⭐⭐ Avanzado |
| 9 | **MessageBox** | API `MessageBoxA` | Diálogos emergentes | ⭐ Básico |

---

## 📖 Conceptos Fundamentales

### 1. Estructura Básica de una Aplicación Win32

Toda aplicación GUI en Windows sigue este patrón:

```assembly
.386
.model flat, stdcall
option casemap:none

; Incluir bibliotecas
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

.data
    ; Variables globales

.code
start:
    ; 1. Obtener handle de la instancia (GetModuleHandleA)
    ; 2. Registrar clase de ventana (RegisterClassExA)
    ; 3. Crear ventana (CreateWindowExA)
    ; 4. Mostrar ventana (ShowWindow, UpdateWindow)
    ; 5. Bucle de mensajes (GetMessageA, TranslateMessage, DispatchMessageA)
    ; 6. Salir (ExitProcess)

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    ; Procesar mensajes de Windows (WM_CREATE, WM_COMMAND, WM_PAINT, WM_CLOSE, etc.)
WndProc endp

end start
```

### 2. Sistema de Mensajes de Windows

Windows usa un **sistema basado en mensajes** para la comunicación:

- **WM_CREATE**: La ventana se está creando (crear controles aquí)
- **WM_COMMAND**: Un control envió un evento (botón clickeado, etc.)
- **WM_PAINT**: Redibujar la ventana
- **WM_CLOSE**: El usuario quiere cerrar la ventana
- **WM_DESTROY**: La ventana se está destruyendo

### 3. Crear Controles Hijos

Los controles (botones, textboxes, etc.) son **ventanas hijas** creadas con `CreateWindowExA`:

```assembly
invoke CreateWindowExA, 
    0,                          ; Estilo extendido
    addr szButtonClass,         ; "BUTTON"
    addr szButtonText,          ; Texto del botón
    WS_VISIBLE or WS_CHILD or BS_PUSHBUTTON,  ; Estilo
    10, 10,                     ; Posición X, Y
    100, 30,                    ; Ancho, Alto
    hWnd,                       ; Handle de la ventana padre
    ID_BUTTON,                  ; ID del control
    hInstance,                  ; Handle de instancia
    NULL                        ; Parámetro adicional
mov hButton, eax                ; Guardar handle del botón
```

### 4. Procesar Eventos de Controles

Cuando un control genera un evento (clic, cambio de texto, etc.), envía **WM_COMMAND** a la ventana padre:

```assembly
.elseif uMsg == WM_COMMAND
    ; LOWORD(wParam) = ID del control
    ; HIWORD(wParam) = Código de notificación
    mov eax, wParam
    and eax, 0FFFFh             ; Obtener LOWORD (ID)
    .if eax == ID_BUTTON
        ; El botón fue clickeado
        invoke MessageBoxA, hWnd, addr szMensaje, addr szTitulo, MB_OK
    .endif
```

### 5. Estilos de Ventana Comunes

| Constante | Valor | Descripción |
|-----------|-------|-------------|
| `WS_OVERLAPPEDWINDOW` | 0CF0000h | Ventana estándar con borde, título, botones |
| `WS_VISIBLE` | 10000000h | Ventana visible al crearse |
| `WS_CHILD` | 40000000h | Ventana hija (para controles) |
| `CW_USEDEFAULT` | 80000000h | Posición/tamaño por defecto |

### 6. Arquitectura x86 (32 bits)

- **Modelo de memoria:** Flat (`.model flat`)
- **Convención de llamada:** `stdcall` (llamador limpia la pila)
- **Punteros:** 32 bits (4 bytes)
- **Registros principales:** EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP

---

## 🔗 Recursos de Aprendizaje

### Documentación Oficial
- [Win32 API Documentation](https://learn.microsoft.com/en-us/windows/win32/api/)
- [MASM Reference](https://learn.microsoft.com/en-us/cpp/assembler/masm/masm-for-x64-ml64-exe)
- [Window Classes](https://learn.microsoft.com/en-us/windows/win32/winmsg/window-classes)

### Tutoriales Recomendados
- [Iczelion's Win32 Assembly Tutorials](http://www.win32assembly.programminghorizon.com/tutorials.html)
- [MASM32 SDK](https://www.masm32.com/)

### Herramientas Útiles
- **Resource Hacker**: Inspeccionar recursos de ejecutables
- **Spy++**: Analizar mensajes de Windows
- **WinDbg**: Depurador de bajo nivel

---

## 💡 Consejos para Aprender

1. **Comienza con lo básico**: Empieza por `01_VentanaBasica` antes de pasar a controles complejos
2. **Lee los comentarios**: Cada ejemplo está extensamente comentado
3. **Experimenta**: Modifica valores (tamaños, posiciones, textos) y recompila
4. **Usa el depurador**: Visual Studio puede depurar ensamblador
5. **Consulta la documentación**: Win32 API es extensa, usa MSDN
6. **Compara con C**: Muchos ejemplos de Win32 están en C, aprende a traducirlos

---

## 🚀 Próximos Pasos

Una vez domines estos controles básicos, puedes avanzar a:

- **Menús** (CreateMenu, AppendMenuA)
- **Barras de herramientas** (Toolbars)
- **Barras de estado** (Status bars)
- **Controles comunes** (Progress bar, Tree view, List view)
- **GDI** (Graphics Device Interface) para dibujar
- **Diálogos personalizados** (DialogBoxParamA)

---

## 📝 Notas Importantes

- **Todos los ejemplos son para 32 bits (x86)**: Usan `.386` y `.model flat`
- **Compatible con Windows 7+**: Los ejemplos usan Win32 API estándar
- **Sin dependencias externas**: Solo requieren las DLLs del sistema (kernel32, user32, gdi32)
- **Código educativo**: Prioriza claridad sobre optimización

---

## 🤝 Contribuir

Si quieres agregar más ejemplos o mejorar los existentes:

1. Mantén el mismo formato de comentarios
2. Actualiza el README.md correspondiente
3. Asegúrate de que compile con `build.ps1`
4. Incluye casos de uso y explicaciones claras

---

## 📜 Licencia

Código educativo de uso libre para aprendizaje.

---

**¡Feliz aprendizaje de ensamblador GUI! 🎓💻**

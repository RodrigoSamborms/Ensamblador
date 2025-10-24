# Proyectos x86 con MASM

Este directorio contiene proyectos de ensamblador x86 compilados con MASM (Microsoft Macro Assembler).

## Requisitos Previos

### 1. Microsoft Visual Studio
MASM (Microsoft Macro Assembler) viene incluido con Visual Studio. Asegúrate de tener instalado:
- Visual Studio 2022 (Community, Professional o Enterprise)
- Componente "Desarrollo para el escritorio con C++"

### 2. GNU Make (Opcional)
Para usar el Makefile, necesitas instalar GNU Make en Windows.

**Instalación con winget:**
```powershell
winget install GnuWin32.Make
```

Después de la instalación, agrega Make al PATH del sistema:
```powershell
$env:Path += ";C:\Program Files (x86)\GnuWin32\bin"
```

Para hacerlo permanente, agrega la ruta en Variables de entorno del sistema.

## Métodos de Compilación

Este directorio ofrece **múltiples métodos de compilación** para adaptarse a diferentes flujos de trabajo:

| Método | Plataforma | Uso Principal | Ventajas |
|--------|-----------|---------------|----------|
| **VS Code Tasks** (Ctrl+Shift+B) | Windows | Desarrollo en VS Code | Integración directa, rápido |
| **build.ps1** | Windows | Línea de comandos PowerShell | Scripts automatizados, CI/CD |
| **Makefile** | WSL (Linux) | Usuarios de Linux/make | Estándar Unix, portable |
| **Manual** | Windows | Aprendizaje, depuración | Control total del proceso |

### Opción 0: Tareas de VS Code (Ctrl+Shift+B)

Se han configurado tareas en `.vscode/tasks.json` para compilar usando el script `build.ps1` automáticamente.

Atajos y uso:
- Abre cualquier archivo `.asm` en este directorio.
- Presiona `Ctrl+Shift+B` y elige una tarea:
    - "ASM: Build current file (MASM via build.ps1)" → Compila el archivo abierto (por defecto). Salida: `./build`
    - "ASM: Build all in folder" → Compila todos los `.asm` en la carpeta del archivo abierto. Salida: `./build`
    - "ASM: Clean folder" → Limpia `./build` (elimina `.obj`, `.exe`, `.pdb`, `.ilk`).

Detalles técnicos:
- Ejecuta PowerShell con ExecutionPolicy Bypass y llama a `X86/build.ps1 -OutDir .\build`.
- El directorio de trabajo (cwd) es la carpeta del archivo abierto (`${fileDirname}`).
- Puedes cambiar la carpeta de salida editando `.vscode/tasks.json` (argumento `-OutDir`).

### Opción 1: Script de PowerShell (`build.ps1`)

**Compilar un archivo específico:**
```powershell
.\build.ps1 suma.asm
```

**Compilar todos los archivos .asm del directorio:**
```powershell
.\build.ps1
```

**Opciones adicionales:**
- `-Clean` limpia artefactos (obj, exe, pdb, ilk) en el directorio actual o en `-OutDir` si se especifica.
- `-OutDir <ruta>` escribe los artefactos de salida en la carpeta indicada (se crea si no existe).

**Ejemplos:**
```powershell
# Limpiar artefactos en el directorio actual
.\build.ps1 -Clean

# Compilar suma.asm dejando los binarios en .\build
.\build.ps1 suma.asm -OutDir .\build

# Compilar todos los .asm hacia .\bin
.\build.ps1 -OutDir .\bin

# Limpiar la carpeta .\build
.\build.ps1 -Clean -OutDir .\build
```

**Características:**
- Compila y enlaza automáticamente
- Mensajes con colores para fácil lectura
- Manejo de errores detallado
- Puede procesar múltiples archivos
- **Detección automática de aplicaciones GUI**: Si el nombre del archivo contiene "Window", automáticamente:
  - Usa `/subsystem:windows` en lugar de `/subsystem:console`
  - Enlaza con `kernel32.lib`, `user32.lib` y `gdi32.lib`
  - Muestra mensaje "Detectado: Aplicación GUI (subsistema Windows)"

### Opción 2: Makefile (WSL - Debian/Ubuntu)

El Makefile está optimizado para usarse **exclusivamente en WSL** (Windows Subsystem for Linux).

**Requisitos:**
- WSL con Debian/Ubuntu instalado
- GNU Make (`sudo apt install make` si no está instalado)
- Acceso a las herramientas de Visual Studio desde WSL (rutas `/mnt/c/...`)

**Características del Makefile:**
- Detección automática de aplicaciones GUI (nombres con "Window")
- Conversión automática de rutas Linux→Windows usando `wslpath`
- Soporte para directorio de salida (`OUTDIR`)
- Colores ANSI en la salida
- Enlaza automáticamente las bibliotecas correctas según el tipo de aplicación

**Compilar el programa por defecto (suma.asm):**
```bash
wsl make
```

**Compilar otro archivo específico:**
```bash
wsl make PROG=nombre_sin_extension
```
Ejemplos:
```bash
# Compilar sumaMejorada.asm
wsl make PROG=sumaMejorada

# Compilar SumaMejoradaWindow.asm (detecta automáticamente que es GUI)
wsl make PROG=SumaMejoradaWindow
```

**Especificar directorio de salida:**
```bash
wsl make PROG=suma OUTDIR=build
wsl make PROG=SumaMejoradaWindow OUTDIR=build
```

**Limpiar archivos generados:**
```bash
wsl make clean
# O limpiar una carpeta específica
wsl make OUTDIR=build clean
```

**Compilar y ejecutar:**
```bash
wsl make run
# O con configuración personalizada
wsl make PROG=SumaMejoradaWindow OUTDIR=build run
```

**Nota sobre `wslpath`:**
El Makefile usa `wslpath` para convertir rutas entre Linux y Windows automáticamente:
- Rutas Linux: `/mnt/c/Users/...`
- Rutas Windows: `C:\Users\...`

Esto permite que las herramientas de Windows (ml.exe, link.exe) funcionen correctamente desde WSL.

### Opción 3: Compilación Manual

Si prefieres compilar manualmente sin scripts:

**Paso 1 - Ensamblar (.asm → .obj):**
```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\ml.exe" /c /coff /Zi /Fo"archivo.obj" "archivo.asm"
```

**Paso 2 - Enlazar (.obj → .exe):**
```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\link.exe" /subsystem:console /out:"archivo.exe" "archivo.obj" /libpath:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86" kernel32.lib
```

**Nota:** Las rutas pueden variar según tu versión de Visual Studio y Windows SDK instalado.

## Archivos Generados

Después de la compilación exitosa, se generarán:
- `*.obj` - Archivo objeto (código ensamblado)
- `*.exe` - Ejecutable final
- `*.pdb` - Información de depuración (opcional)
- `*.ilk` - Archivo de enlace incremental (opcional)

## Ejemplo Completo

### Aplicación de Consola (suma.asm)

**Con PowerShell:**
```powershell
# Compilar
.\build.ps1 suma.asm -OutDir .\build

# Ejecutar
.\build\suma.exe
```

**Con Makefile (WSL):**
```bash
# Compilar
wsl make PROG=suma OUTDIR=build

# Ejecutar
wsl make PROG=suma OUTDIR=build run
```

**Salida esperada:**
```
El resultado de 7 + 4 es: 11
```

### Aplicación de Consola Interactiva (sumaMejorada.asm)

**Con PowerShell:**
```powershell
# Compilar
.\build.ps1 sumaMejorada.asm -OutDir .\build

# Ejecutar
.\build\sumaMejorada.exe
```

**Con Makefile (WSL):**
```bash
# Compilar
wsl make PROG=sumaMejorada OUTDIR=build

# Ejecutar
wsl make PROG=sumaMejorada OUTDIR=build run
```

**Salida esperada:**
```
# El programa pedirá:
Ingrese el primer número: 15
Ingrese el segundo número: 27
Resultado: 42
```

### Aplicación GUI (SumaMejoradaWindow.asm)

**Con PowerShell:**
```powershell
# Compilar (detecta automáticamente que es GUI)
.\build.ps1 SumaMejoradaWindow.asm -OutDir .\build

# Ejecutar (abre una ventana)
.\build\SumaMejoradaWindow.exe
```

**Con Makefile (WSL):**
```bash
# Compilar (detecta automáticamente que es GUI)
wsl make PROG=SumaMejoradaWindow OUTDIR=build

# Ejecutar (abre una ventana)
wsl make PROG=SumaMejoradaWindow OUTDIR=build run
```

**Con VS Code (el más rápido):**
```
1. Abre SumaMejoradaWindow.asm
2. Presiona Ctrl+Shift+B para compilar
3. Ejecuta: .\build\SumaMejoradaWindow.exe
```

### Limpiar archivos generados

**Con PowerShell (Windows):**
```powershell
.\build.ps1 -Clean -OutDir .\build
```

**Con Makefile (WSL):**
```bash
wsl make OUTDIR=build clean
```

## Comparación: PowerShell vs Makefile

Ambos métodos ofrecen las mismas funcionalidades, elige según tu entorno:

| Característica | build.ps1 (Windows) | Makefile (WSL) |
|----------------|---------------------|----------------|
| **Comando típico** | `.\build.ps1 suma.asm -OutDir .\build` | `wsl make PROG=suma OUTDIR=build` |
| **Detección GUI** | ✅ Automática (nombres con "Window") | ✅ Automática (nombres con "Window") |
| **Directorio salida** | `-OutDir .\build` | `OUTDIR=build` |
| **Limpiar** | `.\build.ps1 -Clean -OutDir .\build` | `wsl make OUTDIR=build clean` |
| **Ejecutar** | `.\build\programa.exe` | `wsl make PROG=programa OUTDIR=build run` |
| **Colores** | ✅ Si (Write-Host con colores) | ✅ Si (códigos ANSI) |
| **Conversión rutas** | N/A (rutas Windows nativas) | ✅ Automática con `wslpath` |
| **Plataforma** | Windows (PowerShell) | WSL (Bash/sh) |
| **Integración VS Code** | ✅ Via tasks.json | ⚠️ Manual (no tasks) |

**Recomendaciones:**
- **Windows puro**: Usa `build.ps1` o VS Code tasks (Ctrl+Shift+B)
- **WSL/Linux**: Usa `Makefile` con `wsl make`
- **CI/CD Windows**: Usa `build.ps1`
- **CI/CD Linux/WSL**: Usa `Makefile`
- **Desarrollo VS Code**: Usa tasks (Ctrl+Shift+B) que llama a `build.ps1`

## Estructura de un Programa MASM Típico

```asm
.386                          ; Procesador 80386+
.model flat, stdcall          ; Modelo de memoria plana, convención stdcall
ExitProcess proto, dwExitCode:dword

.data
    ; Variables aquí
    variable dword ?

.code
main proc
    ; Tu código aquí
    mov eax, 5
    mov variable, eax
    
    invoke ExitProcess, 0
main endp
end main
```

## Sintaxis MASM vs Emu8086

Los programas aquí usan sintaxis MASM para Windows modernos, que difiere de la sintaxis DOS/Emu8086:

| Característica | MASM (X86) | Emu8086 (.COM) |
|---------------|------------|----------------|
| Modelo | `.model flat` | `ORG 100h` |
| Salida | `.exe` (PE32) | `.COM` (DOS) |
| Directivas | `.386`, `.data`, `.code` | Segmentos manuales |
| Llamadas sistema | `invoke ExitProcess` | `INT 21h` |
| Bibliotecas | `kernel32.lib` | N/A (solo BIOS/DOS) |

## Aplicaciones GUI vs Consola en MASM

### Diferencias Principales

| Aspecto | Aplicación de Consola | Aplicación GUI |
|---------|----------------------|----------------|
| **Subsistema** | `/subsystem:console` | `/subsystem:windows` |
| **Bibliotecas** | `kernel32.lib` | `kernel32.lib`, `user32.lib`, `gdi32.lib` |
| **Entrada/Salida** | ReadConsoleA, WriteConsoleA | Controles de Windows (EDIT, BUTTON) |
| **Interfaz** | Terminal de texto | Ventanas gráficas |
| **Bucle principal** | Secuencial | Bucle de mensajes (GetMessage/DispatchMessage) |
| **Eventos** | N/A | WM_CREATE, WM_COMMAND, WM_CLOSE, etc. |
| **APIs principales** | GetStdHandle, ReadFile, WriteFile | CreateWindowExA, RegisterClassExA, ShowWindow |

### Convención de Nombres

El script `build.ps1` y el `Makefile` detectan automáticamente aplicaciones GUI cuando el nombre del archivo contiene "Window":
- `suma.asm` → Consola
- `sumaMejorada.asm` → Consola
- `SumaMejoradaWindow.asm` → GUI ✓
- `CalculadoraWindow.asm` → GUI ✓

## Herramientas WSL: wslpath

Si usas el Makefile en WSL, la herramienta `wslpath` convierte automáticamente entre rutas Linux y Windows:

**Sintaxis:**
```bash
# Linux → Windows
wsl wslpath -w '/mnt/c/Users/sambo/Documents'
# Salida: C:\Users\sambo\Documents

# Windows → Linux
wsl wslpath -u 'C:\Users\sambo\Documents'
# Salida: /mnt/c/Users/sambo/Documents
```

**Uso en el Makefile:**
El Makefile usa `wslpath` internamente para:
1. Convertir rutas de bibliotecas (`LIBPATH`) para el linker de Windows
2. Convertir rutas de ejecutables al usar `make run`

Ejemplo del Makefile:
```makefile
# Ruta Linux
LIBPATH_LINUX = /mnt/c/Program Files (x86)/Windows Kits/10/Lib/...

# Convertir a ruta Windows
LIBPATH_WIN := $(shell wslpath -w '$(LIBPATH_LINUX)')
# Resultado: C:\Program Files (x86)\Windows Kits\10\Lib\...
```

Esto permite que las herramientas de Windows (ml.exe, link.exe) ejecutadas desde WSL reciban rutas en el formato correcto.
- `CalculadoraWindow.asm` → GUI ✓

## Proyectos Incluidos

### Aplicaciones de Consola

- **suma.asm** - Suma simple de dos números (7 + 4)
  - Tipo: Consola
  - Subsistema: console
  - Bibliotecas: kernel32.lib

- **sumaMejorada.asm** - Programa interactivo que solicita dos números al usuario
  - Tipo: Consola
  - Subsistema: console
  - Características:
    - Lee entrada del usuario mediante ReadConsoleA
    - Convierte texto a números (AsciiToInt)
    - Suma los valores
    - Convierte resultado a texto (IntToAscii)
    - Muestra el resultado
  - Bibliotecas: kernel32.lib

### Aplicaciones GUI (Interfaz Gráfica)

- **SumaMejoradaWindow.asm** - Calculadora con interfaz gráfica de Windows
  - Tipo: Aplicación GUI
  - Subsistema: windows
  - Características:
    - Ventana con título "Calculadora - Suma de Numeros"
    - Dos campos de texto para ingresar números
    - Botón "Sumar" para ejecutar la operación
    - Campo de resultado (solo lectura)
    - Utiliza Win32 API (CreateWindowExA, GetDlgItemInt, SetDlgItemInt)
    - Sin dependencias de MASM32 - usa solo APIs estándar de Windows
  - Bibliotecas: kernel32.lib, user32.lib, gdi32.lib
  - Compilación: El script `build.ps1` detecta automáticamente que es GUI y usa el subsistema correcto
  - Ejecución: `.\build\SumaMejoradaWindow.exe`

## Solución de Problemas

**Error: "no se puede abrir el archivo de entrada 'kernel32.lib'"**
- Verifica que tienes instalado el Windows SDK
- Ajusta la ruta `/libpath` en el comando de enlazado

**Error: "ml.exe no se reconoce como comando"**
- Usa la ruta completa al ejecutable
- O abre "Developer Command Prompt for VS 2022"

**Error de permisos al ejecutar build.ps1**
- Ejecuta: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## Autor

Rodrigo Samborms

## Fecha

Octubre 2025

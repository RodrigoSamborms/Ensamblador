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

Este directorio permite compilar de tres formas:

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

### Opción 2: Makefile

**Compilar el programa por defecto (suma.asm):**
```powershell
make
```

**Compilar otro archivo específico:**
```powershell
make PROG=nombre_sin_extension
```
Ejemplo: para compilar `programa.asm`, usa `make PROG=programa`

**Limpiar archivos generados:**
```powershell
make clean
```

**Compilar y ejecutar:**
```powershell
make run
```

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

```powershell
# Compilar con el script de PowerShell
.\build.ps1 suma.asm

# Ejecutar el programa
.\suma.exe

# Limpiar archivos generados (si usas Makefile)
make clean
```

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

## Proyectos Incluidos

- **suma.asm** - Suma simple de dos números (7 + 4)

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

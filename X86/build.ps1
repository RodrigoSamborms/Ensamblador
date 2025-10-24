# Script de compilación para archivos .asm con MASM
<#
Uso:
    # Compilar archivo específico (salida en el directorio actual)
    .\build.ps1 suma.asm

    # Compilar todos los .asm del directorio actual
    .\build.ps1

    # Limpiar artefactos (obj, exe, pdb, ilk) en el directorio actual
    .\build.ps1 -Clean

    # Especificar carpeta de salida
    .\build.ps1 suma.asm -OutDir .\build
    .\build.ps1 -OutDir .\bin    # compila todos hacia .\bin

    # Limpiar una carpeta de salida específica
    .\build.ps1 -Clean -OutDir .\build
#>

param(
        [string]$AsmFile = "",
        [switch]$Clean,
        [string]$OutDir = ""
)

# Rutas de MASM y Linker
$MASM32 = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\ml.exe"
$LINK32 = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\link.exe"
$LIBPATH = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86"

# Verificar que existan las herramientas
if (-not (Test-Path $MASM32)) {
    Write-Host "ERROR: No se encuentra ml.exe en $MASM32" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $LINK32)) {
    Write-Host "ERROR: No se encuentra link.exe en $LINK32" -ForegroundColor Red
    exit 1
}

# Resolver carpeta de salida
$ResolvedOutDir = if ([string]::IsNullOrWhiteSpace($OutDir)) { (Get-Location).Path } else {
    $resolved = $null
    try { $resolved = Resolve-Path -Path $OutDir -ErrorAction Stop } catch { }
    $fullOut = $null
    if ($resolved) {
        $fullOut = $resolved.Path
    } else {
        # Construir ruta según si es absoluta o relativa
        if ([System.IO.Path]::IsPathRooted($OutDir)) {
            $fullOut = $OutDir
        } else {
            $fullOut = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $OutDir))
        }
    }
    if (-not (Test-Path $fullOut)) { New-Item -ItemType Directory -Force -Path $fullOut | Out-Null }
    $fullOut
}

# Limpiar si se solicita
if ($Clean) {
    Write-Host "Limpiando artefactos en: $ResolvedOutDir" -ForegroundColor Cyan
    $patterns = @('*.obj','*.exe','*.pdb','*.ilk')
    foreach ($pat in $patterns) {
        Get-ChildItem -Path $ResolvedOutDir -Filter $pat -ErrorAction SilentlyContinue | ForEach-Object {
            try { Remove-Item $_.FullName -Force -ErrorAction Stop } catch { }
        }
    }
    # Si solo es limpieza (sin compilar nada), salir aquí
    if ([string]::IsNullOrWhiteSpace($AsmFile) -and $PSBoundParameters.ContainsKey('OutDir') -or [string]::IsNullOrWhiteSpace($AsmFile)) {
        Write-Host "Limpieza completada." -ForegroundColor Green
        if ([string]::IsNullOrWhiteSpace($AsmFile)) { return }
    }
}

# Función para compilar un archivo
function Build-AsmFile {
    param(
        [string]$File,
        [string]$DestDir
    )
    
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $ObjFile = Join-Path $DestDir "$BaseName.obj"
    $ExeFile = Join-Path $DestDir "$BaseName.exe"
    
    Write-Host "`n=== Compilando $File ===" -ForegroundColor Cyan
    
    # Detectar si es aplicación GUI (nombres que contienen "Window")
    $subsystem = "console"
    $libraries = "kernel32.lib"
    
    if ($BaseName -match "Window") {
        $subsystem = "windows"
        $libraries = "kernel32.lib user32.lib gdi32.lib"
        Write-Host "Detectado: Aplicación GUI (subsistema Windows)" -ForegroundColor Magenta
    }
    
    # Paso 1: Ensamblar
    Write-Host "Ensamblando..." -ForegroundColor Yellow
    & $MASM32 /c /coff /Zi /Fo"$ObjFile" "$File"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Fallo al ensamblar $File" -ForegroundColor Red
        return $false
    }
    
    # Paso 2: Enlazar
    Write-Host "Enlazando..." -ForegroundColor Yellow
    $libArray = $libraries -split ' '
    & $LINK32 /subsystem:$subsystem /out:"$ExeFile" "$ObjFile" /libpath:"$LIBPATH" @libArray
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Fallo al enlazar $ObjFile" -ForegroundColor Red
        return $false
    }
    
    Write-Host "EXITO: Se creó $ExeFile" -ForegroundColor Green
    return $true
}

# Main
if ($AsmFile -eq "") {
    # Compilar todos los archivos .asm en el directorio actual
    $AsmFiles = Get-ChildItem -Filter "*.asm"
    
    if ($AsmFiles.Count -eq 0) {
        Write-Host "No se encontraron archivos .asm en el directorio actual" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Compilando todos los archivos .asm..." -ForegroundColor Cyan
    $Success = 0
    $Failed = 0
    
    foreach ($File in $AsmFiles) {
        if (Build-AsmFile $File.FullName $ResolvedOutDir) {
            $Success++
        } else {
            $Failed++
        }
    }
    
    Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
    Write-Host "Exitosos: $Success" -ForegroundColor Green
    Write-Host "Fallidos: $Failed" -ForegroundColor Red
    
} else {
    # Compilar archivo específico
    # Manejar rutas relativas y absolutas
    $FullAsmPath = if ([System.IO.Path]::IsPathRooted($AsmFile)) {
        $AsmFile
    } else {
        Join-Path (Get-Location).Path $AsmFile
    }
    
    if (-not (Test-Path $FullAsmPath)) {
        Write-Host "ERROR: No se encuentra el archivo $FullAsmPath" -ForegroundColor Red
        exit 1
    }
    
    if (Build-AsmFile $FullAsmPath $ResolvedOutDir) {
        exit 0
    } else {
        exit 1
    }
}

# REPORTE TÉCNICO
## ACTIVIDAD 05: Manejo de Directorios y Archivos en Lenguaje Ensamblador

---

**Programa:** Ingeniería en Sistemas Computacionales  
**Materia:** Lenguaje Ensamblador  
**Alumno:** Rodrigo Samborms  
**Fecha:** 21 de Octubre, 2025  
**Tipo de Programa:** .COM (DOS)

---

## ÍNDICE

1. [Introducción](#introducción)
2. [Objetivos](#objetivos)
3. [Marco Teórico](#marco-teórico)
4. [Análisis del Problema](#análisis-del-problema)
5. [Diagrama de Flujo](#diagrama-de-flujo)
6. [Código Fuente](#código-fuente)
7. [Servicios DOS Utilizados](#servicios-dos-utilizados)
8. [Procedimientos Implementados](#procedimientos-implementados)
9. [Variables del Programa](#variables-del-programa)
10. [Manejo de Errores](#manejo-de-errores)
11. [Resultados y Pruebas](#resultados-y-pruebas)
12. [Conclusiones](#conclusiones)
13. [Referencias](#referencias)

---

## INTRODUCCIÓN

El presente reporte documenta el desarrollo de un programa en lenguaje ensamblador x86 que demuestra la capacidad de interactuar directamente con el sistema operativo DOS para realizar operaciones de manejo de directorios y archivos. El programa, denominado **ACTIVIDAD05_PBN**, crea un directorio en el sistema de archivos, genera un archivo de texto, escribe la fecha actual del sistema en formato legible, y posteriormente lee y muestra el contenido del archivo en pantalla.

Este tipo de programación de bajo nivel permite comprender los fundamentos de cómo los sistemas operativos gestionan recursos como archivos y directorios, así como la comunicación directa con el hardware a través de interrupciones del sistema (INT 21h).

El programa fue desarrollado utilizando sintaxis compatible con **Emu8086**, un emulador de procesador 8086 ampliamente utilizado para el aprendizaje de programación en ensamblador. La estructura del código sigue un enfoque didáctico con nomenclatura en español para facilitar su comprensión.

---

## OBJETIVOS

### Objetivo General

Desarrollar un programa en lenguaje ensamblador que demuestre el manejo de directorios y archivos utilizando servicios del sistema operativo DOS, aplicando conceptos de programación de bajo nivel y gestión de recursos del sistema.

### Objetivos Específicos

1. **Crear directorios** en el sistema de archivos utilizando la interrupción INT 21h con la función 39h (MKDIR).

2. **Implementar conversión de datos** desde formato hexadecimal/binario a ASCII para presentar información legible al usuario.

3. **Obtener la fecha del sistema** mediante la interrupción INT 21h función 2Ah y formatearla en el estándar DD/MM/AAAA.

4. **Crear y escribir archivos** de texto utilizando los servicios DOS de creación (3Ch) y escritura (40h).

5. **Leer archivos existentes** y mostrar su contenido en pantalla utilizando los servicios de apertura (3Dh) y lectura (3Fh).

6. **Implementar manejo robusto de errores** detectando la activación de la bandera CF (Carry Flag) y proporcionando mensajes descriptivos al usuario.

7. **Aplicar buenas prácticas de programación** en ensamblador, incluyendo:
   - Modularización mediante procedimientos (PROC)
   - Preservación de registros (PUSH/POP)
   - Nomenclatura descriptiva en español
   - Comentarios claros y exhaustivos
   - Estructura organizada (Datos → Procedimientos → Código Principal)

---

## MARCO TEÓRICO

### Programas tipo .COM

Los archivos .COM (Command) son ejecutables de DOS con las siguientes características:

- **Tamaño máximo:** 64 KB - 256 bytes (debido al PSP - Program Segment Prefix)
- **Estructura:** Un único segmento para código, datos y pila
- **Inicio:** Siempre en el offset 100h (ORG 100h)
- **Registros de segmento:** CS = DS = ES = SS al iniciar
- **Simplicidad:** No requieren cabeceras complejas como los .EXE

### Interrupciones DOS (INT 21h)

La interrupción 21h del DOS proporciona servicios del sistema operativo. El número de función se especifica en el registro AH:

- **Manejo de archivos:** Crear, abrir, leer, escribir, cerrar
- **Manejo de directorios:** Crear, eliminar, cambiar
- **Entrada/salida:** Leer teclado, escribir pantalla
- **Fecha y hora:** Obtener y establecer fecha/hora del sistema
- **Atributos:** Consultar y modificar atributos de archivos

### Bandera CF (Carry Flag)

La bandera CF indica el resultado de operaciones del sistema:

- **CF = 0:** Operación exitosa
- **CF = 1:** Error ocurrido (código de error en AX)

### Conversión Numérica

El programa utiliza dos técnicas de conversión:

1. **AAM (ASCII Adjust after Multiply):** Convierte AL a BCD (Binary Coded Decimal)
   - Entrada: AL = número binario (0-99)
   - Salida: AH = decenas, AL = unidades

2. **División sucesiva:** Para números mayores (años de 4 dígitos)
   - Dividir entre 1000, 100, 10 para extraer cada dígito

---

## ANÁLISIS DEL PROBLEMA

### Requerimientos

El programa debe cumplir con los siguientes requisitos funcionales:

1. **Directorio de trabajo seguro:** Todas las operaciones deben realizarse en `C:\emu8086\MyBuild\` para evitar modificar archivos del sistema.

2. **Estructura de archivos:**
   - Directorio: `C:\emu8086\MyBuild\Rodrigo`
   - Archivo: `C:\emu8086\MyBuild\Rodrigo\Torres.txt`

3. **Contenido del archivo:** Fecha actual del sistema en formato DD/MM/AAAA seguida de salto de línea (CRLF).

4. **Validaciones:**
   - Detectar si el directorio ya existe
   - Manejar archivos existentes (sobrescribir)
   - Verificar bytes escritos = bytes esperados
   - Detectar archivos vacíos
   - Reportar errores con mensajes descriptivos incluyendo el estado de CF

5. **Nomenclatura:** Variables, procedimientos y etiquetas en español para facilitar la comprensión en audiencias hispanohablantes.

### Restricciones

- Entorno: Emu8086 (emulador de procesador 8086)
- Tipo: Programa .COM
- Tamaño máximo: 64 KB
- Compatibilidad: DOS/interrupciones INT 21h

---

## DIAGRAMA DE FLUJO

El siguiente diagrama muestra el flujo de ejecución del programa paso a paso:

```
    [INICIO]
       |
       v
  ┌─────────────────────────────────────┐
  │ 1. INICIALIZAR SEGMENTO DE DATOS    │
  │    - Asegurar DS = CS (modelo .COM) │
  │    - Mostrar encabezado del programa│
  └──────────────┬──────────────────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 2. CREAR DIRECTORIO                                 │
  │    Ruta: C:\emu8086\MyBuild\Rodrigo                 │
  │    INT 21h, AH=39h (MKDIR)                          │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
         ┌───────┴───────┐
         │  ¿CF=0?       │ (¿Se creó exitosamente?)
         └───┬───────┬───┘
             │       │
          SI │       │ NO (CF=1)
             │       │
             v       v
    ┌──────────┐   ┌────────────────────────────────┐
    │ Mostrar  │   │ Verificar si ya existe         │
    │ "Creado" │   │ INT 21h, AX=4300h (Get Attrs)  │
    └─────┬────┘   └────────┬───────────────────────┘
          │                 │
          │         ┌───────┴───────┐
          │         │  ¿CF=0?       │ (¿Existe?)
          │         └───┬───────┬───┘
          │             │       │
          │          SI │       │ NO
          │             │       │
          │             v       v
          │    ┌────────────┐ ┌─────────────┐
          │    │ "Directorio│ │ "Error al   │
          │    │ existente, │ │ crear dir,  │
          │    │ CF activa" │ │ CF activa"  │
          │    └──────┬─────┘ └──────┬──────┘
          │           │               │
          └───────────┴───────────────┘
                      |
                      v
  ┌─────────────────────────────────────────────────────┐
  │ 3. CONSTRUIR FECHA                                  │
  │    - INT 21h, AH=2Ah (Get Date)                     │
  │    - CX=año, DH=mes, DL=día                         │
  │    - Convertir a ASCII formato DD/MM/AAAA           │
  │    - Agregar CRLF (0Dh, 0Ah)                        │
  │    - Guardar en bufferFecha                         │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 4. CREAR ARCHIVO                                    │
  │    Ruta: C:\emu8086\MyBuild\Rodrigo\Torres.txt      │
  │    INT 21h, AH=3Ch (CREATE)                         │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
         ┌───────┴───────┐
         │  ¿CF=0?       │ (¿Se creó?)
         └───┬───────┬───┘
             │       │
          SI │       │ NO (CF=1)
             │       │
             │       v
             │   ┌──────────────────────────────────┐
             │   │ INTENTAR ABRIR PARA ESCRITURA    │
             │   │ INT 21h, AH=3Dh, AL=2 (R/W)      │
             │   └─────────┬────────────────────────┘
             │             │
             │     ┌───────┴───────┐
             │     │  ¿CF=0?       │
             │     └───┬───────┬───┘
             │         │       │
             │      SI │       │ NO
             │         │       │
             │         v       v
             │  ┌──────────┐ ┌──────────────┐
             │  │ "Archivo │ │ Ir a ERROR   │
             │  │ existe,  │ │              │
             │  │ CF activa│ └──────────────┘
             │  └─────┬────┘
             │        │
             └────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 5. ESCRIBIR FECHA EN ARCHIVO                        │
  │    INT 21h, AH=40h (WRITE)                          │
  │    BX=manejador, CX=longitudFecha, DX=bufferFecha   │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
         ┌───────┴───────┐
         │ ¿Bytes escritos│
         │ = esperados?   │
         └───┬───────┬────┘
             │       │
          SI │       │ NO
             │       │
             │       v
             │   ┌──────────────┐
             │   │ CERRAR y     │
             │   │ Ir a ERROR   │
             │   └──────────────┘
             v
  ┌─────────────────────────────────────────────────────┐
  │ 6. CERRAR ARCHIVO DESPUÉS DE ESCRIBIR               │
  │    INT 21h, AH=3Eh (CLOSE)                          │
  │    Mostrar "Escritura OK"                           │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 7. ABRIR ARCHIVO PARA LECTURA                       │
  │    Ruta: C:\emu8086\MyBuild\Rodrigo\Torres.txt      │
  │    INT 21h, AH=3Dh, AL=0 (solo lectura)             │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
         ┌───────┴───────┐
         │  ¿CF=0?       │
         └───┬───────┬───┘
             │       │
          SI │       │ NO
             │       │
             │       v
             │   ┌──────────────┐
             │   │ Ir a ERROR   │
             │   │ DE LECTURA   │
             │   └──────────────┘
             v
  ┌─────────────────────────────────────────────────────┐
  │ 8. LEER CONTENIDO DEL ARCHIVO                      │
  │    INT 21h, AH=3Fh (READ)                           │
  │    BX=manejador, CX=128, DX=bufferLectura           │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 9. CERRAR ARCHIVO DESPUÉS DE LEER                   │
  │    INT 21h, AH=3Eh (CLOSE)                          │
  └──────────────┬──────────────────────────────────────┘
                 |
                 v
         ┌───────┴───────┐
         │ ¿Bytes leídos │
         │ > 0?          │
         └───┬───────┬───┘
             │       │
          SI │       │ NO
             │       │
             v       v
  ┌──────────────┐ ┌─────────────────┐
  │ 10. MOSTRAR  │ │ Mostrar         │
  │ CONTENIDO    │ │ "Archivo vacío" │
  │ Imprimir     │ └────────┬────────┘
  │ bufferLectura│          │
  │ + CRLF       │          │
  └──────┬───────┘          │
         └──────────────────┘
                 |
                 v
  ┌─────────────────────────────────────────────────────┐
  │ 11. TERMINAR PROGRAMA                               │
  │     Mostrar "Fin del programa"                      │
  │     INT 21h, AX=4C00h (EXIT)                        │
  └─────────────────────────────────────────────────────┘
       |
       v
    [FIN]
```

---

## CÓDIGO FUENTE

El código fuente completo se encuentra en el archivo `ACTIVIAD05_PBN.asm`. A continuación se presenta la estructura general:

### Estructura del Programa

```assembly
; ACTIVIAD05_PBN.asm - Manejo de directorios y archivos (tipo .COM)
; Autor: Rodrigo Samborms
; Fecha: 21 de Octubre, 2025

ORG 100h                    ; Programas .COM inician en 100h

JMP INICIO                  ; Saltar sobre datos y procedimientos

; ============================================================
; DATOS DEL PROGRAMA
; ============================================================
rutaDirectorio db 'C:\emu8086\MyBuild\Rodrigo', 0
rutaArchivo    db 'C:\emu8086\MyBuild\Rodrigo\Torres.txt', 0
; ... (mensajes y buffers)

; ============================================================
; PROCEDIMIENTOS
; ============================================================
; - ImprimirCadena: Imprime cadena terminada en '$'
; - ImprimirCRLF: Imprime salto de línea
; - ImprimirBuffer: Imprime CX bytes desde DS:SI
; - DosDigitos: Convierte AL (0-99) a 2 dígitos ASCII
; - CuatroDigitos: Convierte AX (0-9999) a 4 dígitos ASCII
; - ConstruirFecha: Construye DD/MM/AAAA en bufferFecha

; ============================================================
; CÓDIGO PRINCIPAL
; ============================================================
INICIO:
    ; 1. Inicializar segmento de datos
    ; 2. Crear directorio
    ; 3. Construir fecha
    ; 4. Crear/abrir archivo
    ; 5. Escribir fecha
    ; 6. Cerrar archivo
    ; 7. Abrir para lectura
    ; 8. Leer contenido
    ; 9. Mostrar contenido
    ; 10. Terminar
```

### Fragmento Destacado: Conversión de Fecha

```assembly
ConstruirFecha PROC
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov ah, 2Ah                 ; DOS Get Date
    int 21h                     ; CX=año, DH=mes, DL=día
    
    lea di, bufferFecha
    
    mov al, dl                  ; Día
    call DosDigitos
    
    mov byte ptr [di], '/'      ; Separador
    inc di
    
    mov al, dh                  ; Mes
    call DosDigitos
    
    mov byte ptr [di], '/'      ; Separador
    inc di
    
    mov ax, cx                  ; Año
    call CuatroDigitos
    
    ; Agregar CRLF
    mov byte ptr [di], 0Dh
    inc di
    mov byte ptr [di], 0Ah
    inc di
    
    ; Calcular longitud
    mov ax, di
    sub ax, offset bufferFecha
    mov [longitudFecha], ax
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ConstruirFecha ENDP
```

---

## SERVICIOS DOS UTILIZADOS

El programa utiliza los siguientes servicios de la interrupción INT 21h:

| Función | Servicio | Descripción | Entrada | Salida |
|---------|----------|-------------|---------|--------|
| **2Ah** | Get Date | Obtener fecha del sistema | - | CX=año, DH=mes, DL=día |
| **39h** | MKDIR | Crear directorio | DS:DX = ruta ASCIIZ | CF=0 (OK) / CF=1 (error) |
| **3Ch** | CREATE | Crear o truncar archivo | CX=atributos, DS:DX=ruta | CF=0, AX=handle / CF=1 |
| **3Dh** | OPEN | Abrir archivo existente | AL=modo, DS:DX=ruta | CF=0, AX=handle / CF=1 |
| **3Eh** | CLOSE | Cerrar archivo | BX=handle | CF=0 (OK) / CF=1 (error) |
| **3Fh** | READ | Leer de archivo | BX=handle, CX=bytes, DS:DX=buffer | CF=0, AX=bytes leídos |
| **40h** | WRITE | Escribir a archivo | BX=handle, CX=bytes, DS:DX=buffer | CF=0, AX=bytes escritos |
| **4300h** | Get Attrs | Obtener atributos | DS:DX=ruta | CF=0, CX=atributos / CF=1 |
| **4C00h** | EXIT | Terminar programa | AL=código salida | - |

### Modos de Apertura (función 3Dh)

- **AL = 0:** Solo lectura
- **AL = 1:** Solo escritura
- **AL = 2:** Lectura/Escritura

---

## PROCEDIMIENTOS IMPLEMENTADOS

### Procedimientos de Salida

#### ImprimirCadena
- **Propósito:** Imprime una cadena terminada en '$' en pantalla
- **Entrada:** DX = puntero a cadena
- **Salida:** Ninguna
- **Registros preservados:** AX
- **Servicio usado:** INT 21h, AH=09h

#### ImprimirCRLF
- **Propósito:** Imprime salto de línea (CR + LF)
- **Entrada:** Ninguna
- **Salida:** Ninguna
- **Registros preservados:** AX, DX
- **Servicio usado:** INT 21h, AH=02h

#### ImprimirBuffer
- **Propósito:** Imprime CX bytes desde DS:SI
- **Entrada:** CX = número de bytes, SI = puntero al buffer
- **Salida:** Ninguna
- **Registros preservados:** AX, DX, CX, SI
- **Servicio usado:** INT 21h, AH=02h (en bucle)

### Procedimientos de Conversión

#### DosDigitos
- **Propósito:** Convierte un valor de 0-99 a 2 dígitos ASCII
- **Entrada:** AL = valor (0-99), DI = puntero destino
- **Salida:** [DI] y [DI+1] contienen dígitos ASCII, DI += 2
- **Técnica:** Usa instrucción AAM para separar decenas y unidades
- **Ejemplo:** AL=25 → [DI]='2', [DI+1]='5'

```assembly
DosDigitos PROC
    aam                     ; AH = AL/10, AL = AL%10
    add ah, '0'            ; Convertir a ASCII
    add al, '0'
    mov [di], ah           ; Decenas
    mov [di+1], al         ; Unidades
    add di, 2
    ret
DosDigitos ENDP
```

#### CuatroDigitos
- **Propósito:** Convierte un valor de 0-9999 a 4 dígitos ASCII
- **Entrada:** AX = valor (0-9999), DI = puntero destino
- **Salida:** 4 bytes en [DI], DI += 4
- **Técnica:** División sucesiva por 1000, 100, 10
- **Ejemplo:** AX=2025 → '2', '0', '2', '5'

#### ConstruirFecha
- **Propósito:** Construye fecha en formato DD/MM/AAAA + CRLF
- **Entrada:** Ninguna (obtiene fecha del sistema)
- **Salida:** bufferFecha contiene la fecha, longitudFecha con el tamaño
- **Formato:** "21/10/2025\r\n" (12 bytes)
- **Servicios usados:** INT 21h AH=2Ah, DosDigitos, CuatroDigitos

---

## VARIABLES DEL PROGRAMA

### Variables de Configuración

| Variable | Tipo | Tamaño | Descripción |
|----------|------|--------|-------------|
| `rutaDirectorio` | DB | 30 bytes | Ruta del directorio a crear |
| `rutaArchivo` | DB | 44 bytes | Ruta completa del archivo |

### Buffers de Trabajo

| Variable | Tipo | Tamaño | Descripción |
|----------|------|--------|-------------|
| `bufferFecha` | DB | 16 bytes | Buffer para construir fecha DD/MM/AAAA |
| `bufferLectura` | DB | 128 bytes | Buffer para leer contenido del archivo |

### Variables de Control

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `longitudFecha` | DW | Longitud en bytes de la fecha construida |
| `manejador` | DW | Handle del archivo abierto |
| `bytesLeidos` | DW | Cantidad de bytes leídos del archivo |

### Mensajes del Programa

| Variable | Contenido |
|----------|-----------|
| `msgEncabezado` | "ACTIVIAD05_PBN - Directorios y Archivos" |
| `msgCrearDir` | "Creando directorio: C:\emu8086\MyBuild\Rodrigo" |
| `msgDirCreado` | "Directorio creado (o ya existente)." |
| `msgDirExiste` | "Directorio existente, la bandera CF se ha activado." |
| `msgDirErrorCF` | "ERROR al crear directorio, la bandera CF se ha activado." |
| `msgCrearArchivo` | "Creando archivo y escribiendo fecha..." |
| `msgArchivoOk` | "Escritura OK." |
| `msgArchivoExiste` | "Archivo existente (CREATE falló), CF activada..." |
| `msgArchivoError` | "ERROR al crear/escribir/cerrar archivo." |
| `msgLeerArchivo` | "Leyendo archivo..." |
| `msgContenidoLeido` | "Contenido leido:" |
| `msgLeerError` | "ERROR al abrir/leer archivo." |
| `msgArchivoVacio` | "Aviso: el archivo esta vacio." |
| `msgFin` | "Fin del programa." |

---

## MANEJO DE ERRORES

### Detección de Errores mediante Bandera CF

El programa implementa un sistema robusto de detección de errores basado en la **bandera CF (Carry Flag)**. Cuando un servicio DOS falla, activa CF=1 y coloca un código de error en AX.

### Estrategias de Manejo

#### 1. Creación de Directorio

**Flujo:**
```
MKDIR (39h)
   ↓
CF=0? → Éxito: "Directorio creado"
   ↓
CF=1? → Get File Attributes (4300h)
   ↓
CF=0? → "Directorio existente, CF activada"
   ↓
CF=1? → "ERROR al crear directorio, CF activada"
```

**Código:**
```assembly
mov ah, 39h
int 21h
jnc DIR_CREADO              ; CF=0, directorio creado

; CF=1, verificar si existe
mov ax, 4300h
int 21h
jc DIR_ERROR_CF             ; No existe, error real
; Existe, notificar
lea dx, msgDirExiste
call ImprimirCadena
jmp DESPUES_DIR

DIR_ERROR_CF:
lea dx, msgDirErrorCF
call ImprimirCadena
jmp DESPUES_DIR

DIR_CREADO:
lea dx, msgDirCreado
call ImprimirCadena
```

#### 2. Creación de Archivo

**Estrategia de Doble Intento:**

Si CREATE (3Ch) falla, el programa intenta OPEN (3Dh) con modo lectura/escritura:

```assembly
mov ah, 3Ch                 ; CREATE
int 21h
jc INTENTAR_ABRIR_ESCRITURA ; CF=1, falló
mov [manejador], ax
jmp HACER_ESCRITURA

INTENTAR_ABRIR_ESCRITURA:
mov al, 2                   ; Modo R/W
mov ah, 3Dh                 ; OPEN
int 21h
jc ARCHIVO_ERROR            ; CF=1, error real
mov [manejador], ax
lea dx, msgArchivoExiste
call ImprimirCadena
```

#### 3. Verificación de Bytes Escritos

Para detectar errores como **disco lleno**, el programa verifica que los bytes escritos coincidan con los esperados:

```assembly
mov ah, 40h                 ; WRITE
int 21h
jc ARCHIVO_ERROR_CERRAR     ; CF=1, error de escritura

; Verificar bytes escritos
cmp ax, cx                  ; AX=escritos, CX=esperados
jne ARCHIVO_ERROR_CERRAR    ; No coinciden, error
```

#### 4. Detección de Archivo Vacío

```assembly
mov ax, [bytesLeidos]
cmp ax, 0
je ARCHIVO_VACIO            ; 0 bytes, archivo vacío

; Mostrar contenido...
```

#### 5. Cierre Garantizado en Errores

```assembly
ARCHIVO_ERROR_CERRAR:
    push ax                 ; Preservar código de error
    mov bx, [manejador]
    mov ah, 3Eh            ; Cerrar archivo
    int 21h
    pop ax                 ; Recuperar código
    ; Continuar con manejo de error...
```

### Tabla de Códigos de Error Comunes

| Código (AX) | Descripción |
|-------------|-------------|
| 02h | Archivo no encontrado |
| 03h | Ruta no encontrada |
| 04h | Demasiados archivos abiertos |
| 05h | Acceso denegado |
| 06h | Handle inválido |
| 50h | Archivo ya existe |

---

## RESULTADOS Y PRUEBAS

### Caso de Prueba 1: Primera Ejecución

**Condiciones iniciales:**
- Directorio `C:\emu8086\MyBuild\Rodrigo` no existe
- Archivo `Torres.txt` no existe
- Fecha del sistema: 21/10/2025

**Resultado esperado:**
```
ACTIVIAD05_PBN - Directorios y Archivos

Creando directorio: C:\emu8086\MyBuild\Rodrigo
Directorio creado (o ya existente).

Creando archivo y escribiendo fecha...
Escritura OK.

Leyendo archivo...
Contenido leido:
21/10/2025

Fin del programa.
```

**Verificación:**
- ✅ Directorio creado exitosamente
- ✅ Archivo `Torres.txt` creado con contenido "21/10/2025\r\n"
- ✅ Contenido mostrado correctamente en pantalla

### Caso de Prueba 2: Ejecución con Directorio Existente

**Condiciones iniciales:**
- Directorio `C:\emu8086\MyBuild\Rodrigo` ya existe
- Archivo `Torres.txt` no existe

**Resultado esperado:**
```
ACTIVIAD05_PBN - Directorios y Archivos

Creando directorio: C:\emu8086\MyBuild\Rodrigo
Directorio existente, la bandera CF se ha activado.

Creando archivo y escribiendo fecha...
Escritura OK.

Leyendo archivo...
Contenido leido:
21/10/2025

Fin del programa.
```

**Verificación:**
- ✅ Detecta directorio existente correctamente
- ✅ Muestra mensaje de CF activada
- ✅ Continúa con creación de archivo sin errores

### Caso de Prueba 3: Ejecución con Archivo Existente

**Condiciones iniciales:**
- Directorio y archivo ya existen
- Archivo contiene fecha anterior: "20/10/2025\r\n"

**Resultado esperado:**
```
ACTIVIAD05_PBN - Directorios y Archivos

Creando directorio: C:\emu8086\MyBuild\Rodrigo
Directorio existente, la bandera CF se ha activado.

Creando archivo y escribiendo fecha...
Archivo existente (CREATE fallo), la bandera CF se ha activado. Se abrira para escribir.
Escritura OK.

Leyendo archivo...
Contenido leido:
21/10/2025

Fin del programa.
```

**Verificación:**
- ✅ Detecta archivo existente
- ✅ Abre archivo para sobrescribir
- ✅ Fecha actualizada correctamente

### Validación del Archivo Generado

El archivo `Torres.txt` puede ser abierto con cualquier editor de texto (Notepad, Notepad++, etc.) y debe mostrar:

```
21/10/2025
```

**Análisis hexadecimal del archivo:**
```
32 31 2F 31 30 2F 32 30 32 35 0D 0A
 2  1  /  1  0  /  2  0  2  5 CR LF
```

---

## CONCLUSIONES

### Logros Alcanzados

1. **Implementación Exitosa:** Se desarrolló un programa funcional en lenguaje ensamblador que cumple con todos los objetivos planteados, demostrando capacidad de:
   - Crear directorios en el sistema de archivos
   - Crear y escribir archivos de texto
   - Leer y mostrar contenido de archivos
   - Obtener y formatear la fecha del sistema

2. **Manejo Robusto de Errores:** Se implementó un sistema completo de detección y manejo de errores mediante la bandera CF, proporcionando mensajes descriptivos para cada situación:
   - Directorio existente vs. error de creación
   - Archivo existente vs. error de creación
   - Validación de bytes escritos
   - Detección de archivos vacíos
   - Cierre garantizado de recursos

3. **Código Didáctico:** La estructura del programa siguiendo el patrón Datos → Procedimientos → Código Principal, junto con nomenclatura en español y comentarios exhaustivos, facilita su comprensión y uso como material educativo.

4. **Modularización Efectiva:** Los 6 procedimientos implementados (ImprimirCadena, ImprimirCRLF, ImprimirBuffer, DosDigitos, CuatroDigitos, ConstruirFecha) demuestran buenas prácticas de:
   - Reutilización de código
   - Preservación de registros
   - Separación de responsabilidades
   - Documentación clara

5. **Conversión Numérica:** Se aplicaron exitosamente técnicas de conversión hexadecimal/binario a ASCII:
   - Instrucción AAM para números de 2 dígitos
   - División sucesiva para números de 4 dígitos
   - Construcción de cadenas formateadas

### Aprendizajes Clave

1. **Programación de Bajo Nivel:** Se profundizó en el entendimiento de cómo los programas interactúan directamente con el sistema operativo sin capas de abstracción.

2. **Interrupciones del Sistema:** Se adquirió experiencia práctica con múltiples servicios DOS (INT 21h), comprendiendo:
   - Convenciones de paso de parámetros en registros
   - Uso de banderas de estado (CF)
   - Manejo de handles de archivos
   - Modos de acceso a archivos

3. **Gestión de Recursos:** Se aplicaron principios de buena gestión de recursos:
   - Apertura y cierre correcto de archivos
   - Liberación de recursos incluso en caso de error
   - Uso eficiente de memoria (buffers apropiados)

4. **Compatibilidad DOS:** Se comprendió el modelo de programas .COM:
   - Restricciones de tamaño (64KB)
   - Estructura de segmento único
   - Importancia de ORG 100h
   - Necesidad de JMP inicial para evitar ejecutar datos

### Aplicaciones Prácticas

Este tipo de programación tiene aplicaciones en:

- **Sistemas Embebidos:** Donde se requiere control directo del hardware
- **Bootloaders:** Programas que inician antes del sistema operativo
- **Drivers de Dispositivos:** Control de bajo nivel de hardware
- **Optimización:** Código crítico que requiere máximo rendimiento
- **Comprensión de Sistemas:** Base para entender sistemas operativos modernos

### Limitaciones Identificadas

1. **Portabilidad:** El código es específico para DOS/x86, no portable a sistemas modernos sin emulación
2. **Formato de Fecha:** Limitado a DD/MM/AAAA sin hora ni zona horaria
3. **Tamaño de Buffer:** Lectura limitada a 128 bytes (adecuado para este caso, pero podría ampliarse)
4. **Sin Interfaz Gráfica:** Programa de línea de comandos puro
5. **Mensajes sin Tildes:** Para compatibilidad con CP437 (juego de caracteres DOS)

### Mejoras Futuras

1. **Agregar Hora:** Incluir INT 21h función 2Ch para obtener y escribir la hora actual
2. **Parámetros de Línea de Comandos:** Permitir especificar rutas personalizadas
3. **Menú Interactivo:** Ofrecer opciones como crear, leer, eliminar archivos
4. **Validación de Rutas:** Verificar que las rutas no excedan el directorio de trabajo seguro
5. **Listar Directorio:** Implementar INT 21h funciones 4Eh/4Fh para mostrar archivos del directorio
6. **Formato Extendido:** Agregar día de la semana y formato 12/24 horas
7. **Codificación de Errores:** Mostrar el código de error hexadecimal cuando ocurre un fallo

### Reflexión Final

Este proyecto demuestra que, aunque la programación en lenguaje ensamblador requiere mayor esfuerzo y atención al detalle comparado con lenguajes de alto nivel, proporciona un entendimiento profundo del funcionamiento interno de las computadoras. 

El dominio de conceptos como interrupciones, banderas de estado, manejo de memoria y registros es fundamental para cualquier profesional en ciencias de la computación, especialmente en áreas de sistemas operativos, arquitectura de computadoras y optimización de código.

La experiencia adquirida en este proyecto sirve como base sólida para:
- Comprender mejor cómo funcionan lenguajes de alto nivel "por debajo"
- Diagnosticar problemas de rendimiento en aplicaciones
- Desarrollar código más eficiente
- Apreciar las abstracciones que proporcionan los sistemas modernos

---

## REFERENCIAS

### Documentación Técnica

1. **Intel 8086 Family User's Manual**  
   Intel Corporation, 1981  
   Referencia oficial del procesador 8086

2. **MS-DOS Programmer's Reference**  
   Microsoft Corporation, 1991  
   Documentación de servicios DOS INT 21h

3. **The Art of Assembly Language Programming**  
   Randall Hyde, 2003  
   No Starch Press  
   ISBN: 978-1886411975

4. **PC Assembly Language**  
   Paul A. Carter, 2006  
   Documento libre disponible en línea

### Recursos en Línea

5. **Emu8086 Documentation**  
   http://www.emu8086.com/  
   Manual oficial del emulador Emu8086

6. **INT 21h DOS Services**  
   Ralph Brown's Interrupt List  
   http://www.ctyme.com/intr/int-21.htm

7. **x86 Assembly Guide**  
   University of Virginia Computer Science  
   https://www.cs.virginia.edu/~evans/cs216/guides/x86.html

### Archivos del Proyecto

8. **ACTIVIAD05_PBN.asm**  
   Código fuente principal del programa

9. **ACTIVIAD05_PBN_DiagramaFlujo.txt**  
   Diagrama de flujo detallado con tablas de referencia

10. **README.md**  
    Documentación del proyecto en formato Markdown

### Archivos de Referencia (Proporcionados)

11. **BorraDirectorio.asm**  
    Referencia para eliminación de directorios

12. **BuscaArchivo.asm**  
    Referencia para búsqueda de archivos

13. **CrearArchivo.asm**  
    Referencia para creación de archivos

14. **CrearDirectorio.asm**  
    Referencia para creación de directorios

15. **LeerArchivo.asm**  
    Referencia para lectura de archivos

16. **ObtenerFecha.asm**  
    Referencia para obtención de fecha del sistema

17. **ObtenerHora.asm**  
    Referencia para obtención de hora del sistema

---

**Fin del Reporte**

---

*Este documento fue generado como parte del proyecto ACTIVIDAD05_PBN de la materia de Lenguaje Ensamblador.*

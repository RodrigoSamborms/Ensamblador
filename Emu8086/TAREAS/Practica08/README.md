# Generador de Archivo .LST para Ensamblador 8086

**Autor:** Rodrigo Torres Rivera

## Descripción

Este programa Python genera archivos `.lst` (listado) a partir de archivos `.asm` (ensamblador 8086), mostrando las direcciones de memoria en hexadecimal para cada instrucción válida.

## Requisitos

- **Python 3.6+**
- Archivo `TABOP.txt` en el mismo directorio (contiene lista de instrucciones válidas del 8086)

## Archivos

- `generador_lst.py` - Programa principal (850+ líneas con comentarios detallados)
- `TABOP.txt` - Tabla de instrucciones válidas del 8086 (115 instrucciones)

## Características

✅ **Validación de instrucciones**: Verifica que cada instrucción sea válida usando la tabla TABOP
✅ **Cálculo de dirección**: Calcula automáticamente la dirección de memoria en hexadecimal (4 dígitos)
✅ **Cálculo de tamaño**: 
   - Instrucciones sin operandos: 1 byte
   - Por cada operando (separado por coma): +1 byte
   - Ejemplo: `MOV AX, BX` → 3 bytes (1 base + 2 operandos)

✅ **Detección inteligente**: Ignora automáticamente:
   - Comentarios
   - Directivas (ORG, INCLUDE, etc)
   - Definiciones de datos (DB, DW, DS)
   - Etiquetas
   - Macros

✅ **Formato claro**: Salida con número de línea, dirección en hex, e instrucción

---

## Documentación Detallada del Código

### Estructura del Programa

```
generador_lst.py
├── Clase GeneradorLST
│   ├── __init__()
│   ├── cargar_tabop()
│   ├── es_instruccion_valida()
│   ├── calcular_tamano_instruccion()
│   ├── procesar_archivo_asm()
│   ├── generar_archivo_lst()
│   └── ejecutar()
├── main()
└── if __name__ == '__main__'
```

---

### Módulo 1: Inicialización (`__init__`)

**Propósito:** Preparar la instancia para procesamiento.

```python
def __init__(self):
    self.instrucciones_validas = set()
    self.cargar_tabop()
```

**Qué hace:**
1. Crea un conjunto vacío (`set()`) para almacenar instrucciones válidas
2. Llama a `cargar_tabop()` para poblarlo con datos de TABOP.txt

**Por qué usar `set`:**
- Búsquedas O(1) = muy rápida (millones de búsquedas)
- Ideal para verificar membresía: `"MOV" in conjunto`
- Alternativa: usar `list` sería O(n) = lento

**Ejemplo:**
```python
gen = GeneradorLST()  # Automáticamente carga TABOP.txt
```

---

### Módulo 2: Cargar Tabla de Operaciones (`cargar_tabop`)

**Propósito:** Leer y validar el archivo TABOP.txt.

```python
def cargar_tabop(self):
    # 1. Buscar archivo en múltiples ubicaciones
    script_dir = os.path.dirname(os.path.abspath(__file__))
    rutas_posibles = [
        os.path.join(script_dir, 'TABOP.txt'),  # Dir del script
        'TABOP.txt',                             # Dir actual
        os.path.join(os.getcwd(), 'TABOP.txt')   # Working directory
    ]
    
    # 2. Encontrar primer archivo existente
    archivo_tabop = None
    for ruta in rutas_posibles:
        if os.path.exists(ruta):
            archivo_tabop = ruta
            break
    
    # 3. Si no encontró, terminar
    if not archivo_tabop:
        print("Error: No se encontró archivo TABOP.txt")
        sys.exit(1)
    
    # 4. Cargar instrucciones
    try:
        with open(archivo_tabop, 'r', encoding='utf-8') as f:
            for linea in f:
                linea = linea.strip()
                if linea and not linea.startswith('#'):
                    self.instrucciones_validas.add(linea.upper())
        print(f"✓ Cargadas {len(self.instrucciones_validas)} instrucciones válidas")
    except Exception as e:
        print(f"Error al leer TABOP.txt: {e}")
        sys.exit(1)
```

**Proceso paso a paso:**

1. **Obtener directorio del script:**
   ```python
   script_dir = os.path.dirname(os.path.abspath(__file__))
   # __file__ = "/home/user/generador_lst.py"
   # dirname = "/home/user"
   ```

2. **Construir lista de rutas a intentar:**
   - Misma carpeta que el script
   - Carpeta actual de ejecución
   - Directorio de trabajo actual

3. **Buscar archivo:**
   ```python
   # Busca en orden hasta encontrar uno existente
   for ruta in rutas_posibles:
       if os.path.exists(ruta):  # ¿Existe?
           archivo_tabop = ruta
           break
   ```

4. **Validar existencia:**
   - Si no encontró → Error y termina
   - Si encontró → Continúa

5. **Leer línea por línea:**
   ```python
   with open(...) as f:
       for linea in f:
           linea = linea.strip()  # "MOV\n" → "MOV"
           if linea and not linea.startswith('#'):  # Ignora vacías y comentarios
               self.instrucciones_validas.add(linea.upper())  # Mayúsculas
   ```

**Ejemplo de TABOP.txt:**
```
MOV
ADD
SUB
# Este es un comentario
JMP
```

**Resultado en memoria:**
```python
self.instrucciones_validas = {"MOV", "ADD", "SUB", "JMP", ...}
# Total: 115 instrucciones
```

---

### Módulo 3: Validar Instrucción (`es_instruccion_valida`)

**Propósito:** Verificar si una mnemónica es válida del 8086.

```python
def es_instruccion_valida(self, mnemonica):
    return mnemonica.upper() in self.instrucciones_validas
```

**Cómo funciona:**
1. Convierte a mayúsculas (case-insensitive)
2. Busca en conjunto (O(1))
3. Retorna True/False

**Ejemplos:**
```python
gen.es_instruccion_valida('mov')    # True
gen.es_instruccion_valida('MOV')    # True
gen.es_instruccion_valida('print')  # False (macro, no 8086)
gen.es_instruccion_valida('xyz')    # False (no existe)
```

---

### Módulo 4: Calcular Tamaño (`calcular_tamano_instruccion`)

**Propósito:** Determinar bytes ocupados por una instrucción.

**Algoritmo:**

```python
def calcular_tamano_instruccion(self, linea):
    linea = linea.strip()
    
    # PASO 1: Validar que no sea vacía ni comentario
    if not linea or linea.startswith(';'):
        return None
    
    # PASO 2: Separar mnemónica de operandos
    # split(None, 1) = dividir en primer espacio máximo 1 vez
    partes = linea.split(None, 1)
    # "mov ah, 47h" → ["mov", "ah, 47h"]
    # "nop" → ["nop"]
    
    mnemonica = partes[0].upper()
    
    # PASO 3: Validar mnemónica
    if not self.es_instruccion_valida(mnemonica):
        return None
    
    # PASO 4: Calcular tamaño base (siempre 1)
    tamano = 1
    
    # PASO 5: Añadir bytes por operandos
    if len(partes) > 1:
        operandos = partes[1]  # "ah, 47h"
        # Contar comas: número_operandos = comas + 1
        num_operandos = operandos.count(',') + 1  # 1 coma → 2 operandos
        tamano += num_operandos
    
    return tamano
```

**Ejemplos de cálculo:**

```
"nop"           → partes=["nop"]          → 1 byte
"push ax"       → partes=["push","ax"]    → 1 + 1 = 2 bytes
"mov ax, bx"    → partes=["mov","ax,bx"]  → 1 + 2 = 3 bytes
"cmp ax, 10h"   → partes=["cmp","ax,10h"] → 1 + 2 = 3 bytes
"add al, [si]"  → partes=["add","al,[si]"] → 1 + 2 = 3 bytes
"print"         → no es válida            → None
```

**Fórmula final:**
```
tamaño = 1 (instrucción) + número_de_operandos
```

**Nota importante:**
- El cálculo es estimado
- No usa tamaño real en bytes de máquina
- Funciona para la mayoría de instrucciones 8086
- Útil para direccionamiento incremental

---

### Módulo 5: Procesar Archivo (`procesar_archivo_asm`)

**Propósito:** Analizar todo el archivo .asm línea por línea.

**Flujo de procesamiento:**

```
Archivo de entrada
     ↓
Leer línea por línea
     ↓
Clasificar línea (comentario, directiva, etiqueta, instrucción)
     ↓
Si es instrucción:
   - Calcular tamaño
   - Asignar dirección de memoria
   - Incrementar dirección para próxima
     ↓
Guardar información de línea en lista
     ↓
Retornar lista de diccionarios
```

**Ejemplo paso a paso:**

```
Línea 1: "org 100h"           → Directiva, ignorar
Línea 2: "jmp inicio"         → Instrucción: DIR=0000, tamaño=2, sig_DIR=2
Línea 3: ""                   → Vacía, ignorar
Línea 4: "mov ah, 47h"        → Instrucción: DIR=0002, tamaño=3, sig_DIR=5
Línea 5: "int 21h"            → Instrucción: DIR=0005, tamaño=2, sig_DIR=7
Línea 6: "lea si, buffer"     → Instrucción: DIR=0007, tamaño=3, sig_DIR=10 (hex 0A)
```

**Código pseudocódigo:**

```python
def procesar_archivo_asm(self, ruta_asm):
    lineas_procesadas = []
    direccion = 0  # Contador de bytes
    numero_linea = 1
    
    for linea_bruta in archivo:
        linea = linea_bruta.rstrip('\n\r')
        linea_stripped = linea.strip()
        
        # ¿Es vacía o comentario?
        if not linea_stripped or linea_stripped.startswith(';'):
            procesadas.append({numero: numero_linea, direccion: None, ...})
            numero_linea += 1
            continue
        
        # ¿Es directiva?
        if linea_stripped.upper().startswith(('ORG', 'INCLUDE', ...)):
            procesadas.append({numero: numero_linea, direccion: None, ...})
            numero_linea += 1
            continue
        
        # ¿Tiene db/dw/ds? (datos)
        if ' db ' in linea_stripped.lower() or ...:
            procesadas.append({numero: numero_linea, direccion: None, ...})
            numero_linea += 1
            continue
        
        # ¿Es etiqueta?
        if ':' in linea_stripped:
            procesadas.append({numero: numero_linea, direccion: None, ...})
            numero_linea += 1
            continue
        
        # PROCESAR COMO INSTRUCCIÓN
        tamano = calcular_tamano_instruccion(linea_stripped)
        
        if tamano is not None:  # Instrucción válida
            direccion_hex = f"{direccion:04X}"  # Convertir a hex
            procesadas.append({
                numero: numero_linea,
                direccion: direccion,
                direccion_hex: direccion_hex,
                es_instruccion: True,
                valida: True,
                tamano: tamano
            })
            direccion += tamano  # IMPORTANTE: Incrementar
        else:  # Instrucción inválida
            procesadas.append({
                numero: numero_linea,
                direccion: None,
                es_instruccion: True,
                valida: False
            })
        
        numero_linea += 1
    
    return procesadas
```

**Estructura de diccionario retornado:**

```python
{
    'numero': 5,                    # Número de línea original
    'direccion': 7,                 # Dirección en decimal
    'direccion_hex': '0007',        # Dirección en hex (4 dígitos)
    'contenido': 'lea si, buffer',  # Texto original
    'es_instruccion': True,         # Es un intento de instrucción
    'valida': True,                 # Pasa validación
    'tamano': 3                     # Bytes que ocupa
}
```

---

### Módulo 6: Generar Archivo `.lst` (`generar_archivo_lst`)

**Propósito:** Crear archivo formateado con direcciones y código (formato simplificado).

**Estructura del archivo:**

```
================================================
LOC    MACHINE CODE         SOURCE              
================================================
0000   6A 6B                jmp Principal
0002   70 71                push ax
0004   70 71                push dx
0006   70 71                push si
0008   6D 6E 6F             mov dl, 0
000B   6C 6D 6E             lea si, buffer_dir
000E   69 6A                int 21h
================================================
```

**Características del formato:**

- **LOC**: Dirección de memoria en hexadecimal (4 dígitos)
- **MACHINE CODE**: Código hexadecimal simulado de la instrucción
- **SOURCE**: Código fuente original (sin comentarios)
- Solo incluye instrucciones válidas
- Ignora comentarios, directivas, etiquetas y datos

**Código:**

```python
def generar_archivo_lst(self, ruta_asm, lineas_procesadas):
    # Construir nombre de salida
    nombre_base = os.path.splitext(ruta_asm)[0]
    # "archivo.asm" → "archivo"
    ruta_lst = nombre_base + '.lst'
    # "archivo.lst"
    
    try:
        with open(ruta_lst, 'w', encoding='utf-8') as f:
            # ENCABEZADO
            f.write("=" * 48 + "\n")
            f.write(f"{'LOC':<6} {'MACHINE CODE':<20} {'SOURCE':<20}\n")
            f.write("=" * 48 + "\n")
            
            # PROCESAR SOLO INSTRUCCIONES VÁLIDAS
            for item in lineas_procesadas:
                # Solo procesar instrucciones válidas
                if item['es_instruccion'] and item['valida']:
                    contenido = item['contenido'].strip()
                    direccion_hex = item['direccion_hex']
                    
                    # Generar código máquina simulado
                    tamano = item['tamano']
                    machine_code = ' '.join([f"{(i + ord(contenido[0]))%256:02X}" 
                                            for i in range(tamano)])
                    
                    # Escribir línea
                    f.write(f"{direccion_hex:<6} {machine_code:<20} {contenido}\n")
            
            # PIE
            f.write("=" * 48 + "\n")
    
    except Exception as e:
        print(f"Error al escribir archivo .lst: {e}")
        return False
    
    return ruta_lst
```

**Especificación de formato:**

```
LOC    MACHINE_CODE    SOURCE
│      │               │
4dígits Hex bytes      Instrucción
hex     por tamaño     completa
```

**Ventajas del formato simplificado:**
- Compacto y fácil de leer
- Enfoque en lo esencial (dirección y código)
- Solo instrucciones ejecutables válidas
- Facilita análisis rápido del flujo de código

---

### Módulo 7: Ejecutar (`ejecutar`)

**Propósito:** Interfaz de usuario principal.

**Flujo:**

```
1. Mostrar encabezado
        ↓
2. BUCLE: Solicitar archivo .asm
        ↓
   ¿Es válido?
   ├─ No → Volver a preguntar
   └─ Sí → Salir del bucle
        ↓
3. Procesar archivo
        ↓
4. Mostrar estadísticas
        ↓
5. Generar .lst
        ↓
6. Mostrar confirmación
```

**Ejemplo de interacción:**

```
============================================================
GENERADOR DE ARCHIVO .LST PARA ENSAMBLADOR 8086
Autor: Rodrigo Torres Rivera
============================================================

Ingrese la ruta del archivo .asm (o 'salir' para terminar): archivo.txt
Error: El archivo debe tener extensión .asm
Ingrese la ruta del archivo .asm (o 'salir' para terminar): archivo.asm

Procesando: archivo.asm
✓ Cargadas 115 instrucciones válidas
✓ Procesadas 50 líneas
✓ Instrucciones válidas: 35
⚠ Instrucciones inválidas: 2
✓ Archivo generado: archivo.lst

```

---

### Función Main y Protección de Script

```python
def main():
    """Instancia GeneradorLST y ejecuta"""
    generador = GeneradorLST()  # Carga TABOP.txt aquí
    generador.ejecutar()        # Inicia interfaz usuario

if __name__ == '__main__':
    """Solo se ejecuta si se corre directamente"""
    main()
```

**¿Por qué `if __name__ == '__main__'`?**

Permite dos formas de uso:

**Opción 1: Script directo**
```bash
$ python generador_lst.py
# Ejecuta main() automáticamente
```

**Opción 2: Módulo importado**
```python
from generador_lst import GeneradorLST

gen = GeneradorLST()
gen.ejecutar()
# No ejecuta main() automáticamente
```

---

## Uso

### Ejecución interactiva

```bash
python generador_lst.py
```

El programa pedirá:
1. **Ruta del archivo .asm** (relativa o absoluta)
2. Genera automáticamente el archivo `.lst` con el mismo nombre

### Ejemplo

```
============================================================
GENERADOR DE ARCHIVO .LST PARA ENSAMBLADOR 8086
Autor: Rodrigo Torres Rivera
============================================================

Ingrese la ruta del archivo .asm (o 'salir' para terminar): .\Prt08Example.asm

Procesando: .\Prt08Example.asm
✓ Cargadas 115 instrucciones válidas
✓ Procesadas 1204 líneas
✓ Instrucciones válidas: 712
⚠ Instrucciones inválidas: 8
✓ Archivo generado: .\Prt08Example.lst
```

### Ejemplo de archivo .lst generado

**Entrada (Prt08Example.asm):**
```asm
include 'emu8086.inc'
org 100h

jmp Principal
push ax
push dx
lea si, buffer_dir
int 21h
...
```

**Salida (Prt08Example.lst):**
```
================================================
LOC    MACHINE CODE         SOURCE              
================================================
0000   6A 6B                jmp Principal
0002   70 71                push ax
0004   70 71                push dx
0006   70 71                push si
0008   6D 6E 6F             mov dl, 0
000B   6C 6D 6E             lea si, buffer_dir
000E   69 6A                int 21h
================================================
```

**Columnas:**
- **LOC**: Dirección de memoria en hexadecimal (4 dígitos)
- **MACHINE CODE**: Representación hexadecimal de la instrucción
- **SOURCE**: Código fuente (solo instrucciones válidas, sin comentarios)

## Instrucciones válidas (TABOP)

El programa reconoce 115 instrucciones del 8086:

AAA, AAD, AAM, AAS, ADC, ADD, AND, CALL, CBW, CLC, CLD, CLI, CMC, CMP, CMPSB, CMPSW, CWD, DAA, DAS, DEC, DIV, HLT, IDIV, IMUL, IN, INC, INT, INTO, IRET, JA, JAE, JB, JBE, JC, JCXZ, JE, JG, JGE, JL, JLE, JMP, JNA, JNAE, JNB, JNBE, JNC, JNE, JNG, JNGE, JNL, JNLE, JNO, JNP, JNS, JNZ, JO, JP, JPE, JPO, JS, JZ, LAHF, LDS, LEA, LES, LODSB, LODSW, LOOP, LOOPE, LOOPNE, LOOPNZ, LOOPZ, MOV, MOVSB, MOVSW, MUL, NEG, NOP, NOT, OR, OUT, POP, POPA, POPF, PUSH, PUSHF, RCL, RCR, REP, REPE, REPNE, REPNZ, REPZ, RET, RETF, ROL, ROR, SAHF, SAL, SAR, SBB, SCASB, SCASW, SHL, SHR, STC, STD, STI, STOSB, STOSW, SUB, TEST, XCHG, XLATB, XOR

## Notas importantes

- ⚠️ Las macros (como `print`, `printn`) se marcarán como instrucciones inválidas (esto es correcto)
- ⚠️ Las definiciones de datos (DB, DW, DS) NO se consideran instrucciones ejecutables
- ✓ El cálculo de tamaño se basa en conteo de operandos, no en el tamaño real de cada instrucción
- ✓ Los direcciones se calculan de forma incremental basándose en tamaños estimados

## Troubleshooting

**Error: "No se encontró archivo TABOP.txt"**
- Verifica que `TABOP.txt` esté en el mismo directorio que `generador_lst.py`
- O en el directorio actual desde donde ejecutas el script

**Error: "Archivo no encontrado"**
- Verifica la ruta ingresada
- Usa rutas relativas (ej: `.\archivo.asm`) o absolutas
- Asegúrate de que el archivo tenga extensión `.asm`

## Licencia

Para uso educativo - Materia de Ensamblador

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
GENERADOR DE ARCHIVO .LST PARA ENSAMBLADOR 8086
================================================================================
Autor: Rodrigo Torres Rivera
Propósito: Generar archivos de listado (.lst) a partir de código ensamblador
          (.asm) para el microprocesador Intel 8086, mostrando las direcciones
          de memoria en hexadecimal para cada instrucción válida.

Módulos principales:
  - GeneradorLST: Clase principal que gestiona todo el proceso
  - cargar_tabop(): Carga las instrucciones válidas desde TABOP.txt
  - calcular_tamano_instruccion(): Determina bytes ocupados por cada instrucción
  - procesar_archivo_asm(): Analiza línea por línea el archivo .asm
  - generar_archivo_lst(): Crea el archivo de salida .lst
  - ejecutar(): Interfaz de usuario principal
================================================================================
"""

import os
import sys

class GeneradorLST:
    """Clase para generar archivos .lst a partir de archivos .asm"""
    
    def __init__(self):
        """
        INICIALIZADOR DE LA CLASE
        
        Propósito:
            Preparar la instancia de GeneradorLST para procesamiento.
            Se cargan las instrucciones válidas desde TABOP.txt.
        
        Variables inicializadas:
            - self.instrucciones_validas (set): Conjunto de mnemonics válidas
              Tipo: set() para búsqueda O(1) eficiente
        
        Proceso:
            1. Crear conjunto vacío de instrucciones
            2. Llamar a cargar_tabop() para poblarlo
        """
        self.instrucciones_validas = set()
        self.cargar_tabop()
        
    def cargar_tabop(self):
        """
        MÓDULO: CARGAR TABLA DE OPERACIONES
        
        Propósito:
            Cargar la lista de instrucciones válidas del 8086 desde el archivo
            TABOP.txt. Este archivo contiene una mnemónica por línea.
        
        Proceso:
            1. Buscar TABOP.txt en múltiples ubicaciones:
               - Mismo directorio que el script
               - Directorio actual de ejecución
               - Directorio de trabajo (cwd)
            
            2. Si encuentra el archivo:
               - Abre el archivo en modo lectura (utf-8)
               - Itera por cada línea
               - Ignora líneas vacías y comentarios (#)
               - Convierte a mayúsculas y añade al conjunto
            
            3. Si no encuentra:
               - Imprime error
               - Termina el programa (sys.exit(1))
        
        Variables:
            - archivo_tabop: Ruta del archivo encontrado (string o None)
            - rutas_posibles: Lista de rutas a intentar (list)
        
        Salida en consola:
            - ✓ Cargadas N instrucciones válidas (si éxito)
            - Error: No se encontró archivo TABOP.txt (si fallo)
        
        Excepciones manejadas:
            - FileNotFoundError: Archivo no existe
            - IOError: Problemas al leer
            - Cualquier Exception: Capturada genéricamente
        """
        # Obtener directorio del script actual
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Lista de ubicaciones donde buscar TABOP.txt (orden de prioridad)
        rutas_posibles = [
            os.path.join(script_dir, 'TABOP.txt'),  # Mismo dir que script
            'TABOP.txt',                             # Dir actual
            os.path.join(os.getcwd(), 'TABOP.txt')   # Directorio de trabajo
        ]
        
        # Buscar el archivo en todas las rutas posibles
        archivo_tabop = None
        for ruta in rutas_posibles:
            if os.path.exists(ruta):
                archivo_tabop = ruta
                break
        
        # Si no encontró el archivo, terminar
        if not archivo_tabop:
            print("Error: No se encontró archivo TABOP.txt")
            print(f"Se buscó en: {rutas_posibles}")
            sys.exit(1)
        
        # Intentar cargar el archivo
        try:
            with open(archivo_tabop, 'r', encoding='utf-8') as f:
                for linea in f:
                    linea = linea.strip()  # Eliminar espacios/saltos
                    # Ignorar líneas vacías y comentarios
                    if linea and not linea.startswith('#'):
                        # Convertir a mayúsculas para búsqueda case-insensitive
                        self.instrucciones_validas.add(linea.upper())
            # Imprimir estadística de carga
            print(f"✓ Cargadas {len(self.instrucciones_validas)} instrucciones válidas")
        except Exception as e:
            print(f"Error al leer TABOP.txt: {e}")
            sys.exit(1)
    
    def es_instruccion_valida(self, mnemonica):
        """
        MÓDULO: VALIDAR INSTRUCCIÓN
        
        Propósito:
            Verificar si una mnemónica dada es una instrucción válida del 8086.
        
        Entrada:
            - mnemonica (str): Nombre de instrucción a validar
        
        Retorna:
            - bool: True si está en TABOP, False en caso contrario
        
        Lógica:
            Búsqueda en conjunto (O(1)) es muy eficiente para miles de búsquedas.
            Se convierte a mayúsculas para búsqueda case-insensitive.
        
        Ejemplo:
            es_instruccion_valida('mov') → True
            es_instruccion_valida('MOV') → True
            es_instruccion_valida('print') → False (es macro, no 8086)
        """
        return mnemonica.upper() in self.instrucciones_validas
    
    def calcular_tamano_instruccion(self, linea):
        """
        MÓDULO: CALCULAR TAMAÑO DE INSTRUCCIÓN
        
        Propósito:
            Determinar cuántos bytes ocupa una instrucción en memoria.
            Implementa el criterio especificado en los requisitos:
            - 1 byte para instrucción sin operandos
            - +1 byte por cada operando adicional
        
        Entrada:
            - linea (str): Línea de código ensamblador
        
        Retorna:
            - int: Tamaño en bytes si es instrucción válida
            - None: Si la línea no es instrucción válida o es comentario
        
        Proceso:
            1. Verificar si la línea está vacía o es comentario
               → Retorna None
            
            2. Separar mnemónica del resto usando split(None, 1)
               Ejemplo: "mov ah, 47h" → ["mov", "ah, 47h"]
            
            3. Validar la mnemónica contra la tabla TABOP
               Si no es válida → Retorna None
            
            4. Calcular tamaño:
               - Base: 1 byte (la instrucción misma)
               - Contar operandos: número de comas + 1
               - Fórmula: tamaño = 1 + numero_operandos
            
            5. Retornar tamaño calculado
        
        Ejemplos de cálculo:
            "nop"           → 1 byte (sin operandos)
            "push ax"       → 2 bytes (1 base + 1 operando)
            "mov ax, bx"    → 3 bytes (1 base + 2 operandos)
            "add al, [bx]"  → 3 bytes (1 base + 2 operandos)
            "cmp ax, 10h"   → 3 bytes (1 base + 2 operandos)
            "print"         → None (no es instrucción 8086)
        
        Notas importantes:
            - El cálculo es estimado (no usa longitud real de máquina)
            - Usado para direccionamiento incremental
            - No es 100% preciso pero funciona para la mayoría de casos
        """
        linea = linea.strip()
        # Si la línea está vacía o es comentario, no es instrucción
        if not linea or linea.startswith(';'):
            return None
        
        # Separar mnemónica de operandos
        # split(None, 1) divide en el primer espacio
        # "mov ah, 47h" → ["mov", "ah, 47h"]
        partes = linea.split(None, 1)
        mnemonica = partes[0].upper()
        
        # Validar que la mnemónica sea válida
        if not self.es_instruccion_valida(mnemonica):
            return None
        
        # Calcular tamaño: 1 byte base
        tamano = 1
        
        # Si hay operandos, contar por comas
        if len(partes) > 1:
            operandos = partes[1]
            # Número de operandos = número de comas + 1
            # "ah, 47h" tiene 1 coma → 2 operandos
            num_operandos = operandos.count(',') + 1
            tamano += num_operandos
        
        return tamano
    
    def procesar_archivo_asm(self, ruta_asm):
        """
        MÓDULO: PROCESAR ARCHIVO .ASM
        
        Propósito:
            Analizar línea por línea el archivo .asm y procesar cada instrucción,
            calculando su dirección de memoria y tamaño.
        
        Entrada:
            - ruta_asm (str): Ruta del archivo .asm a procesar
        
        Retorna:
            - list: Lista de diccionarios con información de cada línea
                    o None si hay error en lectura
        
        Estructura de cada diccionario en la lista:
            {
                'numero': int,           # Número de línea (1-indexed)
                'direccion': int|None,   # Dirección de memoria en decimal
                'direccion_hex': str,    # Dirección en hex (ej: "0042")
                'contenido': str,        # Contenido original de la línea
                'es_instruccion': bool,  # True si intenta ser instrucción
                'valida': bool|None,     # None si no es instrucción
                'tamano': int            # Bytes ocupados (solo si válida)
            }
        
        Proceso línea por línea:
            
            1. LEER ARCHIVO:
               - Abrir archivo .asm en modo lectura (utf-8, error='ignore')
               - Si no existe o hay error → Retorna None
            
            2. INICIALIZAR:
               - direccion = 0 (contador de bytes)
               - numero_linea = 1
            
            3. PROCESAR CADA LÍNEA:
            
               A) Si línea vacía o comentario puro:
                  - Añadir a lista sin información de dirección
                  - Continuar siguiente línea
               
               B) Si es directiva (ORG, INCLUDE, DB, DW, DS):
                  - Ignorar (no son instrucciones ejecutables)
                  - Continuar siguiente línea
               
               C) Si contiene db/dw/ds:
                  - Ignorar (son etiquetas con datos, no instrucciones)
                  - Continuar siguiente línea
               
               D) Si tiene ':' (etiqueta):
                  - Ignorar (no ocupan espacio de instrucción)
                  - Continuar siguiente línea
               
               E) PROCESAR COMO INSTRUCCIÓN:
                  - Calcular tamaño (validar mnemónica)
                  - Si tamaño es válido (> 0):
                    * Convertir dirección a hex (formato 4 dígitos)
                    * Guardar información con dirección
                    * INCREMENTAR dirección para próxima instrucción
                  - Si no es válida:
                    * Marcar como inválida
                    * NO incrementar dirección
        
        Variables locales:
            - lineas_procesadas: Lista de diccionarios (result)
            - direccion: Contador de bytes (se incrementa)
            - numero_linea: Contador de líneas (siempre se incrementa)
            - linea: Contenido de línea actual
            - linea_stripped: Versión sin espacios
            - tamano: Resultado de calcular_tamano_instruccion()
        
        Ejemplo de flujo:
            
            Línea 1: "org 100h"           → Ignorada (directiva)
            Línea 2: "jmp inicio"         → DIR=0000, tamaño=2, direccion→2
            Línea 3: ""                   → Línea vacía
            Línea 4: "mov ah, 47h"        → DIR=0002, tamaño=3, direccion→5
            Línea 5: "int 21h"            → DIR=0005, tamaño=2, direccion→7
        
        Excepciones manejadas:
            - FileNotFoundError: Archivo no existe
            - Exception: Problemas generales de lectura
        """
        lineas_procesadas = []
        
        # Intenta leer el archivo
        try:
            with open(ruta_asm, 'r', encoding='utf-8', errors='ignore') as f:
                lineas = f.readlines()
        except FileNotFoundError:
            print(f"Error: No se encontró archivo {ruta_asm}")
            return None
        except Exception as e:
            print(f"Error al leer archivo: {e}")
            return None
        
        # Inicializar contadores
        direccion = 0  # Contador de dirección en bytes
        numero_linea = 1
        
        # Procesar cada línea del archivo
        for linea in lineas:
            # Eliminar saltos de línea al final
            linea = linea.rstrip('\n\r')
            
            # PASO 1: Ignorar líneas vacías y comentarios puros
            linea_stripped = linea.strip()
            if not linea_stripped or linea_stripped.startswith(';'):
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': None,
                    'contenido': linea,
                    'es_instruccion': False,
                    'valida': None
                })
                numero_linea += 1
                continue
            
            # PASO 2: Ignorar directivas de ensamblador
            if linea_stripped.upper().startswith(('ORG', 'INCLUDE', 'EQU', 'DB', 'DW', 'DS', 'DEFINE_')):
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': None,
                    'contenido': linea,
                    'es_instruccion': False,
                    'valida': None
                })
                numero_linea += 1
                continue
            
            # PASO 3: Ignorar líneas que contienen db/dw/ds (datos con etiqueta)
            if ' db ' in linea_stripped.lower() or ' dw ' in linea_stripped.lower() or ' ds ' in linea_stripped.lower():
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': None,
                    'contenido': linea,
                    'es_instruccion': False,
                    'valida': None
                })
                numero_linea += 1
                continue
            
            # PASO 4: Ignorar etiquetas (líneas que terminan con ':')
            if ':' in linea_stripped and not linea_stripped.startswith(';'):
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': None,
                    'contenido': linea,
                    'es_instruccion': False,
                    'valida': None
                })
                numero_linea += 1
                continue
            
            # PASO 5: Procesar como posible instrucción
            tamano = self.calcular_tamano_instruccion(linea_stripped)
            es_instruccion = tamano is not None
            
            if es_instruccion:
                # Instrucción válida: convertir dirección a hexadecimal
                direccion_hex = f"{direccion:04X}"
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': direccion,
                    'direccion_hex': direccion_hex,
                    'contenido': linea,
                    'es_instruccion': True,
                    'valida': True,
                    'tamano': tamano
                })
                # IMPORTANTE: Incrementar dirección para próxima instrucción
                direccion += tamano
            else:
                # Línea no reconocida como instrucción válida
                lineas_procesadas.append({
                    'numero': numero_linea,
                    'direccion': None,
                    'contenido': linea,
                    'es_instruccion': True,  # Intento de instrucción
                    'valida': False
                })
            
            numero_linea += 1
        
        return lineas_procesadas
    
    def generar_archivo_lst(self, ruta_asm, lineas_procesadas):
        """
        MÓDULO: GENERAR ARCHIVO .LST (FORMATO SIMPLIFICADO)
        
        Propósito:
            Crear el archivo de salida .lst con formato compacto:
            - LOC: Dirección de memoria en hexadecimal
            - MACHINE CODE: Código hexadecimal (simulado)
            - SOURCE: Código fuente original
            Solo incluye instrucciones válidas (sin comentarios ni directivas)
        
        Entrada:
            - ruta_asm (str): Ruta original del archivo .asm
            - lineas_procesadas (list): Lista de diccionarios con info de líneas
        
        Retorna:
            - str: Ruta del archivo .lst generado (si éxito)
            - False: Si hay error al escribir
        
        Proceso:
            
            1. CONSTRUIR NOMBRE DE SALIDA:
               - Usar splitext() para separar nombre y extensión
               - Reemplazar extensión .asm por .lst
               - Ejemplo: "Prt08Example.asm" → "Prt08Example.lst"
            
            2. ESCRIBIR ENCABEZADO MINIMALISTA:
               - Únicamente línea de separación
               - Encabezado de 3 columnas: LOC, MACHINE CODE, SOURCE
            
            3. PROCESAR SOLO INSTRUCCIONES VÁLIDAS:
               - Ignorar comentarios, directivas, etiquetas, datos
               - Solo procesar líneas con instrucciones válidas
               - Saltar líneas vacías y comentarios
               - Formato: LOC  MACHINE_CODE  SOURCE
                 Ejemplo: 0000  90 90 87 C3   mov ah, 47h
            
            4. PIE DEL DOCUMENTO:
               - Línea de separación simple
        
        Variables locales:
            - nombre_base: Nombre sin extensión (ej: "Prt08Example")
            - ruta_lst: Ruta del archivo a crear (ej: "Prt08Example.lst")
            - f: Manejador de archivo abierto
        
        Ejemplos de salida:
            ================================================
            LOC    MACHINE CODE        SOURCE
            ================================================
            0000   90 90 87 C3         jmp Principal
            0002   B4 2F               mov ah, 47h
            0004   8D 36 00 10         lea si, buffer_dir
            0007   CD 21               int 21h
            ================================================
        
        Excepciones manejadas:
            - IOError: Error al escribir archivo
            - Cualquier Exception: Capturada genéricamente
        """
        # Construir nombre del archivo .lst
        nombre_base = os.path.splitext(ruta_asm)[0]
        ruta_lst = nombre_base + '.lst'
        
        try:
            with open(ruta_lst, 'w', encoding='utf-8') as f:
                # ===== ENCABEZADO =====
                f.write("=" * 48 + "\n")
                f.write(f"{'LOC':<6} {'MACHINE CODE':<20} {'SOURCE':<20}\n")
                f.write("=" * 48 + "\n")
                
                # ===== PROCESAR SOLO INSTRUCCIONES VÁLIDAS =====
                for item in lineas_procesadas:
                    # Solo procesar instrucciones válidas
                    if item['es_instruccion'] and item['valida']:
                        contenido = item['contenido'].strip()
                        direccion_hex = item['direccion_hex']
                        
                        # Generar código máquina simulado (basado en bytes)
                        tamano = item['tamano']
                        # Crear bytes hexadecimales ficticios para ilustración
                        machine_code = ' '.join([f"{(i + ord(contenido[0]))%256:02X}" for i in range(tamano)])
                        
                        # Escribir línea
                        f.write(f"{direccion_hex:<6} {machine_code:<20} {contenido}\n")
                
                # ===== PIE =====
                f.write("=" * 48 + "\n")
        
        except Exception as e:
            print(f"Error al escribir archivo .lst: {e}")
            return False
        
        return ruta_lst
    
    def ejecutar(self):
        """
        MÓDULO: INTERFAZ PRINCIPAL DEL USUARIO
        
        Propósito:
            Implementar el flujo principal de interacción con el usuario.
            Solicita rutas de archivo y coordina todo el proceso de generación.
        
        Flujo de ejecución:
            
            1. MOSTRAR ENCABEZADO:
               - Línea de separación (60 '=')
               - Título del programa
               - Autor: Rodrigo Torres Rivera
               - Nueva línea de separación
            
            2. SOLICITAR ARCHIVO DE ENTRADA:
               Preguntar en bucle hasta entrada válida:
               - Aceptar ruta del archivo .asm
               - Si usuario escribe "salir" → Terminar programa
               - Validar existencia del archivo
               - Validar que tenga extensión .asm
               - Si son válidos → Salir del bucle
            
            3. PROCESAMIENTO:
               - Procesar el archivo .asm línea por línea
               - Contar estadísticas:
                 * Total de líneas procesadas
                 * Instrucciones válidas
                 * Instrucciones inválidas
               - Imprimir estadísticas en pantalla
            
            4. GENERACIÓN:
               - Generar archivo .lst
               - Imprimir confirmación y ruta
        
        Variables locales:
            - ruta_asm: Ruta del archivo de entrada
            - lineas: Resultado del procesamiento
            - num_instrucciones: Cantidad de instrucciones válidas
            - num_invalidas: Cantidad de instrucciones inválidas
            - ruta_lst: Ruta del archivo de salida generado
        
        Mensajes de usuario:
            - Entrada: "Ingrese la ruta del archivo .asm (o 'salir' para terminar): "
            - Error archivo: "Error: Archivo no encontrado: {ruta}"
            - Error extensión: "Error: El archivo debe tener extensión .asm"
            - Procesamiento: "Procesando: {ruta_asm}"
            - Estadísticas: 
              * "✓ Procesadas N líneas"
              * "✓ Instrucciones válidas: M"
              * "⚠ Instrucciones inválidas: K"
            - Éxito: "✓ Archivo generado: {ruta_lst}"
            - Error: "Error: No se pudo generar el archivo .lst"
        
        Comportamiento especial:
            - Si usuario escribe "salir" → Termina gracefully
            - Si archivo no existe → Vuelve a pedir ruta
            - Si no es .asm → Vuelve a pedir ruta
            - Solo sale del bucle de entrada con archivo válido
        """
        # Mostrar encabezado de programa
        print("\n" + "=" * 60)
        print("GENERADOR DE ARCHIVO .LST PARA ENSAMBLADOR 8086")
        print("Autor: Rodrigo Torres Rivera")
        print("=" * 60 + "\n")
        
        # BUCLE: Solicitar archivo válido
        while True:
            ruta_asm = input("Ingrese la ruta del archivo .asm (o 'salir' para terminar): ").strip()
            
            # Si usuario quiere terminar
            if ruta_asm.lower() == 'salir':
                print("Programa terminado.")
                return
            
            # Validar que el archivo existe
            if not os.path.exists(ruta_asm):
                print(f"Error: Archivo no encontrado: {ruta_asm}")
                continue
            
            # Validar extensión
            if not ruta_asm.lower().endswith('.asm'):
                print("Error: El archivo debe tener extensión .asm")
                continue
            
            # Archivo válido → Salir del bucle
            break
        
        print(f"\nProcesando: {ruta_asm}")
        
        # Procesar el archivo
        lineas = self.procesar_archivo_asm(ruta_asm)
        
        if lineas is None:
            return
        
        # Calcular estadísticas
        num_instrucciones = sum(1 for l in lineas if l['es_instruccion'] and l['valida'])
        num_invalidas = sum(1 for l in lineas if l['es_instruccion'] and not l['valida'])
        
        # Mostrar estadísticas
        print(f"✓ Procesadas {len(lineas)} líneas")
        print(f"✓ Instrucciones válidas: {num_instrucciones}")
        if num_invalidas > 0:
            print(f"⚠ Instrucciones inválidas: {num_invalidas}")
        
        # Generar archivo .lst
        ruta_lst = self.generar_archivo_lst(ruta_asm, lineas)
        
        if ruta_lst:
            print(f"✓ Archivo generado: {ruta_lst}\n")
        else:
            print("Error: No se pudo generar el archivo .lst")


def main():
    """
    FUNCIÓN PRINCIPAL
    
    Propósito:
        Punto de entrada del programa. Instancia la clase GeneradorLST
        y llama al método ejecutar().
    
    Proceso:
        1. Crear instancia de GeneradorLST:
           - Inicializa el conjunto de instrucciones vacío
           - Carga TABOP.txt automáticamente en __init__
        
        2. Llamar a ejecutar():
           - Inicia la interfaz de usuario
           - Solicita entrada del usuario
           - Procesa archivo
           - Genera archivo .lst
    
    Notas:
        - La carga de TABOP ocurre aquí (durante instanciación)
        - Si TABOP.txt no existe, el programa termina aquí
        - Si TABOP.txt se carga exitosamente, continúa a ejecutar()
    """
    generador = GeneradorLST()
    generador.ejecutar()


if __name__ == '__main__':
    """
    PROTECCIÓN: EJECUCIÓN COMO SCRIPT
    
    Propósito:
        Permitir usar este archivo de dos formas:
        1. Como script directo: python generador_lst.py
        2. Como módulo importado: import generador_lst
    
    Lógica:
        - __name__ == '__main__' solo es verdadero cuando se ejecuta directamente
        - Si se importa como módulo, __name__ será 'generador_lst'
        - Esto previene ejecutar main() automáticamente si se importa
    
    Ventaja:
        Permite reutilizar las clases en otros programas sin ejecutar main()
        Ejemplo: from generador_lst import GeneradorLST
    """
    main()

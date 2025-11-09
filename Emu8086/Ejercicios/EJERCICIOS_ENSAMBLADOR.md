# 📚 Cuaderno de Ejercicios de Ensamblador 8086

Colección de ejercicios de algoritmos para implementar en Emu8086 (archivos .COM)

---

## 📋 Índice de Ejercicios

### 🔢 Nivel 1: Básicos - Operaciones Numéricas
1. [Factorial de un Número](#ejercicio-1-factorial)
2. [Serie de Fibonacci](#ejercicio-2-fibonacci)
3. [Verificar Número Primo](#ejercicio-3-numero-primo)
4. [Máximo Común Divisor (MCD)](#ejercicio-4-mcd)
5. [Conversión Decimal a Binario](#ejercicio-5-decimal-a-binario)

### 📊 Nivel 2: Intermedios - Arreglos y Ordenamiento
6. [Bubble Sort](#ejercicio-6-bubble-sort)
7. [Búsqueda Binaria](#ejercicio-7-busqueda-binaria)
8. [Encontrar Máximo y Mínimo](#ejercicio-8-max-min)
9. [Invertir un Arreglo](#ejercicio-9-invertir-arreglo)
10. [Suma de Matrices](#ejercicio-10-suma-matrices)

### 📝 Nivel 3: Cadenas de Texto
11. [Invertir una Cadena](#ejercicio-11-invertir-cadena)
12. [Verificar Palíndromo](#ejercicio-12-palindromo)
13. [Contar Vocales y Consonantes](#ejercicio-13-contar-vocales)
14. [Comparar Cadenas](#ejercicio-14-comparar-cadenas)
15. [Convertir Mayúsculas/Minúsculas](#ejercicio-15-mayusculas-minusculas)

### 🎨 Nivel 4: Gráficos (INT 10h)
16. [Dibujar Línea (Bresenham)](#ejercicio-16-linea-bresenham)
17. [Dibujar Rectángulo](#ejercicio-17-rectangulo)
18. [Tablero de Ajedrez](#ejercicio-18-tablero-ajedrez)
19. [Bola Rebotando](#ejercicio-19-bola-rebotando)
20. [Reloj Analógico](#ejercicio-20-reloj-analogico)

---

## 🔢 Ejercicios Nivel 1: Básicos

### Ejercicio 1: Factorial

**📝 Descripción:**
Calcular el factorial de un número n (n!). El factorial es el producto de todos los números enteros positivos desde 1 hasta n.
Ejemplo: 5! = 5 × 4 × 3 × 2 × 1 = 120

**🎯 Objetivo de aprendizaje:**
- Uso de bucles
- Multiplicaciones sucesivas
- Manejo de registros para contadores

**📋 Pseudocódigo:**
```
INICIO
    Solicitar número n
    resultado = 1
    contador = n
    
    MIENTRAS contador > 1 HACER
        resultado = resultado * contador
        contador = contador - 1
    FIN MIENTRAS
    
    Mostrar resultado
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer n]
    ↓
[resultado = 1]
    ↓
[contador = n]
    ↓
<contador > 1?> ──No──→ [Mostrar resultado] → [Fin]
    ↓ Sí
[resultado = resultado * contador]
    ↓
[contador = contador - 1]
    ↓
(volver a comparación)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - n (número a calcular)
; - resultado (word o dword)
; - contador

; Registros sugeridos:
; AX = resultado parcial
; BX = contador
; DX = parte alta del resultado (para 32 bits)
```

**✅ Casos de prueba:**
- Entrada: 5 → Salida: 120
- Entrada: 7 → Salida: 5040
- Entrada: 0 → Salida: 1
- Entrada: 1 → Salida: 1

**📁 Archivo de implementación:** `Ejercicio01_Factorial.asm`

---

### Ejercicio 2: Fibonacci

**📝 Descripción:**
Generar los primeros n números de la serie de Fibonacci, donde cada número es la suma de los dos anteriores.
Serie: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34...

**🎯 Objetivo de aprendizaje:**
- Manejo de variables temporales
- Sumas sucesivas
- Almacenamiento en arreglos

**📋 Pseudocódigo:**
```
INICIO
    Solicitar cantidad n
    fib[0] = 0
    fib[1] = 1
    
    PARA i = 2 HASTA n-1 HACER
        fib[i] = fib[i-1] + fib[i-2]
    FIN PARA
    
    Mostrar arreglo fib
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer n]
    ↓
[fib[0] = 0, fib[1] = 1]
    ↓
[i = 2]
    ↓
<i < n?> ──No──→ [Mostrar serie] → [Fin]
    ↓ Sí
[fib[i] = fib[i-1] + fib[i-2]]
    ↓
[i = i + 1]
    ↓
(volver a comparación)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - serie db 20 dup(0)  ; arreglo para guardar la serie
; - n db ?               ; cantidad de números
; - indice db ?

; Registros sugeridos:
; AL = fib[i-2]
; BL = fib[i-1]
; CL = suma temporal
; SI = índice del arreglo
```

**✅ Casos de prueba:**
- n=10 → 0,1,1,2,3,5,8,13,21,34
- n=5 → 0,1,1,2,3

**📁 Archivo de implementación:** `Ejercicio02_Fibonacci.asm`

---

### Ejercicio 3: Número Primo

**📝 Descripción:**
Verificar si un número n es primo (solo divisible por 1 y por sí mismo).

**🎯 Objetivo de aprendizaje:**
- División entera
- Uso de módulo (residuo)
- Optimización de bucles

**📋 Pseudocódigo:**
```
INICIO
    Solicitar número n
    
    SI n <= 1 ENTONCES
        No es primo
        TERMINAR
    FIN SI
    
    esPrimo = VERDADERO
    
    PARA divisor = 2 HASTA raiz(n) HACER
        SI n MOD divisor == 0 ENTONCES
            esPrimo = FALSO
            SALIR del bucle
        FIN SI
    FIN PARA
    
    SI esPrimo ENTONCES
        Mostrar "Es primo"
    SINO
        Mostrar "No es primo"
    FIN SI
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer n]
    ↓
<n <= 1?> ──Sí──→ [Mostrar "No es primo"] → [Fin]
    ↓ No
[divisor = 2]
    ↓
<divisor ≤ √n?> ──No──→ [Mostrar "Es primo"] → [Fin]
    ↓ Sí
<n MOD divisor == 0?> ──Sí──→ [Mostrar "No es primo"] → [Fin]
    ↓ No
[divisor = divisor + 1]
    ↓
(volver a comparación divisor ≤ √n)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - numero dw ?
; - divisor dw ?
; - esPrimo db ?

; Registros sugeridos:
; AX = número a verificar
; BX = divisor actual
; DX = residuo de la división
```

**✅ Casos de prueba:**
- Entrada: 7 → Es primo
- Entrada: 12 → No es primo
- Entrada: 2 → Es primo
- Entrada: 1 → No es primo

**📁 Archivo de implementación:** `Ejercicio03_NumeroPrimo.asm`

---

### Ejercicio 4: MCD (Máximo Común Divisor)

**📝 Descripción:**
Calcular el MCD de dos números usando el algoritmo de Euclides.

**🎯 Objetivo de aprendizaje:**
- Algoritmo de Euclides
- División con residuo
- Bucles condicionales

**📋 Pseudocódigo:**
```
INICIO
    Solicitar a, b
    
    MIENTRAS b != 0 HACER
        residuo = a MOD b
        a = b
        b = residuo
    FIN MIENTRAS
    
    MCD = a
    Mostrar MCD
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer a, b]
    ↓
<b != 0?> ──No──→ [MCD = a] → [Mostrar MCD] → [Fin]
    ↓ Sí
[residuo = a MOD b]
    ↓
[a = b]
    ↓
[b = residuo]
    ↓
(volver a comparación b != 0)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - num1 dw ?
; - num2 dw ?

; Registros sugeridos:
; AX = dividendo
; BX = divisor
; DX = residuo
```

**✅ Casos de prueba:**
- a=48, b=18 → MCD=6
- a=100, b=50 → MCD=50
- a=17, b=19 → MCD=1

**📁 Archivo de implementación:** `Ejercicio04_MCD.asm`

---

### Ejercicio 5: Decimal a Binario

**📝 Descripción:**
Convertir un número decimal a su representación binaria.

**🎯 Objetivo de aprendizaje:**
- Divisiones sucesivas entre 2
- Almacenamiento de residuos
- Inversión de resultados

**📋 Pseudocódigo:**
```
INICIO
    Solicitar número decimal
    i = 0
    
    MIENTRAS numero > 0 HACER
        binario[i] = numero MOD 2
        numero = numero DIV 2
        i = i + 1
    FIN MIENTRAS
    
    Mostrar binario[i-1] hasta binario[0] (invertido)
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer decimal]
    ↓
[i = 0]
    ↓
<decimal > 0?> ──No──→ [Mostrar binario invertido] → [Fin]
    ↓ Sí
[binario[i] = decimal MOD 2]
    ↓
[decimal = decimal DIV 2]
    ↓
[i = i + 1]
    ↓
(volver a comparación)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - numero dw ?
; - binario db 16 dup(0)
; - indice db ?

; Registros sugeridos:
; AX = número a convertir
; BX = 2 (divisor)
; DX = residuo (bit actual)
```

**✅ Casos de prueba:**
- Entrada: 13 → 1101
- Entrada: 255 → 11111111
- Entrada: 8 → 1000

**📁 Archivo de implementación:** `Ejercicio05_DecimalBinario.asm`

---

## 📊 Ejercicios Nivel 2: Intermedios

### Ejercicio 6: Bubble Sort

**📝 Descripción:**
Ordenar un arreglo de números en orden ascendente usando el algoritmo Bubble Sort.

**🎯 Objetivo de aprendizaje:**
- Bucles anidados
- Intercambio de valores
- Comparaciones múltiples

**📋 Pseudocódigo:**
```
INICIO
    Definir arreglo[n]
    
    PARA i = 0 HASTA n-2 HACER
        PARA j = 0 HASTA n-i-2 HACER
            SI arreglo[j] > arreglo[j+1] ENTONCES
                // Intercambiar
                temp = arreglo[j]
                arreglo[j] = arreglo[j+1]
                arreglo[j+1] = temp
            FIN SI
        FIN PARA
    FIN PARA
    
    Mostrar arreglo ordenado
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Cargar arreglo]
    ↓
[i = 0]
    ↓
<i < n-1?> ──No──→ [Mostrar arreglo] → [Fin]
    ↓ Sí
[j = 0]
    ↓
<j < n-i-1?> ──No──→ [i = i + 1] → (volver a i < n-1)
    ↓ Sí
<arr[j] > arr[j+1]?> ──No──→ [j = j + 1] → (volver a j < n-i-1)
    ↓ Sí
[Intercambiar arr[j] y arr[j+1]]
    ↓
[j = j + 1]
    ↓
(volver a j < n-i-1)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - arreglo db 10 dup(?)
; - tamaño db 10
; - temp db ?

; Registros sugeridos:
; CX = contador externo (i)
; DX = contador interno (j)
; SI = índice del arreglo
; AL, BL = valores a comparar
```

**✅ Casos de prueba:**
- Entrada: [5,2,8,1,9] → [1,2,5,8,9]
- Entrada: [3,3,1,2] → [1,2,3,3]

**📁 Archivo de implementación:** `Ejercicio06_BubbleSort.asm`

---

### Ejercicio 7: Búsqueda Binaria

**📝 Descripción:**
Buscar un elemento en un arreglo ordenado usando búsqueda binaria.

**🎯 Objetivo de aprendizaje:**
- Algoritmo divide y vencerás
- Cálculo de punto medio
- Comparaciones optimizadas

**📋 Pseudocódigo:**
```
INICIO
    Arreglo ordenado[n]
    Solicitar valor a buscar
    
    inicio = 0
    fin = n - 1
    encontrado = FALSO
    
    MIENTRAS inicio <= fin Y NO encontrado HACER
        medio = (inicio + fin) / 2
        
        SI arreglo[medio] == valor ENTONCES
            encontrado = VERDADERO
            posicion = medio
        SINO SI arreglo[medio] < valor ENTONCES
            inicio = medio + 1
        SINO
            fin = medio - 1
        FIN SI
    FIN MIENTRAS
    
    SI encontrado ENTONCES
        Mostrar "Encontrado en posición", posicion
    SINO
        Mostrar "No encontrado"
    FIN SI
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer arreglo ordenado y valor]
    ↓
[inicio=0, fin=n-1]
    ↓
<inicio ≤ fin?> ──No──→ [Mostrar "No encontrado"] → [Fin]
    ↓ Sí
[medio = (inicio+fin)/2]
    ↓
<arr[medio] == valor?> ──Sí──→ [Mostrar posición] → [Fin]
    ↓ No
<arr[medio] < valor?> ──Sí──→ [inicio = medio+1]
    ↓ No                           ↓
[fin = medio-1]                    ↓
    ↓←──────────────────────────────
(volver a inicio ≤ fin)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - arreglo dw 10 dup(?)  ; debe estar ordenado
; - valor dw ?
; - inicio dw ?
; - fin dw ?
; - medio dw ?

; Registros sugeridos:
; BX = inicio
; DX = fin
; SI = medio * 2 (para words)
```

**✅ Casos de prueba:**
- Arr=[1,3,5,7,9], Buscar 7 → Posición 3
- Arr=[2,4,6,8], Buscar 5 → No encontrado

**📁 Archivo de implementación:** `Ejercicio07_BusquedaBinaria.asm`

---

### Ejercicio 8: Máximo y Mínimo

**📝 Descripción:**
Encontrar el valor máximo y mínimo en un arreglo de números.

**🎯 Objetivo de aprendizaje:**
- Recorrido de arreglos
- Comparaciones sucesivas
- Manejo de valores iniciales

**📋 Pseudocódigo:**
```
INICIO
    Arreglo[n]
    max = arreglo[0]
    min = arreglo[0]
    
    PARA i = 1 HASTA n-1 HACER
        SI arreglo[i] > max ENTONCES
            max = arreglo[i]
        FIN SI
        
        SI arreglo[i] < min ENTONCES
            min = arreglo[i]
        FIN SI
    FIN PARA
    
    Mostrar max, min
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer arreglo]
    ↓
[max = arr[0], min = arr[0]]
    ↓
[i = 1]
    ↓
<i < n?> ──No──→ [Mostrar max, min] → [Fin]
    ↓ Sí
<arr[i] > max?> ──Sí──→ [max = arr[i]]
    ↓ No                      ↓
<arr[i] < min?> ──Sí──→ [min = arr[i]]
    ↓ No                      ↓
[i = i + 1] ←─────────────────
    ↓
(volver a i < n)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - arreglo db 10 dup(?)
; - maximo db ?
; - minimo db ?

; Registros sugeridos:
; AL = máximo
; BL = mínimo
; SI = índice
; CL = valor actual
```

**✅ Casos de prueba:**
- [3,7,1,9,2] → Max=9, Min=1
- [5,5,5] → Max=5, Min=5

**📁 Archivo de implementación:** `Ejercicio08_MaxMin.asm`

---

### Ejercicio 9: Invertir Arreglo

**📝 Descripción:**
Invertir el orden de los elementos de un arreglo.

**🎯 Objetivo de aprendizaje:**
- Intercambio de elementos
- Recorrido desde ambos extremos
- Cálculo de índices simétricos

**📋 Pseudocódigo:**
```
INICIO
    Arreglo[n]
    inicio = 0
    fin = n - 1
    
    MIENTRAS inicio < fin HACER
        temp = arreglo[inicio]
        arreglo[inicio] = arreglo[fin]
        arreglo[fin] = temp
        
        inicio = inicio + 1
        fin = fin - 1
    FIN MIENTRAS
    
    Mostrar arreglo invertido
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer arreglo]
    ↓
[inicio=0, fin=n-1]
    ↓
<inicio < fin?> ──No──→ [Mostrar arreglo] → [Fin]
    ↓ Sí
[Intercambiar arr[inicio] y arr[fin]]
    ↓
[inicio++, fin--]
    ↓
(volver a inicio < fin)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - arreglo db 10 dup(?)
; - temp db ?

; Registros sugeridos:
; SI = índice inicio
; DI = índice fin
; AL, BL = valores temporales
```

**✅ Casos de prueba:**
- [1,2,3,4,5] → [5,4,3,2,1]
- [a,b,c] → [c,b,a]

**📁 Archivo de implementación:** `Ejercicio09_InvertirArreglo.asm`

---

### Ejercicio 10: Suma de Matrices

**📝 Descripción:**
Sumar dos matrices de igual tamaño (ejemplo: 3x3).

**🎯 Objetivo de aprendizaje:**
- Matrices bidimensionales
- Bucles anidados para filas/columnas
- Direccionamiento indexado

**📋 Pseudocódigo:**
```
INICIO
    Matriz A[3][3]
    Matriz B[3][3]
    Matriz C[3][3]
    
    PARA i = 0 HASTA 2 HACER
        PARA j = 0 HASTA 2 HACER
            C[i][j] = A[i][j] + B[i][j]
        FIN PARA
    FIN PARA
    
    Mostrar matriz C
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Cargar matrices A y B]
    ↓
[i = 0]
    ↓
<i < 3?> ──No──→ [Mostrar matriz C] → [Fin]
    ↓ Sí
[j = 0]
    ↓
<j < 3?> ──No──→ [i++] → (volver a i < 3)
    ↓ Sí
[C[i][j] = A[i][j] + B[i][j]]
    ↓
[j++]
    ↓
(volver a j < 3)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - matrizA db 9 dup(?)  ; 3x3 = 9 elementos
; - matrizB db 9 dup(?)
; - matrizC db 9 dup(?)

; Registros sugeridos:
; SI = índice matriz A
; DI = índice matriz B
; BX = índice matriz C
; AL, BL = valores a sumar
```

**✅ Casos de prueba:**
```
A = [1 2 3]    B = [9 8 7]    C = [10 10 10]
    [4 5 6]        [6 5 4]        [10 10 10]
    [7 8 9]        [3 2 1]        [10 10 10]
```

**📁 Archivo de implementación:** `Ejercicio10_SumaMatrices.asm`

---

## 📝 Ejercicios Nivel 3: Cadenas

### Ejercicio 11: Invertir Cadena

**📝 Descripción:**
Invertir una cadena de texto (ejemplo: "HOLA" → "ALOH").

**🎯 Objetivo de aprendizaje:**
- Manipulación de cadenas
- Intercambio de caracteres
- Búsqueda del fin de cadena (null terminator)

**📋 Pseudocódigo:**
```
INICIO
    Solicitar cadena
    
    // Encontrar longitud
    longitud = 0
    MIENTRAS cadena[longitud] != '\0' HACER
        longitud = longitud + 1
    FIN MIENTRAS
    
    // Invertir
    inicio = 0
    fin = longitud - 1
    
    MIENTRAS inicio < fin HACER
        temp = cadena[inicio]
        cadena[inicio] = cadena[fin]
        cadena[fin] = temp
        inicio++
        fin--
    FIN MIENTRAS
    
    Mostrar cadena invertida
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer cadena]
    ↓
[Calcular longitud]
    ↓
[inicio=0, fin=longitud-1]
    ↓
<inicio < fin?> ──No──→ [Mostrar cadena] → [Fin]
    ↓ Sí
[Intercambiar cadena[inicio] y cadena[fin]]
    ↓
[inicio++, fin--]
    ↓
(volver a inicio < fin)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - cadena db 50 dup(0)
; - longitud db ?

; Macros Emu8086:
; get_string, print_string
```

**✅ Casos de prueba:**
- "HOLA" → "ALOH"
- "ANITA LAVA LA TINA" → "ANIT AL AVAL ATINA"

**📁 Archivo de implementación:** `Ejercicio11_InvertirCadena.asm`

---

### Ejercicio 12: Palíndromo

**📝 Descripción:**
Verificar si una cadena es un palíndromo (se lee igual al derecho y al revés).

**🎯 Objetivo de aprendizaje:**
- Comparación de caracteres
- Recorrido simétrico
- Validación de strings

**📋 Pseudocódigo:**
```
INICIO
    Solicitar cadena
    
    longitud = calcular_longitud(cadena)
    esPalindromo = VERDADERO
    
    PARA i = 0 HASTA longitud/2 HACER
        SI cadena[i] != cadena[longitud-1-i] ENTONCES
            esPalindromo = FALSO
            SALIR
        FIN SI
    FIN PARA
    
    SI esPalindromo ENTONCES
        Mostrar "Es palíndromo"
    SINO
        Mostrar "No es palíndromo"
    FIN SI
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer cadena]
    ↓
[Calcular longitud]
    ↓
[i = 0]
    ↓
<i < longitud/2?> ──No──→ [Mostrar "Es palíndromo"] → [Fin]
    ↓ Sí
<cadena[i] == cadena[long-1-i]?> ──No──→ [Mostrar "No es palíndromo"] → [Fin]
    ↓ Sí
[i++]
    ↓
(volver a i < longitud/2)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - cadena db 50 dup(0)
; - longitud db ?
; - esPalindromo db ?

; Registros sugeridos:
; SI = índice desde inicio
; DI = índice desde fin
```

**✅ Casos de prueba:**
- "ANILINA" → Es palíndromo
- "RECONOCER" → Es palíndromo
- "HOLA" → No es palíndromo

**📁 Archivo de implementación:** `Ejercicio12_Palindromo.asm`

---

### Ejercicio 13: Contar Vocales y Consonantes

**📝 Descripción:**
Contar el número de vocales y consonantes en una cadena.

**🎯 Objetivo de aprendizaje:**
- Clasificación de caracteres
- Contadores múltiples
- Comparaciones con conjuntos

**📋 Pseudocódigo:**
```
INICIO
    Solicitar cadena
    vocales = 0
    consonantes = 0
    
    PARA cada caracter en cadena HACER
        SI caracter es letra ENTONCES
            SI caracter en ['A','E','I','O','U','a','e','i','o','u'] ENTONCES
                vocales++
            SINO
                consonantes++
            FIN SI
        FIN SI
    FIN PARA
    
    Mostrar "Vocales:", vocales
    Mostrar "Consonantes:", consonantes
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer cadena]
    ↓
[vocales=0, consonantes=0, i=0]
    ↓
<cadena[i] != '\0'?> ──No──→ [Mostrar resultados] → [Fin]
    ↓ Sí
<es letra?> ──No──→ [i++] → (volver)
    ↓ Sí
<es vocal?> ──Sí──→ [vocales++]
    ↓ No                  ↓
[consonantes++] ←─────────
    ↓
[i++]
    ↓
(volver a cadena[i] != '\0')
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - cadena db 100 dup(0)
; - contVocales db 0
; - contConsonantes db 0

; Comparaciones necesarias:
; A-Z: 65-90 (mayúsculas)
; a-z: 97-122 (minúsculas)
; Vocales: A,E,I,O,U,a,e,i,o,u
```

**✅ Casos de prueba:**
- "HOLA MUNDO" → Vocales: 4, Consonantes: 5
- "PROGRAMACION" → Vocales: 5, Consonantes: 7

**📁 Archivo de implementación:** `Ejercicio13_ContarVocales.asm`

---

### Ejercicio 14: Comparar Cadenas

**📝 Descripción:**
Comparar dos cadenas y determinar si son iguales o cuál es mayor lexicográficamente.

**🎯 Objetivo de aprendizaje:**
- Comparación caracter por caracter
- Orden lexicográfico
- Manejo de diferentes longitudes

**📋 Pseudocódigo:**
```
INICIO
    Solicitar cadena1
    Solicitar cadena2
    
    i = 0
    resultado = "iguales"
    
    MIENTRAS cadena1[i] != '\0' Y cadena2[i] != '\0' HACER
        SI cadena1[i] < cadena2[i] ENTONCES
            resultado = "cadena1 es menor"
            SALIR
        SINO SI cadena1[i] > cadena2[i] ENTONCES
            resultado = "cadena1 es mayor"
            SALIR
        FIN SI
        i++
    FIN MIENTRAS
    
    SI cadena1[i] == '\0' Y cadena2[i] != '\0' ENTONCES
        resultado = "cadena1 es menor"
    SINO SI cadena1[i] != '\0' Y cadena2[i] == '\0' ENTONCES
        resultado = "cadena1 es mayor"
    FIN SI
    
    Mostrar resultado
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer cadena1 y cadena2]
    ↓
[i = 0]
    ↓
<ambas tienen caracteres?> ──No──→ [Comparar longitudes] → [Mostrar] → [Fin]
    ↓ Sí
<cad1[i] == cad2[i]?> ──Sí──→ [i++] → (volver)
    ↓ No
<cad1[i] < cad2[i]?> ──Sí──→ [resultado="menor"]
    ↓ No                           ↓
[resultado="mayor"] ───────────────→ [Mostrar] → [Fin]
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - cadena1 db 50 dup(0)
; - cadena2 db 50 dup(0)

; Registros sugeridos:
; SI = índice cadena1
; DI = índice cadena2
; AL, BL = caracteres a comparar
```

**✅ Casos de prueba:**
- "ABC" vs "ABC" → Iguales
- "ABC" vs "ABD" → cadena1 es menor
- "ZAPATO" vs "CASA" → cadena1 es mayor

**📁 Archivo de implementación:** `Ejercicio14_CompararCadenas.asm`

---

### Ejercicio 15: Mayúsculas/Minúsculas

**📝 Descripción:**
Convertir una cadena a mayúsculas o a minúsculas.

**🎯 Objetivo de aprendizaje:**
- Manipulación de códigos ASCII
- Conversión de casos
- Transformación in-place

**📋 Pseudocódigo:**
```
// Convertir a mayúsculas
INICIO
    Solicitar cadena
    
    PARA cada caracter en cadena HACER
        SI caracter >= 'a' Y caracter <= 'z' ENTONCES
            caracter = caracter - 32  // diferencia entre mayúscula y minúscula
        FIN SI
    FIN PARA
    
    Mostrar cadena en mayúsculas
FIN

// Para minúsculas: si caracter entre 'A' y 'Z', sumar 32
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer cadena]
    ↓
[i = 0]
    ↓
<cadena[i] != '\0'?> ──No──→ [Mostrar cadena] → [Fin]
    ↓ Sí
<'a' ≤ cadena[i] ≤ 'z'?> ──Sí──→ [cadena[i] = cadena[i] - 32]
    ↓ No                               ↓
[i++] ←────────────────────────────────
    ↓
(volver a cadena[i] != '\0')
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - cadena db 100 dup(0)

; Códigos ASCII:
; 'A'-'Z': 65-90
; 'a'-'z': 97-122
; Diferencia: 32

; Registros sugeridos:
; SI = índice
; AL = caracter actual
```

**✅ Casos de prueba:**
- "Hola Mundo" → "HOLA MUNDO" (mayúsculas)
- "PROGRAMAR" → "programar" (minúsculas)
- "123 ABC xyz" → "123 ABC XYZ" (mayúsculas)

**📁 Archivo de implementación:** `Ejercicio15_MayusculasMinusculas.asm`

---

## 🎨 Ejercicios Nivel 4: Gráficos

### Ejercicio 16: Línea (Bresenham)

**📝 Descripción:**
Dibujar una línea entre dos puntos usando el algoritmo de Bresenham.

**🎯 Objetivo de aprendizaje:**
- Algoritmo de Bresenham para líneas
- Gráficos con INT 10h
- Interpolación de puntos

**📋 Pseudocódigo:**
```
INICIO
    x1, y1, x2, y2  // puntos inicial y final
    
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)
    sx = si x1 < x2 entonces 1 sino -1
    sy = si y1 < y2 entonces 1 sino -1
    err = dx - dy
    
    x = x1
    y = y1
    
    MIENTRAS VERDADERO HACER
        DibujarPixel(x, y)
        
        SI x == x2 Y y == y2 ENTONCES
            SALIR
        FIN SI
        
        e2 = 2 * err
        
        SI e2 > -dy ENTONCES
            err = err - dy
            x = x + sx
        FIN SI
        
        SI e2 < dx ENTONCES
            err = err + dx
            y = y + sy
        FIN SI
    FIN MIENTRAS
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer (x1,y1) y (x2,y2)]
    ↓
[Calcular dx, dy, sx, sy, err]
    ↓
[x=x1, y=y1]
    ↓
[Dibujar píxel en (x,y)]
    ↓
<x==x2 Y y==y2?> ──Sí──→ [Fin]
    ↓ No
[Calcular e2 = 2*err]
    ↓
<e2 > -dy?> ──Sí──→ [err-=dy, x+=sx]
    ↓ No              ↓
<e2 < dx?> ──Sí──→ [err+=dx, y+=sy]
    ↓ No              ↓
(volver a Dibujar píxel) ←
```

**💻 Estructura del código ASM:**
```assembly
; INT 10h, función 0Ch: Dibujar píxel
; AH = 0Ch
; AL = color
; CX = coordenada X
; DX = coordenada Y
; BH = página (0)

; Modo gráfico: INT 10h AH=00h, AL=13h (320x200)
```

**✅ Casos de prueba:**
- Línea horizontal: (0,100) a (319,100)
- Línea vertical: (160,0) a (160,199)
- Diagonal: (0,0) a (319,199)

**📁 Archivo de implementación:** `Ejercicio16_LineaBresenham.asm`

---

### Ejercicio 17: Rectángulo

**📝 Descripción:**
Dibujar un rectángulo (con borde o relleno).

**🎯 Objetivo de aprendizaje:**
- Dibujo de formas básicas
- Bucles de líneas horizontales/verticales
- Relleno de áreas

**📋 Pseudocódigo:**
```
// Rectángulo con borde
INICIO
    x1, y1, x2, y2, color
    
    // Líneas horizontales (arriba y abajo)
    PARA x = x1 HASTA x2 HACER
        DibujarPixel(x, y1, color)  // línea superior
        DibujarPixel(x, y2, color)  // línea inferior
    FIN PARA
    
    // Líneas verticales (izquierda y derecha)
    PARA y = y1 HASTA y2 HACER
        DibujarPixel(x1, y, color)  // línea izquierda
        DibujarPixel(x2, y, color)  // línea derecha
    FIN PARA
FIN

// Para rectángulo relleno:
PARA y = y1 HASTA y2 HACER
    PARA x = x1 HASTA x2 HACER
        DibujarPixel(x, y, color)
    FIN PARA
FIN PARA
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Leer x1,y1,x2,y2,color]
    ↓
[Modo gráfico 13h]
    ↓
[x = x1]
    ↓
<x ≤ x2?> ──No──→ [Dibujar verticales]
    ↓ Sí
[Píxel(x,y1) y Píxel(x,y2)]
    ↓
[x++]
    ↓
(volver a x ≤ x2)
    ↓
[y = y1]
    ↓
<y ≤ y2?> ──No──→ [Esperar tecla] → [Fin]
    ↓ Sí
[Píxel(x1,y) y Píxel(x2,y)]
    ↓
[y++]
    ↓
(volver a y ≤ y2)
```

**💻 Estructura del código ASM:**
```assembly
; Constantes sugeridas:
; X1 = 50, Y1 = 50
; X2 = 270, Y2 = 150
; COLOR = 0Fh (blanco)

; Modo 13h: 320x200, 256 colores
```

**✅ Casos de prueba:**
- Rectángulo centrado
- Cuadrado (cuando x2-x1 == y2-y1)
- Rectángulo relleno vs solo borde

**📁 Archivo de implementación:** `Ejercicio17_Rectangulo.asm`

---

### Ejercicio 18: Tablero de Ajedrez

**📝 Descripción:**
Dibujar un tablero de ajedrez de 8x8 cuadros alternando colores.

**🎯 Objetivo de aprendizaje:**
- Patrones geométricos
- Bucles anidados para cuadrícula
- Alternancia de colores

**📋 Pseudocódigo:**
```
INICIO
    tamanoCuadro = 20  // píxeles por cuadro
    
    PARA fila = 0 HASTA 7 HACER
        PARA columna = 0 HASTA 7 HACER
            // Determinar color (alternar)
            SI (fila + columna) MOD 2 == 0 ENTONCES
                color = BLANCO
            SINO
                color = NEGRO
            FIN SI
            
            // Dibujar cuadro relleno
            x1 = columna * tamanoCuadro
            y1 = fila * tamanoCuadro
            x2 = x1 + tamanoCuadro - 1
            y2 = y1 + tamanoCuadro - 1
            
            DibujarRectanguloRelleno(x1, y1, x2, y2, color)
        FIN PARA
    FIN PARA
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Modo gráfico 13h]
    ↓
[fila = 0]
    ↓
<fila < 8?> ──No──→ [Esperar tecla] → [Fin]
    ↓ Sí
[columna = 0]
    ↓
<columna < 8?> ──No──→ [fila++] → (volver a fila < 8)
    ↓ Sí
<(fila+col) MOD 2 == 0?> ──Sí──→ [color = BLANCO]
    ↓ No                              ↓
[color = NEGRO] ──────────────────────→ [Calcular x1,y1,x2,y2]
    ↓
[Dibujar cuadro relleno]
    ↓
[columna++]
    ↓
(volver a columna < 8)
```

**💻 Estructura del código ASM:**
```assembly
; Constantes:
; TAMAÑO_CUADRO = 25
; COLOR_CLARO = 0Fh (blanco)
; COLOR_OSCURO = 00h (negro)

; 8x8 cuadros = 200x200 píxeles
; Centrado en pantalla 320x200
```

**✅ Casos de prueba:**
- Tablero 8x8 con cuadros de 25x25 píxeles
- Verificar alternancia correcta de colores

**📁 Archivo de implementación:** `Ejercicio18_TableroAjedrez.asm`

---

### Ejercicio 19: Bola Rebotando

**📝 Descripción:**
Animar una bola que rebota en los bordes de la pantalla.

**🎯 Objetivo de aprendizaje:**
- Animación básica
- Detección de colisiones con bordes
- Delays y actualización de pantalla

**📋 Pseudocódigo:**
```
INICIO
    x = 160, y = 100  // posición inicial (centro)
    dx = 2, dy = 2    // velocidad
    radio = 5
    color = ROJO
    
    MIENTRAS NO se presione tecla HACER
        // Borrar posición anterior (dibujar en negro)
        DibujarCirculo(x, y, radio, NEGRO)
        
        // Actualizar posición
        x = x + dx
        y = y + dy
        
        // Detectar colisión con bordes
        SI x - radio <= 0 O x + radio >= 319 ENTONCES
            dx = -dx  // invertir dirección horizontal
        FIN SI
        
        SI y - radio <= 0 O y + radio >= 199 ENTONCES
            dy = -dy  // invertir dirección vertical
        FIN SI
        
        // Dibujar en nueva posición
        DibujarCirculo(x, y, radio, color)
        
        Delay(10ms)
    FIN MIENTRAS
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Modo gráfico, inicializar x,y,dx,dy]
    ↓
<tecla presionada?> ──Sí──→ [Restaurar modo texto] → [Fin]
    ↓ No
[Borrar círculo en (x,y)]
    ↓
[x += dx, y += dy]
    ↓
<colisión horizontal?> ──Sí──→ [dx = -dx]
    ↓ No                           ↓
<colisión vertical?> ──Sí──→ [dy = -dy]
    ↓ No                           ↓
[Dibujar círculo en (x,y)] ←───────
    ↓
[Delay]
    ↓
(volver a tecla presionada)
```

**💻 Estructura del código ASM:**
```assembly
; Variables necesarias:
; - posX dw 160
; - posY dw 100
; - velX dw 2
; - velY dw 2
; - radio dw 5

; INT 16h AH=01h: verificar si hay tecla
; INT 16h AH=00h: leer tecla (para salir)
```

**✅ Casos de prueba:**
- Bola rebota en las 4 esquinas
- Velocidad constante después de rebotar
- Salir al presionar cualquier tecla

**📁 Archivo de implementación:** `Ejercicio19_BolaRebotando.asm`

---

### Ejercicio 20: Reloj Analógico

**📝 Descripción:**
Dibujar un reloj analógico simple con manecillas para horas, minutos y segundos.

**🎯 Objetivo de aprendizaje:**
- Coordenadas polares
- Cálculo de ángulos
- Actualización periódica (tiempo real)

**📋 Pseudocódigo:**
```
INICIO
    centroX = 160, centroY = 100
    radio = 60
    
    MIENTRAS VERDADERO HACER
        // Obtener hora actual (INT 1Ah)
        hora, minuto, segundo = ObtenerHora()
        
        // Limpiar pantalla o borrar manecillas anteriores
        LimpiarCirculo()
        
        // Dibujar círculo del reloj
        DibujarCirculo(centroX, centroY, radio)
        
        // Calcular ángulos (12 en punto = 0°, sentido horario)
        anguloSegundos = segundo * 6        // 360°/60 = 6° por segundo
        anguloMinutos = minuto * 6 + segundo * 0.1
        anguloHoras = (hora % 12) * 30 + minuto * 0.5
        
        // Calcular posiciones de las manecillas
        // x = centroX + radio * sin(angulo)
        // y = centroY - radio * cos(angulo)
        
        // Dibujar manecillas (de más corta a más larga)
        DibujarLinea(centroX, centroY, xHora, yHora, COLOR_HORA)
        DibujarLinea(centroX, centroY, xMinuto, yMinuto, COLOR_MINUTO)
        DibujarLinea(centroX, centroY, xSegundo, ySegundo, COLOR_SEGUNDO)
        
        Delay(1 segundo)
    FIN MIENTRAS
FIN
```

**🔄 Diagrama de Flujo (Descripción):**
```
[Inicio]
    ↓
[Modo gráfico]
    ↓
[Dibujar círculo del reloj]
    ↓
<tecla ESC?> ──Sí──→ [Restaurar modo] → [Fin]
    ↓ No
[Obtener hora actual (INT 1Ah)]
    ↓
[Calcular ángulos para h,m,s]
    ↓
[Borrar manecillas anteriores]
    ↓
[Calcular coord. polares → cartesianas]
    ↓
[Dibujar manecilla horas (corta, gruesa)]
    ↓
[Dibujar manecilla minutos (media)]
    ↓
[Dibujar manecilla segundos (larga, delgada)]
    ↓
[Delay 1 segundo]
    ↓
(volver a tecla ESC)
```

**💻 Estructura del código ASM:**
```assembly
; INT 1Ah: Obtener hora del sistema
; AH = 02h: Leer hora del RTC
; CH = hora (BCD)
; CL = minutos (BCD)
; DH = segundos (BCD)

; Tablas de seno/coseno precalculadas
; o usar aproximaciones para calcular posiciones

; Longitud manecillas:
; - Horas: radio * 0.5
; - Minutos: radio * 0.7
; - Segundos: radio * 0.9
```

**✅ Casos de prueba:**
- Verificar que las manecillas se actualizan cada segundo
- Comprobar posiciones en 12:00, 3:00, 6:00, 9:00
- Manecilla de horas se mueve gradualmente

**📁 Archivo de implementación:** `Ejercicio20_RelojAnalogico.asm`

---

## 📊 Tabla de Progreso

Usa esta tabla para marcar los ejercicios completados:

| # | Ejercicio | Dificultad | Completado | Archivo |
|---|-----------|------------|------------|---------|
| 1 | Factorial | ⭐ | ⬜ | - |
| 2 | Fibonacci | ⭐ | ⬜ | - |
| 3 | Número Primo | ⭐ | ⬜ | - |
| 4 | MCD | ⭐ | ⬜ | - |
| 5 | Decimal a Binario | ⭐ | ⬜ | - |
| 6 | Bubble Sort | ⭐⭐ | ⬜ | - |
| 7 | Búsqueda Binaria | ⭐⭐ | ⬜ | - |
| 8 | Máximo y Mínimo | ⭐⭐ | ⬜ | - |
| 9 | Invertir Arreglo | ⭐⭐ | ⬜ | - |
| 10 | Suma de Matrices | ⭐⭐ | ⬜ | - |
| 11 | Invertir Cadena | ⭐⭐ | ⬜ | - |
| 12 | Palíndromo | ⭐⭐ | ⬜ | - |
| 13 | Contar Vocales | ⭐⭐ | ⬜ | - |
| 14 | Comparar Cadenas | ⭐⭐ | ⬜ | - |
| 15 | Mayúsculas/Minúsculas | ⭐⭐ | ⬜ | - |
| 16 | Línea Bresenham | ⭐⭐⭐ | ⬜ | - |
| 17 | Rectángulo | ⭐⭐⭐ | ⬜ | - |
| 18 | Tablero Ajedrez | ⭐⭐⭐ | ⬜ | - |
| 19 | Bola Rebotando | ⭐⭐⭐ | ⬜ | - |
| 20 | Reloj Analógico | ⭐⭐⭐⭐ | ⬜ | - |

---

## 🛠️ Recursos y Referencias

### Interrupciones INT 21h (DOS)
- `AH=01h`: Leer caracter con eco
- `AH=02h`: Escribir caracter
- `AH=09h`: Escribir cadena (termina en '$')
- `AH=0Ah`: Leer cadena con buffer
- `AH=4Ch`: Terminar programa

### Interrupciones INT 10h (Video)
- `AH=00h, AL=13h`: Modo gráfico 320x200, 256 colores
- `AH=0Ch`: Escribir píxel (CX=X, DX=Y, AL=color)
- `AH=00h, AL=03h`: Modo texto 80x25

### Interrupciones INT 16h (Teclado)
- `AH=00h`: Leer tecla (espera)
- `AH=01h`: Verificar si hay tecla (no espera)

### Macros Emu8086
```assembly
DEFINE_PRINT_STRING
DEFINE_GET_STRING
PRINTN "mensaje"
PRINT "mensaje"
```

### Plantilla Base
```assembly
org 100h
jmp start

; Incluir macros de Emu8086
include 'emu8086.inc'

; Variables
; ...

start:
    ; Tu código aquí
    
    ; Salir
    mov ax, 4C00h
    int 21h
    ret

; Subrutinas
; ...

; Macros
DEFINE_PRINT_STRING
DEFINE_GET_STRING
```

---

## 📝 Notas

- Todos los ejercicios están diseñados para **Emu8086**
- Formato **.COM** (org 100h)
- Usar `include 'emu8086.inc'` para macros de entrada/salida
- Los diagramas de flujo están en formato texto descriptivo
- El pseudocódigo usa sintaxis simple y clara

---

**¡Buena suerte con tus ejercicios de ensamblador! 🚀**

*Recuerda: la práctica hace al maestro. Comienza con los ejercicios básicos y avanza gradualmente.*

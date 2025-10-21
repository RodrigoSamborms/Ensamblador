# ACTIVIDAD05_PBN - Manejo de Directorios y Archivos

**Autor:** Rodrigo Samborms  
**Fecha:** 21 de Octubre, 2025  
**Tipo:** Programa ensamblador (.COM)

---

## Diagrama de Flujo

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

## Referencias

<!-- Agregar referencias de archivos .asm aquí -->


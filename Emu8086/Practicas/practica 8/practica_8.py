INSTRUCCIONES_8086 = [
    "AAA", "AAD", "AAM", "AAS", "ADC", "ADD", "AND", "CALL", "CBW", "CLC", "CLD", "CLI", "CMC", "CMP",
    "CMPSB", "CMPSW", "CWD", "DAA", "DAS", "DEC", "DIV", "HLT", "IDIV", "IMUL", "IN", "INC", "INT", "INTO",
    "IRET", "JA", "JAE", "JB", "JBE", "JC", "JCXZ", "JE", "JG", "JGE", "JL", "JLE", "JMP", "JNA", "JNAE",
    "JNB", "JNBE", "JNC", "JNE", "JNG", "JNGE", "JNL", "JNLE", "JNO", "JNP", "JNS", "JNZ", "JO", "JP",
    "JPE", "JPO", "JS", "JZ", "LAHF", "LDS", "LEA", "LES", "LODSB", "LODSW", "LOOP", "LOOPE", "LOOPNE",
    "LOOPNZ", "LOOPZ", "MOV", "MOVSB", "MOVSW", "MUL", "NEG", "NOP", "NOT", "OR", "OUT", "POP", "POPA",
    "POPF", "PUSH", "PUSHF", "RCL", "RCR", "REP", "REPE", "REPNE", "REPNZ", "REPZ", "RET", "RETF", "ROL",
    "ROR", "SAHF", "SAL", "SAR", "SBB", "SCASB", "SCASW", "SHL", "SHR", "STC", "STD", "STI", "STOSB",
    "STOSW", "SUB", "TEST", "XCHG", "XLATB", "XOR"
]

def calcular_tamano_instruccion(instruccion):
    """Calcula el tamaño de la instrucción basado en el número de operandos."""
    tamano = 1
    if ' ' in instruccion:
        tamano += instruccion.count(',') + 1
    return tamano

def calcular_direccion_memoria(direccion_base, lineas_asm):
    """Calcula las direcciones de memoria para cada línea de instrucción."""
    direccion_actual = direccion_base
    direcciones = []
    for linea in lineas_asm:
        instruccion = linea.strip().split(' ')[0]
        tamano = calcular_tamano_instruccion(instruccion)
        direcciones.append(f"{direccion_actual:04X}")
        direccion_actual += tamano
    return direcciones

def main():
    print("Bryan Eduardo Zarate Miramontes \n"
          "Este programa identifica las direcciones\n"
          "de memoria de cada instruccion de un\n"
          "archivo con extension .asm accediendo\n"
          "la ruta del archivo a analizar.\n")
    ruta_archivo_asm = input("Ingrese la ruta del archivo .asm: ")

    try:
        with open(ruta_archivo_asm, 'r') as archivo_asm:
            lineas_asm = archivo_asm.readlines()
        
        direcciones_memoria = calcular_direccion_memoria(0x0000, lineas_asm)
        
        ruta_archivo_lst = ruta_archivo_asm.replace('.asm', '.lst')
        with open(ruta_archivo_lst, 'w') as archivo_lst:
            for direccion in direcciones_memoria:
                archivo_lst.write(f"{direccion}\n")
        
        print("Se han calculado las direcciones de memoria y se han guardado en el archivo .lst.")
    
    except FileNotFoundError:
        print("No se pudo encontrar el archivo especificado.")

if __name__ == "__main__":
    main()


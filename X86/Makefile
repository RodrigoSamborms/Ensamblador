# Makefile para compilar archivos .asm con MASM (32-bit)
# Uso: make              (compila suma.asm por defecto)
#      make PROG=nombre  (compila nombre.asm)
#      make clean        (limpia archivos generados)

# Configuración
PROG = suma
ASM = $(PROG).asm
OBJ = $(PROG).obj
EXE = $(PROG).exe

# Herramientas
MASM = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\ml.exe"
LINK = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x86\link.exe"
LIBPATH = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86"

# Opciones
ASMFLAGS = /c /coff /Zi
LINKFLAGS = /subsystem:console /libpath:$(LIBPATH)
LIBS = kernel32.lib

# Regla por defecto
all: $(EXE)

# Compilar .asm a .obj
$(OBJ): $(ASM)
	@echo Ensamblando $(ASM)...
	$(MASM) $(ASMFLAGS) /Fo$(OBJ) $(ASM)

# Enlazar .obj a .exe
$(EXE): $(OBJ)
	@echo Enlazando $(OBJ)...
	$(LINK) $(LINKFLAGS) /out:$(EXE) $(OBJ) $(LIBS)
	@echo.
	@echo Compilacion exitosa: $(EXE)

# Limpiar archivos generados
clean:
	@echo Limpiando archivos generados...
	@if exist $(OBJ) del $(OBJ)
	@if exist $(EXE) del $(EXE)
	@if exist *.pdb del *.pdb
	@if exist *.ilk del *.ilk
	@echo Limpieza completada.

# Ejecutar el programa
run: $(EXE)
	@echo Ejecutando $(EXE)...
	@$(EXE)

.PHONY: all clean run

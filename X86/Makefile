# Makefile para compilar archivos .asm con MASM en WSL (Debian/Ubuntu)
# Este Makefile está diseñado para usarse SOLO en WSL
# Para Windows, usa el script build.ps1
#
# Uso: wsl make                    (compila suma.asm por defecto)
#      wsl make PROG=nombre        (compila nombre.asm)
#      wsl make PROG=nombre OUTDIR=build  (salida a carpeta build)
#      wsl make clean               (limpia archivos generados)
#      wsl make run                 (ejecuta el programa compilado)

# Configuración
PROG = suma
OUTDIR = .
ASM = $(PROG).asm
OBJ = $(OUTDIR)/$(PROG).obj
EXE = $(OUTDIR)/$(PROG).exe

# Herramientas - Rutas /mnt/c para acceso directo desde WSL
MASM = /mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/VC/Tools/MSVC/14.42.34433/bin/Hostx64/x86/ml.exe
LINK = /mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/VC/Tools/MSVC/14.42.34433/bin/Hostx64/x86/link.exe
# Ruta Linux para LIBPATH
LIBPATH_LINUX = /mnt/c/Program\ Files\ \(x86\)/Windows\ Kits/10/Lib/10.0.22000.0/um/x86
# Convertir a ruta Windows con wslpath y reemplazar \ con \\
LIBPATH_WIN_RAW := $(shell wslpath -w '/mnt/c/Program Files (x86)/Windows Kits/10/Lib/10.0.22000.0/um/x86')
LIBPATH_WIN := $(subst \,\\,$(LIBPATH_WIN_RAW))

# Detectar si es aplicación GUI (nombres que contienen "Window")
ifeq ($(findstring Window,$(PROG)),Window)
    SUBSYSTEM = windows
    LIBS = kernel32.lib user32.lib gdi32.lib
    APP_TYPE = GUI
else
    SUBSYSTEM = console
    LIBS = kernel32.lib
    APP_TYPE = Console
endif

# Opciones para MASM y Linker
ASMFLAGS = /c /coff /Zi
LINKFLAGS = /subsystem:$(SUBSYSTEM) "/libpath:$(LIBPATH_WIN)"

# Colores para output (ANSI codes)
GREEN = \033[0;32m
YELLOW = \033[0;33m
CYAN = \033[0;36m
MAGENTA = \033[0;35m
NC = \033[0m # No Color

# Regla por defecto
all: $(EXE)

# Crear directorio de salida si no existe
$(OUTDIR):
	@mkdir -p $(OUTDIR)

# Compilar .asm a .obj
$(OBJ): $(ASM) | $(OUTDIR)
	@echo ""
	@printf "$(CYAN)=== Compilando $(ASM) ===$(NC)\n"
	@printf "$(MAGENTA)Detectado: Aplicacion $(APP_TYPE) (subsistema $(SUBSYSTEM))$(NC)\n"
	@printf "$(YELLOW)Ensamblando...$(NC)\n"
	$(MASM) $(ASMFLAGS) /Fo$(OBJ) $(ASM)

# Enlazar .obj a .exe
$(EXE): $(OBJ)
	@printf "$(YELLOW)Enlazando...$(NC)\n"
	$(LINK) $(LINKFLAGS) /out:$(EXE) $(OBJ) $(LIBS)
	@echo ""
	@printf "$(GREEN)EXITO: Se creo $(EXE)$(NC)\n"

# Limpiar archivos generados
clean:
	@printf "$(CYAN)Limpiando artefactos en: $(OUTDIR)$(NC)\n"
	@rm -f $(OUTDIR)/*.obj $(OUTDIR)/*.exe $(OUTDIR)/*.pdb $(OUTDIR)/*.ilk 2>/dev/null || true
	@printf "$(GREEN)Limpieza completada.$(NC)\n"

# Ejecutar el programa (convertir ruta a Windows y ejecutar via cmd.exe)
run: $(EXE)
	@printf "$(CYAN)Ejecutando $(EXE)...$(NC)\n"
	@cmd.exe /c $$(wslpath -w $(EXE))

.PHONY: all clean run


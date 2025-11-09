# MessageBox (API)

## Introducción
`MessageBoxA` muestra un cuadro de diálogo modal con texto, título, botones e íconos. Es útil para notificaciones, preguntas y errores.

## Prototipo
```assembly
MessageBoxA proto stdcall :DWORD, :DWORD, :DWORD, :DWORD
; hWnd (padre), lpText, lpCaption, uType
```

## Botones e íconos comunes
| Constante | Valor | Descripción |
|-----------|-------|-------------|
| MB_OK | 0x00000000 | Botón OK |
| MB_OKCANCEL | 0x00000001 | OK / Cancel |
| MB_YESNO | 0x00000004 | Yes / No |
| MB_ICONINFORMATION | 0x00000040 | Icono de información |
| MB_ICONQUESTION | 0x00000020 | Icono de pregunta |
| MB_ICONEXCLAMATION | 0x00000030 | Icono de advertencia |
| MB_ICONERROR | 0x00000010 | Icono de error |

## Valores de retorno
| Constante | Valor |
|-----------|-------|
| IDOK | 1 |
| IDCANCEL | 2 |
| IDYES | 6 |
| IDNO | 7 |

## Ejemplo
Ver `MessageBoxEjemploWindow.asm` para:
- Mostrar Info, Pregunta (Yes/No) y Error
- Manejar la respuesta de Yes/No

## Compilación
```powershell
cd .\X86\GUI_EJEMPLOS\09_MessageBox
..\..\build.ps1 MessageBoxEjemploWindow.asm -OutDir ..\build
..\build\MessageBoxEjemplo.exe
```

## Referencia rápida
```assembly
MB_OK               equ 0h
MB_OKCANCEL         equ 1h
MB_YESNO            equ 4h
MB_ICONINFORMATION  equ 40h
MB_ICONQUESTION     equ 20h
MB_ICONEXCLAMATION  equ 30h
MB_ICONERROR        equ 10h
IDOK                equ 1
IDCANCEL            equ 2
IDYES               equ 6
IDNO                equ 7
```

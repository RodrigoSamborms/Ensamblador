;Suma simple en ensamblador
.386
.model flat,stdcall
ExitProcess proto, dwExitCode:dword
.data
sum dword ?

.code
main proc
    mov eax, 7
    add eax, 4
    mov sum, eax
    invoke ExitProcess, 0
main endp
end main    
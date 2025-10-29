# Learnings about assebly languaje



Set up the Enviroment

Download FreeDOS to run in Qemu (instrucctions to Windows)

Put the iso file in the work directory

Creates a Hard Disk Drive (HDD) to use with Qemu #you can use Disk Manager to make a HDD too

\\>qemu-img create -f qcow2 freedos.img 100M





Call the virtual machine with the options to boot from the ISO file and with the HDD (virtual) attached

qemu-system-x86\_64 -hda freedos.img -cdrom FD14LIVE.iso -boot d -m 16



you can shutdown the system using the command "shutdown"



After Install FreeDOS on HDD to run from the HDD

qemu-system-i386 -hda freedos.img -boot c -m 16



qemu-system-i386 -hda freedos.img -boot c -m 16 -device sb16 #run this options to enable soundblaster 16 hardware on Qemu



qemu-system-i386 -hda freedos.img -boot c -m 16 -device sb16 -device adlib -soundhw pcspk



Create a VHDD

C:\\Users\\sambo\\Documents\\Programacion\\GitHub\\assembly

On Powershell terminal launch diskpart command

    create vdisk file="C:\\Users\\sambo\\Documents\\Programacion\\GitHub\\assembly\\virtualdisk.vhdx" maximum=260 type=fixed

    select vdisk file="C:\\Users\\sambo\\Documents\\Programacion\\GitHub\\assembly\\virtualdisk.vhdx"

    attach vdisk

    list disk

    select disk <disk\_number>

    convert mbr  (or convert gpt if preferred)

    create partition primary

    format fs=fat32 quick label="MyVHD"

    assign letter=V



    exit #para terminar

The next steps requires administrator privileges

C:\\Users\\sambo\\Documents\\Programacion\\GitHub\\assembly\\virtualdisk.vhdx	#mount a vhd from Powershell

C:\\Users\\sambo\\Documents\\Programacion\\GitHub\\assembly\\virtualdisk.vhdx #unmount a vhd from Powershell

In order to perform those actions the drive has't being used by another process

\#adittional

Get-Partition -DiskNumber (Get-DiskImage -ImagePath "your\_virtual\_drive\_path").Number | Set-Partition -NewDriveLetter G



Puede que necesite ejecutar diskpart en una sesión de Powershell con permisos de administrador

si deseamos desligar el disco virtual del exporador de windows, dentro de diskpart verificamos la lista discos virtuales

list vdisk		#listamos los discos virtuales

select vdisk file "<Dirección\_del\_disco\_virtual>" #elegir el disco con el número más bajo

detach vdisk	#revisar que el estado del disco ha cambiado

exit	#para salir





para acceder al disco nos aeguramos que no esta enlazado en el explorador y lanzamos el comando



 qemu-system-i386 -hda freedos.img -hdb .\\virtualdisk.vhdx -boot c -m 16 -device sb16



El disco será listado como D: por FreeDOS (C: será el disco de arranque)





qemu-system-x86\_64 -hda freedos.img -cdrom FD14FULL.vmdk -boot d -m 16



 sudo apt install linux-tools-common hwdata usbip


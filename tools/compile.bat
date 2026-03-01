echo off
echo =============================================
ECHO FTEQCC COMPILATION:
del ..\qc\vqmdk.pak
fteqcc-compiler\fteqcc64.exe -std=qcc -src ../qc -o ../qc/progs.dat

echo =============================================
copy ..\qc\progs.dat \quakepak
cd quakepak\
qpak64.exe p list_to_pak.txt ..\..\qc\vqmdk.pak
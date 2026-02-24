del ..\qc\progs.pak
fteqcc-compiler\fteqcc64.exe -std=qcc -src ../qc -o ../qc/progs.dat
copy ..\qc\progs.dat \quakepak
cd quakepak\
qpak64.exe p list_to_pak.txt ..\..\qc\progs.pak
# additional tools
signtool="%WindowsSdkDir%\bin\signtool.exe"
candle="%WIX%\bin\candle.exe"
light="%WIX%\bin\light.exe"

# version
version= \
	-dMajor=1 \
	-dMinor=0 \
	-dBuild=0 \
	-dRevision=0 \
	-dName="Advanced Fast User Switching" \
	-dDescription="Fast User Switching for Windows XP Professional Domain Member Workstations"

!IF "$(Configuration)" == ""
Configuration=Debug
!ENDIF
Platform=x86
OutDir=bin\$(Configuration)^\
IntDir=obj\$(Configuration)^\

# set defaults
.SUFFIXES: .wxs
APPVER=5.01
!IF "$(Configuration)" != "Debug"
nodebug=1
!ENDIF
CPU=$(Platform)
!include <win32.mak>

all: directories "$(OutDir)FUSingEx.msi"

directories:
	if not exist "$(IntDir)" mkdir "$(IntDir)"
	if not exist "$(OutDir)" mkdir "$(OutDir)"

clean: directories
	del \
		"$(OutDir)FUSingEx.msi" \
		"$(OutDir)FUSingEx.wixpdb" \
		"$(IntDir)FUSingEx.dll" \
		"$(IntDir)FUSingEx.exp" \
		"$(IntDir)FUSingEx.lib" \
		"$(IntDir)FUSingEx.obj" \
		"$(IntDir)FUSingEx.pdb" \
		"$(IntDir)FUSingEx.res" \
		"$(IntDir)FUSingEx.wixobj" 2> nul

"$(OutDir)FUSingEx.msi": "$(IntDir)FUSingEx.wixobj" "$(IntDir)FUSingEx.dll"
	$(light) -out $@ "$(IntDir)FUSingEx.wixobj"
!IF "$(Configuration)" != "Debug"
	$(signtool) sign $@
!ENDIF

"$(IntDir)FUSingEx.dll": FUSingEx.def "$(IntDir)FUSingEx.obj" "$(IntDir)FUSingEx.res"
	$(link) $(ldebug) $(dlllflags) -out:$@ -def:FUSingEx.def "$(IntDir)FUSingEx.obj" "$(IntDir)FUSingEx.res" $(guilibsmt)
!IF "$(Configuration)" != "Debug"
	$(signtool) sign $@
!ENDIF

{}.c{$(IntDir)}.obj:
	$(cc) $(cdebug) $(cflags) $(cvarsmt) /D_UNICODE /DUNICODE /Fd"$(IntDir)FUSingEx.pdb" /Fo$@ $<

{}.wxs{$(IntDir)}.wixobj:
	$(candle) $(version) -arch $(Platform) -dPlatform=$(Platform) -out $@ $<

{}.rc{$(IntDir)}.res:
	$(rc) $(rcflags) $(rcvars) $(version) /D_UNICODE /DUNICODE /Fo$@ $<

# DWFXOUTCLI

An AutoCAD command to get DWFX output from a DWG, this command can be scriptable.

For more information refer [3DDWF](https://knowledge.autodesk.com/support/autocad/learn-explore/caas/CloudHelp/cloudhelp/2020/ENU/AutoCAD-Core/files/GUID-8D5FEF23-3399-4948-98FE-B3DDCF50E269-htm.html)

# Build

### Expected Compiled Output

```bash
Microsoft (R) Build Engine version 16.8.3+39993bd9d for .NET Framework
Copyright (C) Microsoft Corporation. All rights reserved.

Building the projects in this solution one at a time. To enable parallel build, please add the "-m" switch.
Build started 20-01-2021 11:00:27.
Project "D:\Work\Arxprojects\2021\dwfoutArx\dwfout.sln" on node 1 (build target(s)).
ValidateSolutionConfiguration:
  Building solution configuration "Debug|x64".
Project "D:\Work\Arxprojects\2021\dwfoutArx\dwfout.sln" (1) is building "D:\Work\Arxprojects\2021\dwfoutArx\dwfout.vcxproj" (2) on node 1 (default targets).
InitializeBuildStatus:
  Touching "x64\Debug\dwfout.tlog\unsuccessfulbuild".
ClCompile:
  All outputs are up-to-date.
Link:
  C:\vs2019\VC\Tools\MSVC\14.28.29333\bin\HostX86\x64\link.exe /ERRORREPORT:QUEUE /OUT:"D:\Work\Arxprojects\2021\dwfoutArx\x64\Debug\dwfout.arx" /INCREMENTAL:NO /NOLOGO /LIBPATH:"D:\work\ArxSdks\Obj
  ectARX2021\lib-x64" /LIBPATH:"D:\Work\ObjectARX2021\lib-x64" accore.lib acad.lib acui24.lib adui24.lib ac1st24.lib acdb24.lib acge24.lib acgiapi.lib acISMobj24.lib rxapi.lib kernel32.lib user32.li
  b gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /DEF:"D:\work\ArxSdks\ObjectARX2021\inc\AcRxDefault.def" /MANIFEST /MANIFESTU
  AC:"level='asInvoker' uiAccess='false'" /manifest:embed /DEBUG /PDB:"D:\Work\Arxprojects\2021\dwfoutArx\x64\Debug\dwfout.pdb" /SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF /TLBID:1 /DYNAMICBASE /NXCOMPAT /
  IMPLIB:"x64\Debug\dwfout.lib" /MACHINE:X64 /CLRTHREADATTRIBUTE:STA /CLRIMAGETYPE:IJW /CLRUNMANAGEDCODECHECK /DLL x64\Debug\dwfout.obj
     Creating library x64\Debug\dwfout.lib and object x64\Debug\dwfout.exp
rxapi.lib(libinit.obj) : warning LNK4099: PDB '' was not found with 'rxapi.lib(libinit.obj)' or at ''; linking object as if no debug info [D:\Work\Arxprojects\2021\dwfoutArx\dwfout.vcxproj]
  dwfout.vcxproj -> D:\Work\Arxprojects\2021\dwfoutArx\x64\Debug\dwfout.arx
FinalizeBuildStatus:
  Deleting file "x64\Debug\dwfout.tlog\unsuccessfulbuild".
  Touching "x64\Debug\dwfout.tlog\dwfout.lastbuildstate".
Done Building Project "D:\Work\Arxprojects\2021\dwfoutArx\dwfout.vcxproj" (default targets).

Done Building Project "D:\Work\Arxprojects\2021\dwfoutArx\dwfout.sln" (build target(s)).


Build succeeded.

"D:\Work\Arxprojects\2021\dwfoutArx\dwfout.sln" (build target) (1) ->
"D:\Work\Arxprojects\2021\dwfoutArx\dwfout.vcxproj" (default target) (2) ->
(Link target) ->
  rxapi.lib(libinit.obj) : warning LNK4099: PDB '' was not found with 'rxapi.lib(libinit.obj)' or at ''; linking object as if no debug info [D:\Work\Arxprojects\2021\dwfoutArx\dwfout.vcxproj]

    1 Warning(s)
    0 Error(s)

Time Elapsed 00:00:01.30
```



# DEMO



## License

This sample is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Please see the [LICENSE](https://github.com/MadhukarMoogala/design-migration/blob/master/LICENSE) file for full details.

## Written by

Madhukar Moogala, [Forge Partner Development](http://forge.autodesk.com/) @galakar
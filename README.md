# DWFXOUT

An AutoCAD command, `DWFOUTCLI`, that exports a DWG to DWFX. It is scriptable, so it works in `accoreconsole.exe` and Design Automation. Supports AutoCAD 2026 and 2027.

For background see [3D DWF](https://knowledge.autodesk.com/support/autocad/learn-explore/caas/CloudHelp/cloudhelp/2020/ENU/AutoCAD-Core/files/GUID-8D5FEF23-3399-4948-98FE-B3DDCF50E269-htm.html).

![Demo](DWFXCLI.gif)

## Prerequisites

- Visual Studio 2026 with the **Desktop development with C++** workload, plus the **MSVC v143** toolset, **ATL** and **MFC** components.
- ObjectARX SDK for each AutoCAD version you target (2026, 2027).

## Build

Open a **Developer Command Prompt for VS 2026**:

```bat
git clone https://github.com/MadhukarMoogala/dwfout.git
cd dwfout
msbuild dwfout.vcxproj /p:Configuration=Release /p:Platform=x64 /p:ArxVersion=2027 /p:ArxSdkDir=C:\path\to\ARX2027
```

| Property | Meaning | Default |
|---|---|---|
| `ArxVersion` | SDK year: `2026` or `2027` | `2026` |
| `ArxSdkDir` | ObjectARX SDK folder (contains `inc\` and `lib-x64\`) | `<ArxSdkRoot>\ARX<ArxVersion>` |
| `ArxSdkRoot` | Folder holding `ARX2026`, `ARX2027`, ... | `D:\SDKS` |
| `ArxModuleType` | `arx` for AutoCAD, `crx` for accoreconsole / Design Automation | `arx` |
| `ArxPlatformToolset` | MSVC toolset | `v143` |
| `ArxCppStandard` | C++ standard | `stdcpp17` |

Output: `bins\<ArxVersion>\dwfout.arx` or `dwfout.crx`. Settings live in `ArxSdk.props` and `Crx.props`.

Build both module types for one version:

```bat
msbuild dwfout.vcxproj /p:Configuration=Release /p:Platform=x64 /p:ArxVersion=2026 /p:ArxSdkDir=C:\path\to\ARX2026 /p:ArxModuleType=arx
msbuild dwfout.vcxproj /p:Configuration=Release /p:Platform=x64 /p:ArxVersion=2026 /p:ArxSdkDir=C:\path\to\ARX2026 /p:ArxModuleType=crx
```

An ARX built against one SDK year only loads in that AutoCAD year.

## Use

In AutoCAD (`.arx`) or accoreconsole (`.crx` only):

```lisp
(arxload "C:/path/to/bins/2027/dwfout.crx")
DWFOUTCLI
```

It prompts for the output file name, then `Objects to publish` (`_ALL`) and `Publish With Materials` (`_YES`). Script example:

```
(arxload "C:/path/to/bins/2027/dwfout.crx")
DWFOUTCLI
C:/temp/out.dwfx
_ALL
_YES
_.QUIT Y
```

## Test

Builds the CRX for each version, runs `DWFOUTCLI` on `solids.dwg` in `accoreconsole.exe` and checks that a valid DWFX is produced:

```powershell
.\tests\Test-DwfOut.ps1 -SdkRoot C:\SDKS -AcadRoot "C:\Program Files\Autodesk"
.\tests\Test-DwfOut.ps1 -Versions 2027 -OutputDir .\testout   # keep the DWFX files
```

Expects `<SdkRoot>\ARX<year>` and `<AcadRoot>\AutoCAD <year>\accoreconsole.exe`.

## License

[MIT](LICENSE)

## Written by

Madhukar Moogala, [Forge Partner Development](http://forge.autodesk.com/) @galakar

IF DEFINED VS140COMNTOOLS (
  SET GENERATOR="Visual Studio 14"
)
IF NOT DEFINED GENERATOR (
  FOR /F %%I IN ('REG QUERY HKLM\SOFTWARE\WOW6432Node\Microsoft ^| FINDSTR "VisualStudio_"') DO CALL :FINDVS "%%~I" 2019
)
IF NOT DEFINED GENERATOR (
  FOR /F "tokens=1,2,*" %%I IN ('REG QUERY HKLM\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7 /v 15.0 ^| FINDSTR "15.0"') DO SET GENERATOR="Visual Studio 15"
)
IF NOT DEFINED GENERATOR (
  ECHO Can not find VC2015 or VC2017 or VC2019 installed!
  GOTO ERROR
)
PUSHD "%~dp0"
SET rootdir=%~dp0
SET rootdir=%rootdir:~0,-1%
SET tmpdir=%~d0\tmp_libsundaowen_astc-encoder
SET target=windows_x86_32
SET prefix=%tmpdir%\%target%
SET version=astc-encoder_src
RD /S /Q "%tmpdir%\%version%"
MD "%tmpdir%\%version%"
XCOPY "..\%version%" "%tmpdir%\%version%" /S /Y
PUSHD "%tmpdir%\%version%"
RD /S /Q build
MD build
CD build
cmake -C "%rootdir%\CMakeLists-MSVC.txt" -DSHAREDLIB=ON -DCLI=OFF -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX="%prefix%" -G %GENERATOR% -T v140_xp -A Win32 ..
cmake --build . --target astcenc-native-shared --config Release --clean-first
POPD
MD "..\target\include\astc-encoder"
XCOPY "%tmpdir%\%version%\Source\astcenc.h" "..\target\include\astc-encoder" /S /Y
MD "..\target\lib\%target%"
COPY /Y "%tmpdir%\%version%\build\Source\Release\*.lib" "..\target\lib\%target%"
COPY /Y "%tmpdir%\%version%\build\Source\Release\*.dll" "..\target\lib\%target%"
POPD
RD /S /Q "%tmpdir%"
GOTO :EOF

:FINDVS
SET vsid=%~1
SET vsid=%vsid:~63%
REG QUERY %~1\Capabilities | FINDSTR /R "ApplicationName.*REG_SZ.*Microsoft.Visual.Studio.%~2" && FOR /F "tokens=1,2,*" %%I IN ('REG QUERY HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%vsid% ^| FINDSTR "InstallLocation"') DO SET GENERATOR="Visual Studio 16"
GOTO :EOF

:ERROR
PAUSE

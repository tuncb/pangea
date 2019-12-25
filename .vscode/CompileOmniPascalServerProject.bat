@echo off

SET MSBUILD="C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
SET RSVARS="C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\rsvars.bat"
SET PROJECT="C:\work\pangea\PangeaTester.dproj"

call %RSVARS%
%MSBUILD% %PROJECT% "/t:Clean,Make" "/verbosity:minimal"

if %ERRORLEVEL% NEQ 0 GOTO END

echo.

if "%1"=="" goto END

if /i %1%==test (
  pushd "C:\work\pangea\Win64\Debug"
  "C:\work\pangea\Win64\Debug\PangeaTester.exe"
  popd
)
:END

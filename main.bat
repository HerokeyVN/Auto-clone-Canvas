@echo off
setlocal

:: Setting
  :: Number of APK wants to be cloned
set Quantity=10
  :: Name of the original APK file (excluding .apk file tail)
set APKfile=Canvas
  :: APK application name after cloning (excluding .apk file tail)
set APKclone=Light
  :: Work directory (no need to edit this item)
set tempDir=temp

:: The path to the original APK and the working folder
set "originalApkPath=%~dp0%APKfile%.apk"
set "workingDirectory=%~dp0%tempDir%"
set "pathSigned=%~dp0signed"
set "pathKeystore=%~dp0android-i5jtD.keystore"
set "keystore_password=wDHFzXQ3fuylFbRw"
set "keystore_alias=keyalias"

:: The function to compile the APK reverse
call echo y|"%~dp0apktool\apktool.bat" d -f "%APKfile%.apk" -o %tempDir%

for /l %%i in (1,1,%Quantity%) do (
    setlocal enabledelayedexpansion
    set "stt=%%i"
    set "newPackageName=git.artdeell.skymodloader!stt!"
    set "newAppName=!APKclone!!stt!"
    set "newApkName=!newAppName!.apk"
    set "decompiledDirectory=%workingDirectory%"
    echo ~~~~~~~~~~~~~~~~~~~~~
    echo Clone APK !newApkName!
    echo ~~~~~~~~~~~~~~~~~~~~~

    :: Change Package Name and App Name
    echo Change the Package Name and App Name for !newApkName!
    call :changeAppInfo "!decompiledDirectory!\AndroidManifest.xml" "!newPackageName!" "!newAppName!"

    :: Translate APK again
    echo Border translation for !newApkName!
    call :recompileApk "./!tempDir!" "./!tempDir!/unalign.apk"

    :: Sign for APK
    echo Sign name for !newApkName!
    call :signApk "!pathKeystore!" "!keystore_password!" "!keystore_alias!" "!workingDirectory!\align.apk" "!pathSigned!\!newApkName!"

    ::move /y "!decompiledDirectory!\AndroidManifest.xml.old" "!decompiledDirectory!\AndroidManifest.xml"
    endlocal
)

echo APK cloning has completed.
goto :eof

:changeAppInfo
setlocal
set "manifestPath=%~1"
set oldPackageName=package="git.artdeell.skymodloader"
set newPackageName="%~2"
set "newAppName=%~3"
for /f "usebackq delims=" %%a in ("%manifestPath%") do (
    set "line=%%a"
    setlocal enabledelayedexpansion
    set "line=!line:"git.artdeell.skymodloader"=%newPackageName%!"
    set "line=!line:@string/app_name=%newAppName%!"
    echo(!line!
    endlocal
) >> "%manifestPath%.tmp"
move /y "%manifestPath%" "%manifestPath%.old"
move /y "%manifestPath%.tmp" "%manifestPath%"
goto :eof

:recompileApk
setlocal
set "decompiledDirectory=%~1"
set "outputApkPath=%~2"
call echo y|"%~dp0apktool\apktool.bat" b -f %decompiledDirectory% -o %outputApkPath%
call "%~dp0android_sdk\latest\build-tools\34.0.0\zipalign.exe" -f -v 4 "%workingDirectory%\unalign.apk" "%workingDirectory%\align.apk"
goto :eof

:signApk
setlocal
set "keystorePath=%~1"
set "storepass=%~2"
set "alias=%~3"
set "unsignedApkPath=%~4"
set "signedApkPath=%~5"
call "%~dp0android_sdk\latest\build-tools\34.0.0\apksigner.bat" sign --ks "%keystorePath%" --ks-pass pass:%storepass% --out "%signedApkPath%" --ks-key-alias %alias% "%unsignedApkPath%"
del /q "%signedApkPath%.idsig"
goto :eof
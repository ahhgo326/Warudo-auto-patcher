@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul

:: 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :admin_ok
) else (
    echo 이 스크립트는 관리자 권한이 필요합니다.
    echo 관리자 권한으로 다시 실행해주세요.
    pause
    exit /b 1
)

:admin_ok
echo.
echo "  .----.   .-----.  .-----.   ,--.    "
echo " /  ..  \ /  -.   \/ ,-.   \ /  .'    "
echo ".  /  \  .'-' _'  |'-'  |  |.  / -.   "
echo "|  |  '  |   |_  <    .'  / | .-.  '  "
echo "'  \  /  '.-.  |  | .'  /__ ' \  |  | "
echo " \  `'  / \ `-'   /|       |\  `'  /  "
echo "  `---''   `----'' `-------' `----'   "
echo.
echo 와루도 씬, 아바타 자동 설치 스크립트를 시작합니다.
echo 제작: 아트머그 0326 작가
echo 빌드: 2024-07-19
echo.

echo 다음 와루도 씬, 아바타 파일을 복사합니다:
for %%F in ("%~dp0*.json") do echo    - 씬 파일: %%~nxF
for %%F in ("%~dp0*.png") do echo    - 썸네일 파일: %%~nxF
for %%F in ("%~dp0*.warudo") do (
    for %%A in ("%%~F") do set "size=%%~zA"
    if !size! leq 104857600 (
        echo    - 프롭 파일: %%~nxF
    ) else (
        echo    - 아바타 파일: %%~nxF
    )
)
for %%F in ("%~dp0*.wav") do echo    - 음악 파일: %%~nxF
for %%F in ("%~dp0*.vmd") do echo    - MMD 파일: %%~nxF
echo.

if not exist "%~dp0*.json" if not exist "%~dp0*.png" if not exist "%~dp0*.warudo" if not exist "%~dp0*.wav" if not exist "%~dp0*.vmd" (
    echo 경고: 현재 디렉토리에서 씬, 아바타, 음악, MMD 파일을 찾을 수 없습니다.
    echo 스크립트 파일과 같은 폴더에 JSON, PNG, Warudo, WAV, VMD 파일이 있는지 확인해주세요.
    goto :end
)

echo 엔터를 누르면 바로 작업이 시작됩니다.
pause >nul

echo.
echo Warudo 설치 경로를 찾는 중...
timeout /t 1 /nobreak >nul
set "warudo_path="
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\SteamLibrary\steamapps\common\Warudo\Warudo_Data\StreamingAssets" (
        set "warudo_path=%%d:\SteamLibrary\steamapps\common\Warudo\Warudo_Data\StreamingAssets"
        echo Warudo 설치 경로를 찾았습니다: !warudo_path!
        goto :found
    )
)

:not_found
echo Warudo 설치 경로를 찾을 수 없습니다.
goto :end

:found
if not exist "!warudo_path!\Scenes" mkdir "!warudo_path!\Scenes"
if not exist "!warudo_path!\Characters" mkdir "!warudo_path!\Characters"
if not exist "!warudo_path!\Props" mkdir "!warudo_path!\Props"
if not exist "!warudo_path!\Music" mkdir "!warudo_path!\Music"
if not exist "!warudo_path!\MMD" mkdir "!warudo_path!\MMD"

set "error_occurred=false"

for %%F in ("%~dp0*.json") do (
    call :copy_file "%%~F" "!warudo_path!\Scenes\%%~nxF"
    if !errorlevel! neq 0 set "error_occurred=true"
)

for %%F in ("%~dp0*.png") do (
    call :copy_file "%%~F" "!warudo_path!\Scenes\%%~nxF"
    if !errorlevel! neq 0 set "error_occurred=true"
)

for %%F in ("%~dp0*.warudo") do (
    for %%A in ("%%~F") do set "size=%%~zA"
    if !size! leq 104857600 (
        call :copy_file "%%~F" "!warudo_path!\Props\%%~nxF"
    ) else (
        call :copy_file "%%~F" "!warudo_path!\Characters\%%~nxF"
    )
    if !errorlevel! neq 0 set "error_occurred=true"
)

for %%F in ("%~dp0*.wav") do (
    call :copy_file "%%~F" "!warudo_path!\Music\%%~nxF"
    if !errorlevel! neq 0 set "error_occurred=true"
)

for %%F in ("%~dp0*.vmd") do (
    call :copy_file "%%~F" "!warudo_path!\MMD\%%~nxF"
    if !errorlevel! neq 0 set "error_occurred=true"
)

if "%error_occurred%"=="true" (
    echo.
    echo 일부 파일 복사 중 오류가 발생했습니다.
    goto :cleanup
) else (
    echo.
    echo 모든 파일이 성공적으로 복사되었습니다.
    goto :end
)

:copy_file
echo.
echo 파일을 복사하는 중...
set "source=%~1"
set "dest=%~2"
copy "%source%" "%dest%" >nul
if %errorlevel% neq 0 (
    echo 파일 복사 실패: %source%
    echo 오류 코드: %errorlevel%
    exit /b 1
) else (
    echo 파일을 "%dest%"에 성공적으로 복사했습니다.
    timeout /t 1 /nobreak >nul
    exit /b 0
)

:cleanup
echo.
echo 오류가 발생하여 복사된 파일을 제거합니다.
for %%F in ("%~dp0*.json") do if exist "!warudo_path!\Scenes\%%~nxF" del "!warudo_path!\Scenes\%%~nxF"
for %%F in ("%~dp0*.png") do if exist "!warudo_path!\Scenes\%%~nxF" del "!warudo_path!\Scenes\%%~nxF"
for %%F in ("%~dp0*.warudo") do (
    for %%A in ("%%~F") do set "size=%%~zA"
    if !size! leq 104857600 (
        if exist "!warudo_path!\Props\%%~nxF" del "!warudo_path!\Props\%%~nxF"
    ) else (
        if exist "!warudo_path!\Characters\%%~nxF" del "!warudo_path!\Characters\%%~nxF"
    )
)
for %%F in ("%~dp0*.wav") do if exist "!warudo_path!\Music\%%~nxF" del "!warudo_path!\Music\%%~nxF"
for %%F in ("%~dp0*.vmd") do if exist "!warudo_path!\MMD\%%~nxF" del "!warudo_path!\MMD\%%~nxF"

:end
echo.
echo 엔터 키를 누르면 프로그램이 종료됩니다...
pause >nul
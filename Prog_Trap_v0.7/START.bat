@echo off
setlocal EnableExtensions

rem --- нейтрализуем переменные окружения, мешающие конфигу ---
set "AVRDUDE_CONF=" & set "AVRCONFFILE=" & set "AVRDUDE_CONFIG="

rem --- пути ---
set "DIR=%~dp0"
set "AVRD=%DIR%avrdude.exe"
set "CONF=%DIR%avrdude.conf"
set "HEX=%DIR%firmware.hex"
if exist "%~1" set "HEX=%~1"

rem --- параметры ---
set "MCU=m2560"
set "PROG=avrispmkII"
set "PORT=usb"
set "B=50"
set "EF=0xFD" & set "HF=0xD9" & set "LF=0xE2"

cls
echo ==== %date% %time% ====
echo [INFO] One-call flasher (B=%B%)
echo [PATH] AVRD="%AVRD%"
echo [PATH] CONF="%CONF%"
echo [PATH] HEX ="%HEX%"

if not exist "%AVRD%" echo [ERR ] avrdude.exe not found & goto HOLD
if not exist "%CONF%" echo [ERR ] avrdude.conf not found & goto HOLD
if not exist "%HEX%"  echo [ERR ] HEX not found: "%HEX%" & goto HOLD

echo.
echo [CTRL] Connect AVRISP mkII, hook 6-pin ISP, POWER the target.
echo [CTRL] Press any key to START...
pause >nul

rem ======== ЗАПУСК: фьюзы + прошивка ========
echo.
echo [STEP] Program fuses (E=%EF% H=%HF% L=%LF%) + flash "%HEX%"  (-B %B%)
"%AVRD%" -C "%CONF%" -p %MCU% -c %PROG% -P %PORT% -B %B% -v -u -U efuse:w:%EF%:m -U hfuse:w:%HF%:m -U lfuse:w:%LF%:m -U flash:w:"%HEX%":i
set "RC=%ERRORLEVEL%"
echo [RET ] avrdude=%RC%
if not "%RC%"=="0" goto HOLD

rem ======== ПОСТ-ПРОВЕРКА: сигнатура и фьюзы ========
echo.
echo [POST] Probe device (signature + safemode fuses)
"%AVRD%" -C "%CONF%" -p %MCU% -c %PROG% -P %PORT% -B %B% -v -n

echo.
echo [POST] LFUSE:
"%AVRD%" -C "%CONF%" -p %MCU% -c %PROG% -P %PORT% -B %B% -q -q -U lfuse:r:-:h

echo.
echo [POST] HFUSE:
"%AVRD%" -C "%CONF%" -p %MCU% -c %PROG% -P %PORT% -B %B% -q -q -U hfuse:r:-:h

echo.
echo [POST] EFUSE:
"%AVRD%" -C "%CONF%" -p %MCU% -c %PROG% -P %PORT% -B %B% -q -q -U efuse:r:-:h

:HOLD
echo.
echo [HOLD] Complete. Press any key to exit, or leave this window open.
pause >nul
exit /b

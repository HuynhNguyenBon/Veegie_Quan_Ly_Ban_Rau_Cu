@echo off
cd /d "%~dp0"
title Veggie - Website ban rau cu
dotnet run --project backend\Veggie.Api --no-launch-profile --urls http://127.0.0.1:5500
pause

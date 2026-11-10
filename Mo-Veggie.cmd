@echo off
cd /d "%~dp0"
title Veggie - Website ban rau cu
dotnet run --project backend\Veggie.Api --launch-profile http
pause

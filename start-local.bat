@echo off
chcp 65001 >nul
cd /d D:\myblog
echo 启动本地预览: http://localhost:1313/
echo 按 Ctrl+C 停止
hugo serve -D --baseURL http://localhost:1313/
pause
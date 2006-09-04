@echo off
pushd %~dp0
tools\want.exe clean-all ntfslinkext translate clean
popd

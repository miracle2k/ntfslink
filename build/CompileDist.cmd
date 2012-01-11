@echo off
pushd %~dp0
want\want.exe clean-all ntfslinkext translate clean
popd

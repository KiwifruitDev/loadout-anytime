@echo off
:: Configuration
set PLUGIN=loadout_anytime
set SELF=.\
set MOD=..\tf\
set SHOULD_COPY_TO_SELF=1
set SHOULD_COPY_TO_MOD=1
set SHOULD_PAUSE=0
:: Compilation
%MOD%addons\sourcemod\scripting\spcomp.exe %SELF%addons\sourcemod\scripting\%PLUGIN%.sp
if %SHOULD_COPY_TO_SELF%==1 copy /y %SELF%addons\sourcemod\scripting\compiled\%PLUGIN%.smx %SELF%addons\sourcemod\plugins\%PLUGIN%.smx
if %SHOULD_COPY_TO_MOD%==1 copy /y %SELF%addons\sourcemod\scripting\compiled\%PLUGIN%.smx %MOD%addons\sourcemod\plugins\%PLUGIN%.smx
if %SHOULD_PAUSE%==1 pause

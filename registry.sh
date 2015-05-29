POL_Wine_CustomExportRegistryKey()
{
	# Export a registry key to a registry file in tmp folder
	# Needs : POL_System_TmpCreate
	# Usage : POL_Wine_CustomGetRegValue RegKey File
	# Returns : nothing
	# Example : POL_Wine_CustomGetRegValue "HKEY_LOCAL_MACHINE\Software\Monolith Productions\No One Lives Forever 2\1.0" "nolf2.reg"
		
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	regedit /E $POL_System_TmpDir/$2 "$1"
}

POL_Wine_CustomGetRegValue()
{
	# Get a value in a registry file in tmp folder
	# Needs : POL_System_TmpCreate
	# Usage : POL_Wine_CustomGetRegValue RegValue File
	# Returns : registry value
	# Example : POL_Wine_CustomGetRegValue "NetRegionCode" "nolf2.reg"
	
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	local value
	[ -e "$POL_System_TmpDir/$2" ] && value="$(grep "$1" "$POL_System_TmpDir/$2" | head -n 1 | tr -d '"' | cut -d= -f2 | tr -d '\015')"
	POL_Debug_Message "Getting registry value $1 on file $2. Return: $value"
	echo -n "${value:-default}"
}

POL_Wine_CustomConvertRegPathToLinuxPrefix()
{
	# Convert a windows registry path info to a linux path inside prefix
	# Needs : POL_Wine_SelectPrefix - POL_Wine_PrefixCreate
	# Usage : POL_Wine_CustomConvertRegPathToLinuxPrefix Path
	# Returns : linux path inside prefix
	# Example : POL_Wine_CustomConvertRegPathToLinuxPrefix "C:\\Program Files\\Fox\\No One Lives Forever 2"
	
	[ -z "$WINEPREFIX" ] && POL_Debug_Fatal "WINEPREFIX not set"
	[ -z "$1" ] && POL_Debug_Fatal "Need PATH as only argument"
	local path
	# TODO : add driver letter substitution
	path="${1/C:\\\\/drive_c/}"
	path="$WINEPREFIX/${path//\\\\//}"
	echo -n "$path"
}

POL_Nolf2_SetLanguage()
{
	# Sets Nolf2 language in registry
	# Needs : POL_Wine_SelectPrefix - POL_Wine_PrefixCreate - POL_System_TmpCreate
	# Usage : POL_Nolf2SetLanguage LanguageCode
	# Returns : nothing
	# Example : POL_Nolf2SetLanguage "EN"
	
	[ -z "$WINEPREFIX" ] && POL_Debug_Fatal "WINEPREFIX not set"
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	[ -z "$1" ] && POL_Debug_Fatal "Need LANG CODE as only argument"
	local regfile
	regfile="$POL_System_TmpDir/nolf2_lang.reg"
	echo "[HKEY_LOCAL_MACHINE\\Software\\Monolith Productions\\No One Lives Forever 2\\1.0]" > regfile
	echo "\"NetRegionCode\"=\"$1\"" >> regfile
	regedit regfile
	rm -f regfile
}

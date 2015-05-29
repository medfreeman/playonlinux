local URL="$1"
local FILE="$2"
local NAME="$3"
local SERVER_MD5="$4"
POL_System_wget "http://community.pcgamingwiki.com/files/download/$URL" "$NAME" -O "$FILE"
local LOCAL_MD5="$(POL_MD5_file "$FILE")"
if [ "$LOCAL_MD5" = "$SERVER_MD5" ]
    then
        POL_Debug_Message "Download MD5 matches"
    else
        POL_SetupWindow_question "$URL\n\n$(eval_gettext 'Error ! Files mismatch\n\nLocal : $LOCAL_MD5\nServer : $SERVER_MD5')\n\n$(eval_gettext 'Do you want to retry?')"
        if [ "$APP_ANSWER" = "TRUE" ]; then
                POL_PCGamingWiki_Download "$URL" "$FILE" "$NAME" "$SERVER_MD5"
        else
                POL_Debug_Error "MD5 sum mismatch !"
        fi
    fi

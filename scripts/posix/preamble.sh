# ==============================================================================
# POSIX SHELL LIBRARY (Namespace: psx::)
# A collision-resistant standard library for POSIX sh.
# Compatible with: bash, dash, ksh, zsh, ash.
#
# USAGE:
#   . "/path/to/lib.sh"
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: psx::log
# Purpose : Standardized logger. DEBUG messages are hidden unless DEBUG=1.
# Usage   : psx::log <level> <message...>
#
# Arguments:
#   $1 : Level (INFO, DEBUG, WARN, ERROR, FATAL)
#   $@ : Message content (accepts multiple arguments)
#
# Environment:
#   DEBUG : Set to any non-empty value to reveal [DEBUG] messages.
#
# Examples:
#   psx::log "INFO" "Script initialized"
#   psx::log "WARN" "Configuration file not found, using defaults"
#   psx::log "DEBUG" "Current iterator value: $i"
# ------------------------------------------------------------------------------
psx::log() {
    # 1. Strict Check: If level is DEBUG and $DEBUG is unset/empty, return immediately.
    #    We use "x$1" to prevent syntax errors if $1 is empty or a hyphen.
    if [ "x$1" = "xDEBUG" ] && [ -z "$DEBUG" ]; then
        return 0
    fi

    # 2. Variable Hygiene: Use a prefixed variable to avoid polluting the global scope.
    _psx_log_level="$1"
    shift

    # 3. Output: Use printf for safety (echo behavior varies across POSIX shells).
    #    "$*" combines all remaining arguments into a single string.
    printf '[%s] %s\n' "$_psx_log_level" "$*" >&2
}

# ------------------------------------------------------------------------------
# Function: psx::die
# Purpose : Log a fatal error and return a failure code.
#           It does NOT exit the shell directly, allowing for interactive safety.
# Usage   : psx::die <message> [exit_code]
#
# Arguments:
#   $1 : Message string (Required).
#   $2 : Exit Code      (Optional). Defaults to 1.
#
# CRITICAL USAGE NOTE:
#   Because this function uses 'return' (to avoid killing your terminal),
#   the CALLER must handle the flow control.
#
# Examples:
#   # Correct Usage (Stops the script safely):
#   psx::command_exists "git" || { psx::die "Git missing" || return 1; }
#
#   # Simple One-Liner (most common):
#   [ -f "config" ] || psx::die "Config missing" || return 1
# ------------------------------------------------------------------------------
psx::die() {
    psx::log "FATAL" "$1"
    # Return the code provided, or default to 1.
    return "${2:-1}"
}

# ------------------------------------------------------------------------------
# Function: psx::include
# Purpose : Source a file safely with error context and readability checks.
# Usage   : psx::include <context> <file> [line_no] [silent_mode]
# Returns : 0 if sourced successfully, 1 if failed.
#
# Arguments:
#   $1 : Context Name (Required). Usually "$0" (script name).
#   $2 : File Path    (Required).
#   $3 : Line Number  (Optional). Pass "$LINENO" for debugging, or "" to skip.
#   $4 : Silent Mode  (Optional). Pass "silent" to suppress warnings.
#
# Examples:
#   # Mandatory include (Stop if missing):
#   psx::include "$0" "./core.sh" "$LINENO" || psx::die "Core missing" || return 1
#
#   # Optional include (Silent if missing):
#   psx::include "$0" "./.env.local" "" "silent"
# ------------------------------------------------------------------------------
psx::include() {
    # Check if file exists (-f) AND is readable (-r)
    if [ -f "$2" ] && [ -r "$2" ]; then
        psx::log "DEBUG" "Loaded: $2"
        . "$2"
        return 0
    else
        # Only print warning if $4 (silent mode) is empty
        if [ -z "$4" ]; then
            # Construct error: [Context:Line]: Message
            # ${3:+:$3} expands to ":$3" only if $3 is not empty.
            psx::log "WARN" "[${1}${3:+:$3}]: missing or unreadable file: $2"
        fi
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Function: psx::path_prepend
# Purpose : Prepend a directory to PATH only if it exists and isn't already there.
# Usage   : psx::path_prepend <directory_path>
#
# Arguments:
#   $1 : Directory Path (Required).
#
# Examples:
#   psx::path_prepend "$HOME/bin"
#   psx::path_prepend "/opt/homebrew/bin"
# ------------------------------------------------------------------------------
psx::path_prepend() {
    if [ -d "$1" ]; then
        # Wrap PATH in colons to ensure exact string matching
        case ":$PATH:" in
            *":$1:"*)
                psx::log "DEBUG" "Path duplicate ignored: $1"
                ;;
            *)
                # Append if PATH exists, otherwise just set it.
                # ${PATH:+":$PATH"} adds the colon only if PATH is not empty.
                PATH="$1${PATH:+":$PATH"}"
                export PATH
                psx::log "DEBUG" "Path added: $1"
                ;;
        esac
    fi
}

# ------------------------------------------------------------------------------
# Function: psx::command_exists
# Purpose : Check if a command exists in the system PATH.
# Usage   : psx::command_exists <command_name> [silent_mode]
# Returns : 0 if found, 1 if missing.
#
# Arguments:
#   $1 : Command Name (Required).
#   $2 : Silent Mode  (Optional). Pass "silent" to suppress missing warnings.
#
# Examples:
#   # Standard check:
#   psx::command_exists "curl" || psx::die "Curl is required" || return 1
#
#   # Silent check for conditional logic:
#   if psx::command_exists "docker" "silent"; then ...
# ------------------------------------------------------------------------------
psx::command_exists() {
    # Guard against empty arguments
    [ -n "$1" ] || return 1

    # command -v is the POSIX standard for checking executables (not 'which')
    if command -v "$1" >/dev/null 2>&1; then
        psx::log "DEBUG" "Command found: $1"
        return 0
    else
        if [ -z "$2" ]; then
            psx::log "WARN" "Command not found: $1"
        fi
        return 1
    fi
}

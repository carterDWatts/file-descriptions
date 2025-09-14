#!/bin/zsh

# File Descriptions Plugin
# Adds descriptions to files and directories with enhanced ls

DESC_FILE="$HOME/.file_descriptions"

# Initialize description file if it doesn't exist
_desc_init() {
    [[ ! -f "$DESC_FILE" ]] && /usr/bin/touch "$DESC_FILE"
}

# Get full path of a file/directory  
_desc_fullpath() {
    local item="$1"
    if [[ -d "$item" ]]; then
        (cd "$item" && /bin/pwd)
    elif [[ -f "$item" ]]; then
        local dir="$(/usr/bin/dirname "$item")"
        local file="$(/usr/bin/basename "$item")"
        echo "$(cd "$dir" && /bin/pwd)/$file"
    else
        echo "$(/bin/pwd)/$item"
    fi
}

# Add description
_desc_add() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: desc add <file/dir> <description>"
        return 1
    fi
    
    _desc_init
    local path="$(_desc_fullpath "$1")"
    shift
    local description="$*"
    
    # Simple approach: remove old entry and add new one
    /usr/bin/grep -v "^$path|" "$DESC_FILE" > "$DESC_FILE.tmp" 2>/dev/null || /usr/bin/touch "$DESC_FILE.tmp"
    echo "$path|$description" >> "$DESC_FILE.tmp"
    /bin/mv "$DESC_FILE.tmp" "$DESC_FILE"
    
    echo "Description added for: $(/usr/bin/basename "$path")"
}

# Show specific description
_desc_show() {
    local path="$(_desc_fullpath "${1:-.}")"
    _desc_init
    
    local result="$(/usr/bin/grep "^$path|" "$DESC_FILE" 2>/dev/null | /usr/bin/head -1)"
    if [[ -n "$result" ]]; then
        echo "$(/usr/bin/basename "$path"): ${result#*|}"
    else
        echo "No description found for: $(/usr/bin/basename "$path")"
    fi
}

# Remove description
_desc_remove() {
    local path="$(_desc_fullpath "${1:-.}")"
    _desc_init
    
    if /usr/bin/grep -q "^$path|" "$DESC_FILE" 2>/dev/null; then
        /usr/bin/grep -v "^$path|" "$DESC_FILE" > "$DESC_FILE.tmp" 2>/dev/null
        /bin/mv "$DESC_FILE.tmp" "$DESC_FILE"
        echo "Description removed for: $(/usr/bin/basename "$path")"
    else
        echo "No description found for: $(/usr/bin/basename "$path")"
    fi
}

# List all descriptions
_desc_list() {
    _desc_init
    echo "All descriptions:"
    
    if [[ ! -s "$DESC_FILE" ]]; then
        echo "  No descriptions found."
        return
    fi
    
    # Show full path instead of just filename
    /usr/bin/awk -F'|' '{
        if (NF >= 2) {
            icon = "[F]"
            # Check if path is a directory (rough heuristic)
            if (system("test -d \"" $1 "\"") == 0) {
                icon = "[D]"
            }
            print "  " icon " " $1 ": " $2
        }
    }' "$DESC_FILE"
}

# Search descriptions
_desc_search() {
    local pattern="${1:-.*}"
    _desc_init
    
    echo "Searching for: $pattern"
    
    if [[ ! -f "$DESC_FILE" ]]; then
        echo "  No descriptions found."
        return
    fi
    
    local matches="$(/usr/bin/grep -i "$pattern" "$DESC_FILE" 2>/dev/null)"
    if [[ -n "$matches" ]]; then
        echo "$matches" | /usr/bin/awk -F'|' '{
            if (NF >= 2) {
                gsub(/^.*\//, "", $1)  # Get just filename  
                icon = "[F]"
                print "  " icon " " $1 ": " $2
            }
        }'
    else
        echo "  No matches found."
    fi
}

# Clean up descriptions for deleted files
_desc_clean() {
    _desc_init
    
    echo "Cleaning up descriptions for deleted files..."
    local cleaned=0
    local temp_clean="/tmp/desc_clean_$$"
    /usr/bin/touch "$temp_clean"
    
    # Simple approach using awk
    /usr/bin/awk -F'|' -v cleaned=0 '{
        if (NF >= 2) {
            # Test if file exists
            if (system("test -e \"" $1 "\"") == 0) {
                print $0
            } else {
                print "  Removing: " $1 > "/dev/stderr"
                cleaned++
            }
        }
    }' "$DESC_FILE" > "$temp_clean"
    
    /bin/mv "$temp_clean" "$DESC_FILE"
    echo "Cleanup complete."
}

# Help
_desc_help() {
    echo "File Descriptions Plugin"
    echo "======================="
    echo
    echo "Usage: desc <command> [args...]"
    echo
    echo "Commands:"
    echo "  add <file> <description>   - Add description to file/directory"
    echo "  show [file]                - Show description for specific item"
    echo "  remove [file]              - Remove description"
    echo "  rm [file]                  - Alias for remove"
    echo "  list                       - List all descriptions"
    echo "  search <pattern>           - Search descriptions"
    echo "  clean                      - Remove descriptions for deleted files"
    echo "  help                       - Show this help"
    echo
    echo "Other commands:"
    echo "  lls [options]              - Enhanced ls with descriptions"
    echo
    echo "Examples:"
    echo "  desc add config.json 'Main configuration file'"
    echo "  desc add ./docs 'Documentation folder'"
    echo "  desc show config.json"
    echo "  desc list"
    echo "  desc search config"
    echo "  lls"
}

# Main desc command with subcommands
desc() {
    case "$1" in
        add)
            shift
            _desc_add "$@"
            ;;
        show)
            shift
            _desc_show "$@"
            ;;
        remove|rm)
            shift
            _desc_remove "$@"
            ;;
        list)
            _desc_list
            ;;
        search)
            shift
            _desc_search "$@"
            ;;
        clean)
            _desc_clean
            ;;
        help|--help|-h)
            _desc_help
            ;;
        "")
            _desc_help
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run 'desc help' for usage information."
            return 1
            ;;
    esac
}

# Enhanced ls with descriptions - kept as separate command
lls() {
    _desc_init
    local current_dir="$(/bin/pwd)"
    
    # 1% chance to run automatic cleanup
    if (( RANDOM % 100 == 0 )); then
        _desc_clean >/dev/null 2>&1
    fi
    
    # Capture the colored ls output to a temp file first
    local ls_temp="/tmp/ls_output_$"
    /bin/ls -la --color=always "$@" > "$ls_temp"
    
    # Get descriptions for current directory
    local desc_temp="/tmp/desc_lookup_$"
    /usr/bin/touch "$desc_temp"
    
    # Build lookup file: filename|description
    if [[ -s "$DESC_FILE" ]]; then
        /usr/bin/grep "^$current_dir/" "$DESC_FILE" 2>/dev/null | /usr/bin/awk -F'|' '{
            gsub(/^.*\//, "", $1)  # Remove path, keep just filename
            print $1 "|" $2
        }' > "$desc_temp"
    fi
    
    # Color codes for descriptions
    local desc_color="\033[2;37m"    # Dim gray
    local icon_color="\033[0;36m"    # Cyan
    local reset="\033[0m"
    
    # Now process the ls output and add descriptions
    while IFS= read -r line; do
        # Handle special lines (total, etc.)
        if [[ "$line" == total* ]] || [[ "$line" == "" ]]; then
            echo "$line"
            continue
        fi
        
        # Extract filename (strip ANSI codes for matching)
        local filename_clean="${line##* }"
        # Remove ANSI color codes to get clean filename
        filename_clean=$(echo "$filename_clean" | sed 's/\x1b\[[0-9;]*m//g')
        
        # Skip . and .. entries  
        if [[ "$filename_clean" == "." ]] || [[ "$filename_clean" == ".." ]]; then
            echo "$line"
            continue
        fi
        
        # Look up description for this file
        local desc=""
        if [[ -s "$desc_temp" ]]; then
            desc="$(/usr/bin/grep "^$filename_clean|" "$desc_temp" 2>/dev/null | /usr/bin/cut -d'|' -f2-)"
        fi
        
        # Output line with or without description
        if [[ -n "$desc" ]]; then
            local icon="[F]"
            [[ -d "$filename_clean" ]] && icon="[D]"
            printf "%-75s ${icon_color}%s${reset} ${desc_color}%s${reset}\n" "$line" "$icon" "$desc"
        else
            echo "$line"
        fi
    done < "$ls_temp"
    
    # Clean up temp files
    /bin/rm -f "$ls_temp" "$desc_temp"
}

# Add completion support
if command -v compdef >/dev/null 2>&1; then
    _desc_completion() {
        local -a subcommands
        subcommands=(
            'add:Add description to file/directory'
            'show:Show description for specific item'
            'remove:Remove description'
            'rm:Remove description (alias)'
            'list:List all descriptions'
            'search:Search descriptions'
            'clean:Remove descriptions for deleted files'
            'help:Show help'
        )
        
        if (( CURRENT == 2 )); then
            _describe 'commands' subcommands
        elif (( CURRENT >= 3 )); then
            case "$words[2]" in
                add|show|remove|rm)
                    _files
                    ;;
            esac
        fi
    }
    
    compdef _desc_completion desc
    compdef _files lls
fi

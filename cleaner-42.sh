#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    cleaner-42.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dherszen <dherszen@student.42.rio>         +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/11/19 16:42:58 by dherszen          #+#    #+#              #
#    Updated: 2025/11/19 16:42:58 by dherszen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Cache Cleaner Script ===${NC}"
echo "Starting cleanup process..."
echo ""

# Check for running programs
running_programs=()
if pgrep -x "code" > /dev/null; then
    running_programs+=("VSCode")
fi
if pgrep -x "slack" > /dev/null; then
    running_programs+=("Slack")
fi
if pgrep -x "discord" > /dev/null || pgrep -x "Discord" > /dev/null; then
    running_programs+=("Discord")
fi
if pgrep -x "chrome" > /dev/null || pgrep -x "google-chrome" > /dev/null; then
    running_programs+=("Chrome")
fi
if pgrep -x "firefox" > /dev/null || pgrep -x "firefox-bin" > /dev/null; then
    running_programs+=("Firefox")
fi

# Warn if programs are running
if [ ${#running_programs[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Warning: The following programs are currently running:${NC}"
    for program in "${running_programs[@]}"; do
        echo -e "  - $program"
    done
    echo ""
    echo -e "${YELLOW}It's recommended to close them before cleaning.${NC}"
    echo -e "Cache deletion may be less effective while programs are running."
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cleanup cancelled.${NC}"
        exit 0
    fi
    echo ""
fi

# Calculate initial disk usage
initial_size=$(du -s "$HOME" 2>/dev/null | awk '{print $1}')

# Counter for cleaned items
cleaned_count=0

# Function to safely remove directory contents (keeping the directory itself)
clean_directory() {
    local dir="$1"
    local description="$2"

    if [ -d "$dir" ]; then
        local size_before=$(du -s "$dir" 2>/dev/null | awk '{print $1}')
        if [ -n "$size_before" ] && [ "$size_before" -gt 0 ]; then
            echo -e "${YELLOW}Cleaning: ${description}${NC}"
            find "$dir" -mindepth 1 -delete 2>/dev/null
            cleaned_count=$((cleaned_count + 1))
            local size_after=$(du -s "$dir" 2>/dev/null | awk '{print $1}')
            local freed=$((size_before - size_after))
            if [ "$freed" -gt 0 ]; then
                echo -e "${GREEN}  ✓ Freed: $(numfmt --to=iec-i --suffix=B "$((freed * 1024))" 2>/dev/null || echo "${freed}KB")${NC}"
            fi
        fi
    fi
}

# Function to remove specific files by pattern
clean_files_by_pattern() {
    local pattern="$1"
    local description="$2"

    echo -e "${YELLOW}Cleaning: ${description}${NC}"
    local count=$(find "$HOME" -type f -name "$pattern" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        find "$HOME" -type f -name "$pattern" -delete 2>/dev/null
        echo -e "${GREEN}  ✓ Removed $count file(s)${NC}"
        cleaned_count=$((cleaned_count + 1))
    else
        echo -e "  No files found"
    fi
}

echo "=== System Cache ==="
clean_directory "$HOME/.cache" "User cache directory"
echo ""

echo "=== VSCode ==="
clean_directory "$HOME/.config/Code/Cache" "VSCode Cache"
clean_directory "$HOME/.config/Code/CachedData" "VSCode Cached Data"
clean_directory "$HOME/.config/Code/CachedExtensions" "VSCode Cached Extensions"
clean_directory "$HOME/.config/Code/CachedExtensionVSIXs" "VSCode Cached Extension VSIXs"
clean_directory "$HOME/.config/Code/logs" "VSCode Logs"
clean_directory "$HOME/.vscode/extensions/.obsolete" "VSCode Obsolete Extensions"
echo ""

echo "=== Slack ==="
clean_directory "$HOME/.config/Slack/Cache" "Slack Cache"
clean_directory "$HOME/.config/Slack/Code Cache" "Slack Code Cache"
clean_directory "$HOME/.config/Slack/Service Worker/CacheStorage" "Slack Service Worker Cache"
clean_directory "$HOME/.config/Slack/logs" "Slack Logs"
echo ""

echo "=== Discord ==="
clean_directory "$HOME/.config/discord/Cache" "Discord Cache"
clean_directory "$HOME/.config/discord/Code Cache" "Discord Code Cache"
clean_directory "$HOME/.config/discord/GPUCache" "Discord GPU Cache"
clean_directory "$HOME/.config/discord/logs" "Discord Logs"
echo ""

echo "=== Google Chrome ==="
clean_directory "$HOME/.config/google-chrome/Default/Cache" "Chrome Cache"
clean_directory "$HOME/.config/google-chrome/Default/Code Cache" "Chrome Code Cache"
clean_directory "$HOME/.config/google-chrome/Default/GPUCache" "Chrome GPU Cache"
clean_directory "$HOME/.config/google-chrome/Default/Service Worker/CacheStorage" "Chrome Service Worker Cache"
clean_directory "$HOME/.config/google-chrome/ShaderCache" "Chrome Shader Cache"
echo ""

echo "=== Firefox ==="
# Find Firefox profile(s)
firefox_dir="$HOME/.mozilla/firefox"
if [ -d "$firefox_dir" ]; then
    # Clean each profile's cache (matches pattern: xxxxxxxx.username)
    for profile in "$firefox_dir"/*.*; do
        if [ -d "$profile" ] && [[ "$(basename "$profile")" =~ ^[a-z0-9]+\.[a-z0-9_-]+$ ]]; then
            profile_name=$(basename "$profile")
            
            # Clean traditional cache directories
            clean_directory "$profile/cache2" "Firefox cache2 ($profile_name)"
            clean_directory "$profile/startupCache" "Firefox startup cache ($profile_name)"
            clean_directory "$profile/thumbnails" "Firefox thumbnails ($profile_name)"
            
            # Clean storage cache (website-specific caches)
            if [ -d "$profile/storage/default" ]; then
                for site_cache in "$profile/storage/default"*/cache; do
                    if [ -d "$site_cache" ]; then
                        site_name=$(basename $(dirname "$site_cache"))
                        clean_directory "$site_cache" "Firefox storage cache: ${site_name:0:40}..."
                    fi
                done
            fi
        fi
    done
fi
echo ""

echo "=== Temporary Files ==="
clean_files_by_pattern ".DS_Store" "macOS .DS_Store files"
clean_files_by_pattern "*.swp" "Vim swap files"
clean_files_by_pattern "*~" "Backup files"
clean_files_by_pattern ".*.swp" "Hidden swap files"
echo ""

# Docker info
if command -v docker &> /dev/null; then
    echo "=== Docker ==="
    echo -e "${YELLOW}Note: Docker files are typically located in /goinfre/ (local machine storage).${NC}"
    echo -e "${YELLOW}This directory is NOT part of your HOME quota.${NC}"
    echo -e "If you need to clean Docker, run manually: ${GREEN}docker system prune -a${NC}"
    echo ""
fi

# Calculate final disk usage and freed space
final_size=$(du -s "$HOME" 2>/dev/null | awk '{print $1}')
freed_space=$((initial_size - final_size))

echo "=== Summary ==="
echo -e "${GREEN}✓ Cleanup completed!${NC}"
echo "Items cleaned: $cleaned_count"

if [ "$freed_space" -gt 0 ]; then
    echo -e "Total space freed: ${GREEN}$(numfmt --to=iec-i --suffix=B "$((freed_space * 1024))" 2>/dev/null || echo "${freed_space}KB")${NC}"
elif [ "$freed_space" -eq 0 ]; then
    echo "No space was freed (cache directories were already clean)"
else
    echo "Note: Disk usage calculation may be affected by other processes"
fi

echo ""
echo -e "${GREEN}Done!${NC}"

# Cleaner 42 (New) 🧹

A cache cleaning script for **Ecole 42 students** to manage the 5GB HOME quota on native Linux installations.

This is an updated version of the [original cleaner-linux-42](https://github.com/hersdani/cleaner-linux-42) script, adapted for systems where programs are installed **natively** (not via Flatpak).

## 🎯 Purpose

At Ecole 42, student accounts have a strict 5GB quota. Applications like VSCode, Slack, Discord, Chrome, and Firefox can accumulate several gigabytes of cache files over time. This script safely removes these cache files without breaking any functionality.

## 📋 What Gets Cleaned

### System
- `~/.cache` - User cache directory

### VSCode
- Cache, cached data, cached extensions
- Logs and obsolete extensions

### Slack
- Cache, code cache, service worker cache
- Logs

### Discord
- Cache, code cache, GPU cache
- Logs

### Google Chrome
- Cache, code cache, GPU cache
- Service worker cache, shader cache

### Firefox
- Cache, startup cache, thumbnails
- (Auto-detects all Firefox profiles)

### Temporary Files
- `.DS_Store` files
- Vim swap files (`*.swp`, `.*.swp`)
- Backup files (`*~`)

## ✅ Safety

This script is **safe to run** and will not break any programs. Here's why:

**What it removes:**
- Cache files (regenerated automatically)
- Logs (historical data only)
- Temporary files (by definition, temporary)
- Obsolete extensions (already marked as obsolete)

**What it preserves:**
- Settings and configurations
- User data (messages, history, bookmarks, passwords)
- Installed extensions
- Workspaces and projects
- Session data and login tokens

**Worst case:** Applications might be slightly slower on first launch after cleaning as they rebuild cache.

## 🚀 Usage

1. Run the script:
   ```bash
   ~/Documents/scripts/cleaner-linux-new-42/cleaner-42.sh
   ```

2. If any programs (VSCode, Slack, Discord, Chrome, Firefox) are running, the script will:
   - **Warn you** which programs are running
   - **Ask for confirmation** to continue
   - Allow you to cancel and close them first

3. The script will show you what's being cleaned and how much space is freed.

**Tip:** For best results, close applications before running the script.

## 💾 Docker Note

Docker files are typically stored in `/goinfre/` (local machine storage), which is **NOT part of your HOME quota**. If you need to clean Docker, run manually:
```bash
docker system prune -a
```

## 📝 Differences from Original Script

The [original cleaner-linux-42](https://github.com/hersdani/cleaner-linux-42) was designed for Flatpak installations where program data was stored in `~/.var/app/`. This new version targets **native installations** where programs store data in standard locations like `~/.config/`, `~/.cache/`, and `~/.vscode/`.

## 🔧 Installation

```bash
# Clone the repository
cd ~/Documents/scripts
git clone https://github.com/hersdani/cleaner-linux-new-42.git cleaner-linux-new-42

# Make the script executable
chmod +x ~/Documents/scripts/cleaner-linux-new-42/cleaner-42.sh

# Run it
~/Documents/scripts/cleaner-linux-new-42/cleaner-42.sh
```

## 📊 Example Output

```
=== Cache Cleaner Script ===
Starting cleanup process...

=== System Cache ===
Cleaning: User cache directory
  ✓ Freed: 1.2GiB

=== VSCode ===
Cleaning: VSCode Cache
  ✓ Freed: 456MiB
...

=== Summary ===
✓ Cleanup completed!
Items cleaned: 15
Total space freed: 2.8GiB

Done!
```

## ⚠️ Recommendations

- Run this script regularly (weekly or when quota is running low)
- Close applications before running for best results
- Check your quota with: `du -sh ~`

## 📜 License

MIT License - feel free to use and modify this script for your needs.

---

Made for 42 students 🚀

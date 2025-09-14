# File Descriptions

Add descriptions to files and directories. See them in your `ls` output.

## What it does

Add short descriptions to files and folders. When you run `lls`, see the descriptions next to each file.

Before:
```
-rw-r--r-- 1 user user 1234 Sep 13 10:30 script.sh
-rw-r--r-- 1 user user  567 Sep 13 10:30 config.json
drwxr-xr-x 3 user user 4096 Sep 13 10:30 project/
```

After:
```
-rw-r--r-- 1 user user 1234 Sep 13 10:30 script.sh                         [F] Backup script
-rw-r--r-- 1 user user  567 Sep 13 10:30 config.json                      [F] DB settings
drwxr-xr-x 3 user user 4096 Sep 13 10:30 project/                         [D] Client work
```

## Commands

```bash
desc add <file> <description>     # Add description
desc show [file]                  # Show description
desc remove [file]                # Remove description
desc list                         # Show all descriptions
desc search <pattern>             # Search descriptions
desc clean                        # Remove descriptions for deleted files

lls                               # Enhanced ls with descriptions
```

## Installation

### Oh My Zsh
```bash
git clone https://github.com/yourusername/file-descriptions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/file-descriptions
```

Add `file-descriptions` to your plugins list in `~/.zshrc`:
```bash
plugins=(git file-descriptions)
```

### Manual
```bash
git clone https://github.com/yourusername/file-descriptions.git
echo 'source /path/to/file-descriptions/file-descriptions.plugin.zsh' >> ~/.zshrc
```

Restart your shell.

## Examples

```bash
desc add config.json "Database connection settings"
desc add ./docs "Project documentation"  
desc add script.sh "Nightly backup script"

lls                    # See files with descriptions
desc list              # Show all descriptions
desc search "backup"   # Find backup-related files
```

## Notes

- Descriptions stored in `~/.file_descriptions`
- Auto-cleanup removes descriptions for deleted files
- Use `lls` instead of `ls -la` to see descriptions
- Tab completion works for file names

# File Descriptions

A Zsh plugin that lets you add descriptions to files and directories, then view them with an enhanced `ls` command.

## Quick Start

```zsh
# Add descriptions
desc config.json "Main configuration file"
desc ./docs "Documentation folder"

# List files with descriptions
lls

# View specific description
showdesc config.json
```

## Commands

- `desc <file> <description>` - Add description
- `lls` - Enhanced ls showing descriptions
- `showdesc [file]` - Show description for file
- `rmdesc [file]` - Remove description
- `listdesc` - Show all descriptions
- `finddesc <pattern>` - Search descriptions
- `cleandesc` - Remove descriptions for deleted files

## Installation
TODO
1. Save as `file-descriptions.plugin.zsh`
2. Source in your `.zshrc` or add to your plugin manager
3. Restart your shell

Descriptions are stored in `~/.file_descriptions`.

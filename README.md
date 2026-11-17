# Git config

My configuration of Git.

## Requirements

- [Git](https://git-scm.com/)
- [mise](https://mise.jdx.dev/)

## Usage

### Create subcommands

Create symlinks for all scripts in `subcommands/` to a directory in your PATH (default: `~/.local/bin`) and set executable permissions.

Use mise tasks:

```bash
mise run sub-create          # Link to ~/.local/bin (default)
mise run sub-create ~/bin # Link to ~/bin
```

### Create aliases

Create symlinks for `alias.conf` to a config directory (default: `~/.config/git/config.d/alias.conf`) and include it in `~/.gitconfig`.

Use mise tasks:

```bash
mise run alias-create                 # Link to ~/.config/git/config.d/alias.conf (default)
mise run alias-create ~/alias.conf # Link to ~/alias.conf
```

## Example usage

### Create subcommand `git hello` and alias `git h`

1. Create a script `subcommands/hello.sh`

2. Format and Check subcommands as shell script

    ```bash
    mise run sub-check
    ```

3. Create subcommand

    ```bash
    mise run sub-create
    ```

4. Check subcommand

    ```bash
    mise run sub-ls
    ```

5. Check the command

    ```bash
    git hello
    ```

6. Add alias to `alias.conf`

    ```conf
    [alias]
    h = hello
    ```

7. Format and Check alias source

    ```bash
    mise run alias-check
    ```

8. Create alias

    ```bash
    mise run alias-create
    ```

9. Check alias

    ```bash
    mise run alias-ls
    ```

10. Check the alias

    ```bash
    git h
    ```

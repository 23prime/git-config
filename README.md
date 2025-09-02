# Git config

My configuration of Git.

## Requirements

- [Git](https://git-scm.com/)
- [Taskfile](https://taskfile.dev/)
- [mise](https://mise.jdx.dev/)

## Usage

### Create subcommands

Create symlinks for all scripts in `subcommands/` to a directory in your PATH (default: `~/.local/bin`) and set executable permissions.

Use Taskfile:

```bash
task sub:create          # Link to ~/.local/bin (default)
task sub:create -- ~/bin # Link to ~/bin
```

### Create aliases

Create symlinks for `alias.conf` to a config directory (default: `~/.config/git/config.d/alias.conf`) and include it in `~/.gitconfig`.

Use Taskfile:

```bash
task alias:create                 # Link to ~/.config/git/config.d/alias.conf (default)
task alias:create -- ~/alias.conf # Link to ~/alias.conf
```

## Example usage

### Create subcommand `git hello` and alias `git h`

1. Create a script `subcommands/hello.sh`

2. Format and Check subcommands as shell script

    ```bash
    task sub:check
    ```

3. Create subcommand

    ```bash
    task sub:create
    ```

4. Check subcommand

    ```bash
    task sub:ls
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
    task alias:check
    ```

8. Create alias

    ```bash
    task alias:create
    ```

9. Check alias

    ```bash
    task alias:ls
    ```

10. Check the alias

    ```bash
    git h
    ```

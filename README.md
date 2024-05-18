# p4plugin

P4 plugin for godot, but without using the p4 api :D.

### How it works

The plugin listens to the signal `apply_changes` [docs](https://docs.godotengine.org/en/2.1/classes/class_editorplugin.html#class-editorplugin-apply-changes) and will run the `reconcile.bat` script on signal emit.

### How to use

- In your godot project root create the file `.p4config` and add this content:
    ```ini
    P4PORT=ssl:167.235.136.144:1666
    P4CLIENT=%your-p4-workspace-name%
    P4IGNORE=%path-to-your-p4ignore-file%
    ```

- Then run this command in your terminal
    ```
    p4 set P4CONFIG=%path-to-your-p4config-file%
    ```

- Add to your project root a file named `reconcile.bat` with this content:
    ```
    @echo off

    pushd %~dp0
    p4 reconcile -m
    popd
    ```

### TODO
- [ ] add config options in viewport
- [ ] setup script path in viewport
- [ ] autodetect platform (linux / windows)

### Tips

For using perforce with godot, I found that it's best to enable this settings for your workspace:
- Allwrite
- Clobber
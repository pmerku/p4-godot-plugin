# p4plugin

P4 plugin for godot, but without using the p4 api :D.

### How it works

The plugin listens to the signal `apply_changes` [docs](https://docs.godotengine.org/en/2.1/classes/class_editorplugin.html#class-editorplugin-apply-changes) and will execute `p4 reconcile` on signal emit.

### How to use

- Install the plugin in your project
- Configure paths and envs using the plugin viewport

### TODO
- ci
- release packages

### Tips

For using perforce with godot, I found that it's best to enable this settings for your workspace:
- Allwrite
- Clobber
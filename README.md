### Home for all the build and infrastructure related tools and frameworks

__What we currently have__:

- A platform agnostic build helper in `C++`
- A dotfile with useful aliases

#### To enable the use of the useful aliases:
Find the config file for your particular shell (e.g. `~/.bashrc`, `~/.zshrc`, `~/.profile`) and add the following line to that file (note that the directory should point to where you stored this repo, it may not be in your home directory)
```
source ~/paramedics-builder/.docker-helper
```
Once you open a new terminal window/tab, you'll have access to the aliases in [.docker_helper](.docker_helper).

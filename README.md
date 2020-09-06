### Home for all the build and infrastructure related tools and frameworks

__What we currently have__:

- A platform agnostic build helper in `C++`
- A dotfile with useful aliases

#### To enable the use of the useful aliases:
Find the config file for your particular shell (e.g. `~/.bashrc`, `~/.zshrc`, `~/.profile`) and add the following line to that file (note that the directory should point to where you stored this repo, it may not be in your home directory)
```
source ~/paramedics-builder/.docker_helper
```
Once you open a new terminal window/tab, you'll have access to the aliases in [.docker_helper](.docker_helper).

**NOTE:** you must have the `builder` binary available - if you dont' have it already, `cd` into [`/builder`](/builder) and run `make optimal`; you should see the `builder` file in your `paramedics-shared` directory (i.e. 2 directories up)

#### Where should I run these aliases?
For container-specific aliases (i.e. `pmc-*`), run them from their corresponding repos.

e.g. to restart your frontend container:
```
$ cd paramedics-react
$ pmc-r
```

For commands that run for both containers at once (i.e. `pma-*`), run them from a directory above `paramedics-web` and `paramedics-react` (see recommended directory layout below)
```
paramedics-shared/ (run commands from here)
|-- paramedics-builder/
|    |-- scripts/
|    |-- .docker_helper
|    |-- ...
|-- paramedics-react/
|    |-- ...
|-- paramedics-web/
|    |-- ...
|-- builder
```

#### How do I update these aliases to get the most recent changes?
```
$ cd paramedics-builder
$ git pull
$ source .docker-helper # or open a new terminal (window, tab, etc.)
```

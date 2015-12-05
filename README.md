# monki

![monki-small](https://cloud.githubusercontent.com/assets/13237912/10610877/89f806f2-76fe-11e5-8927-9c34f10411a7.png)


Monki is essentially cp for git.  It creates a copy of a git repo within a subfolder of your existing repo.  It doesn't import any of the project's history -- think of it like copying the project files straight into the subfolder.  The advantage of monki is that the subfolder can be updated very easily, whereas other alternatives (like git submodules / subtrees / etc) usually require some sort of management.

## Installation

git clone https://github.com/laarc/monki then symlink monki/bin/monki into your PATH.  E.g. 

```
git clone https://github.com/laarc/monki
cd monki/bin
ln -s "$(pwd)/monki" ~/bin/
```

## Usage

The "sudoarc" subfolder is an example of Monki's usage.  It was created by running `monki clone laarc/lumen-sudoarc sudoarc` from the project directory.

The "lumen" folder within sudoarc is a more interesting example:  https://github.com/laarc/monki/blob/master/sudoarc/lumen/monki.l

It tells Monki to clone [Lumen](https://github.com/sctb/lumen) and then make a variety of changes to it.  (That's partly where the name came from: I needed a way to monkeypatch Lumen, but didn't want to fork it.)


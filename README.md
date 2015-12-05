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

Anywhere within your project's git repo, run `monki clone user/project dstdir` to copy the project files from https://github.com/user/project into `./dstdir`.  Then run `git add dstdir; git commit`.

Later on, the project may add some new features or fix some bugs.  To pull in those changes, run `monki dstdir/`

Don't make direct changes to the files under dstdir.  They'll be overwritten by `monki dstdir/`.  Instead, if you wish to make edits to the project, open `dstdir/monki.l` (which monki creates during the initial clone) and describe the changes you wish to make.  (See below.)

## In-depth example

The "sudoarc" subfolder is an example of Monki's usage.  It was created by running `monki clone laarc/lumen-sudoarc sudoarc` from the project directory, which clones [laarc/lumen-sudoarc](https://github.com/laarc/lumen-sudoarc).

If you visit [laarc/lumen-sudoarc](https://github.com/laarc/lumen-sudoarc), you'll notice the "lumen" subfolder is also manged by Monki.  It's very easy to re-use code across all of your repos, since it's just a matter of running `monki clone yourname/yourproject dir`.

The lumen subfolder was originally created by running:

```
$ git clone https://github.com/laarc/lumen-sudoarc sudoarc
$ cd sudoarc
$ monki clone sctb/lumen lumen
$ git add lumen
$ git commit
$ git push
```

This created `lumen/monki.l` within `lumen/` along with all of Lumen's files.  A `monki.l` file tells Monki what to do to the subfolder it resides in.  

If you just want a copy of someone's repo, then you won't need to edit any `monki.l` files.  `monki clone foo/bar dst` automatically generates a `dst/monki.l` file for you.

If you want to make any changes to someone else's repo, examine sudoarc's [lumen/monki.l](https://github.com/laarc/monki/blob/master/sudoarc/lumen/monki.l) file to see an example.  It instructs monki to clone [Lumen](https://github.com/sctb/lumen), modify it with various hacks (like multiline raw string syntax), fully rebuild it three times, then `make test`.

(That's basically why the project was originally created.  I needed a way to monkeypatch Lumen, and I didn't want to fork it and deal with keeping it in sync.)




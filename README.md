# monki

![monki-small](https://cloud.githubusercontent.com/assets/13237912/10610877/89f806f2-76fe-11e5-8927-9c34f10411a7.png)




## choosing a home for your monki

To get started, git clone https://github.com/laarc/monki then symlink monki/bin/monki into your PATH.  For example, 

```
git clone https://github.com/laarc/monki
cd monki/bin
ln -s "$(pwd)/monki" ~/bin/
```

## care and feeding of your monki

Your new `monki` is quite versatile, but usually you won't need most of what it can do.  In our day-to-day coding lives, two scenarios turn out to be exceedingly common:

1.  "I have some common code, like a library, and I want my other git repositories to use it.  And when I make changes to the common code, everything that uses it should automatically get the new changes.  (Except the things that shouldn't.)"

2. "I want to use a third-party library, but [it has a bug] [it doesn't quite work how I'd like] [I want to extend it] [...]."

The traditional approach for #1 is to use git submodules, git subtrees, git stree, etc.  (And of course, if those solutions are a good fit for a project, then use 'em!  There's no Right Way in coding.)

For #2, typically you'd fork their repo, make some changes, submit a pull request, then switch your project over to use your fork instead.  Sometimes people document the differences, but this seems rare.

`monki` tries to handle both scenarios in a simple way.

Let's dive right into a real-world instance of #1:  https://github.com/tlbtlbtlb/startuptools

README:  "This requires an installation of tlbcore (https://github.com/tlbtlbtlb/tlbcore) symlinked to this directory."

At that point, it's up to each cloner to figure out how to set up the repo, which in this case is trivially easy.  But that starts to become less true the more dependencies of this nature that your project relies on.  (I.e. "Here's a bunch of code I want to use; the code originates from outside this git repo; please don't make me worry about it / manage it, since I just want to use it;  and please pull in any new changes automatically".)

Let's try to discover a way to balance all of these concerns.  Our first thought might be that we'd ideally like to be able to commit that tlbcore/ symlink into startuptools/.  After all, the symlink represents a *dependency*; "startuptools depends on tlbcore".  But "symlink" means "this has already been set up, and it's ready to use; we're just making an alias for it."  Yet in reality, when someone clones your repo, they likely have nothing set up.  They likely just heard about your project over on HN, and they're checking whether it might be useful to them.

Wouldn't it be wonderful if all they had to do was `git clone` your repo, and nothing else?

Other systems have been built on top of git to accomplish that, of course. And some of them are pretty excellent.  So why create Monki-aka-"Yet Another Solution To Subtrees"

Because much of the time you don't want to merely use someone else's code; you want to *modify* it. But you don't really want to go through the hassle of managing their code as some sort of "separate entity", like forking it or making it a submodule, since there are a bunch of tradeoffs. It will have its own set of branches, for one, and won't track your main repo's branches.  I.e. if you switch from master to dev, you'll also need to switch each submodule.  In fact, it has a bunch of context that you'd really prefer not to link with your own repo, such as thousands of commit logs, pull requests, branches, etc.  We'd ideally like to do without this extraneous metadata.

Another ideal: Whenever someone clones your repo, it should be "ready to go."  Meaning if they clone your repo and switch to your dev branch, then that clone should be a correct snapshot of "the current state of your *entire* repository, and its dependencies"  according to that branch.  To wit, they shouldn't be forced to worry about setting each submodule to the same branch.

What are we describing, here?  It turns out that we're almost describing `cp -r`.  We just want the files, and don't care too much about how we get them.  We just want to be able to (a) change them easily, and (b) pull in new updates.

## sure

In that light, Monki is "cp for git."  It's also "structured monkeypatching." It's the ability to clone some external *person/foo* repository into the *foo* subfolder of your own repository, effortlessly.

## show me

Here's how monki could be applied to the earlier example of https://github.com/tlbtlbtlb/startuptools

By the end of it, there will be no need to symlink to tlbcore; monki ensures that tlbcore/ is a mirror of tlbtlbtlb/tlbcore.  Yet if tlbcore changes, monki will pull in any new updates, like a symlink would've.

```sh
git clone https://github.com/tlbtlbtlb/startuptools
cd startuptools
monki clone tlbtlbtlb/tlbcore tblcore
cat .gitignore | grep -v tlbcore | sponge > .gitignore # Remove tlbcore entry from .gitignore
git add .
git commit -m "Cloned github.com/tlbtlbtlb/tlbcore into tlbcore/"
git push
```

What did we do, exactly?  Well, conceptually, just think of it as identical to `cd startuptools ; git clone https://github.com/tlbtlbtlb/tlbcore ../tlbcore ; cp -r ../tblcore .`

In reality, here's what `monki clone tlbtlbtlb/tlbcore tblcore` actually did:

```
mkdir -p tlbcore/.monki/git

# ignore everything within .monki
echo '*' > tlbcore/.monki/.gitignore 

# create a Monki script that says "Our subfolder will be a clone of this other repo."
echo '(clone "tlbtlbtlb/tlbcore" "tlbcore")' > tlbcore/monki.l 

# search under tlbcore/ for all "monki.l" files and run each of them as a Monki script:
monki tlbcore/

# At this point, monki sees the new tlbcore/monki.l file we created, and begins running it.
# Every monki.l file is just a program.  No magic; just a script, written in Lumen.
# Think of a monki.l file as "a Bash script, but with nice syntax."
#
# The monki.l script contains only one expression: (clone "tlbtlbtlb/tlbcore" "tlbcore").
# Conceptually, it means "ensure the contents of tlbcore/ always mirror the contents of
#  github.com/tlbtlbtlb/tlbcore."
#
# Hmm... Mirror a repository?  Isn't that just `git clone tlbtlbtlb/tlbcore`?  Well, if we did that,
# then we'd end up with a .git folder at tlbcore/.git, which would cause startuptools/tlbcore/ 
# to become a git submodule.  We want to avoid that; we want tlbcore/ to just be a set of files
# that automatically pull updates from the repo they came from.  What's the simplest way to
# avoid cloning tlbcore as a submodule?
#
# It turns out that we can put the .git folder elsewhere.  The solution is to put it inside of a subdir
# which is being ignored by .gitignore.  That way, tlbcore/ appears to us and to everyone else
# to be "just a bunch of files".  Yet tlbcore's git history  remains available to us, since we know
# where we stashed the .git folder.  This is the decisive advantage, and the whole reason for
# all of this:  We now have the ability to pull in new changes from tlbtlbtlb/tlbcore into our tblcore/
# subdir, yet the subdir just looks like "a bunch of files," not a git submodule or subtree or anything
# that has to be managed.  We also have the ability to revert unwanted changes to tlbcore.  In fact,
# every time monki runs, it will revert *all* changes in tlbcore/ -- then it will re-run monki.l, which
# pulls in new updates.  The upshot is that if we want to change tlbcore/ somehow, then we can,
# very easily; monki.l is the ideal place to write such monkeypatches;  and monki scripts are
# essentially "a language designed to make monkeypatching really, really easy, without sacrificing
# the ability to pull in updates."
#
# To see examples of how this "structured monkeypatching" nonsense works out in practice, check
# out https://github.com/laarc/monki/blob/master/lumen/monki.l.  Monki is powered by Lumen, yet
# Monki's own repo uses Monki.  In fact, it extends Lumen in various ways, by e.g. adding support
# for """python-style raw multiline string syntax""", which makes it significantly easier to paste code
# without worrying about whether it's escaped correctly.
#
# To see how to create a repository that uses monki to clone a bunch of other repositories into
# subfolders, check out the monki.l files inside "lumen", "motor", and "sudoarc" subfolders of
# https://github.com/laarc/arc-tiefighter
#
# (Random tangent:  arc-tiefighter the webserver for http://arc.lol, pronounced "arc dot tiefighter"
# for obvious reasons.  It's a Lumen-powered in-browser Arc repl we've been building.  Check it out,
# if you want!)

# Whew.  Anyway, now (clone "tlbtlbtlb/tlbcore" "tlbcore") is evaluated, which does the following:
git clone -n https://github.com/tlbtlbtlb/tlbcore .monki/git
git --git-dir=.monki/git/.git reset -- . 
git --git-dir=.monki/git/.git checkout -- . 
git --git-dir=.monki/git/.git checkout master
git --git-dir=.monki/git/.git pull 
```

A few closing points:

- Running `monki` will search for any monki.l files underneath your current dir, and will run each of them.  Since monki.l files usually start with a (clone ....) statement, that means the last five git commands typically run every time you run `monki`, for every subdir that contains a monki.l file.

(E.g. I usually run `cd ~/dev ; monki` since ~/dev is where I keep most of my projects.)

- Note the `git pull` command.   By default, all monki subfolders will pull
in any new changes. This is what we want most of the time, but there are certainly times you wouldn't want that.  Or perhaps you'd like to auto-update to a different branch other than `master`.

Whichever you want, monki makes it easy: pop open the monki.l file and change

(clone "person/foo" "foo")

to

(clone "person/foo" "foo" "some-branch-name")

or

(clone "person/foo" "foo" "some-commit-hash")

That will cause your subfolder to mirror the HEAD of branch "some-branch-name" / to mirror "some-commit-hash", respectively.  Specifying a commit hash causes the subdir to never deviate from that hash, meaning it won't sync to any new code under any circumstances, till you remove or change the hash in the clone expression.

- To switch your subfolder back to master, just change the clone statement back to (clone "person/foo" "foo") and run `monki`.  Your subdir will automatically mirror itself to the latest HEAD of the master branch.

- Cloning to a specific tag (as opposed to branch/hash) isn't yet supported, though only because I haven't gotten around to it yet.

- You're not limited to github URLs in a (clone url ...) statement.  All types of URLs should work fine; even local path URLs like (clone "../tlbcore/.git" "tlbcore").

- Right now, monki makes no attempt whatsoever to detect or react to errors.  Instead, monki spews most of the commands it runs to stdout, as it runs them (run `VERBOSE=1 monki` to see every command) in hopes that you'll spot any errors.  It's unfortunate that monki isn't following the unix philosophy of "produce no output if successful."  Sorry about that.  I plan to fix this, but my time's been stretched.

- Pull requests most welcome.  If "digging into the guts of software written in experimental lisp dialects" sounds interesting, feel free to try your hand at e.g. "abort on error", or anything else.

Title: Some notes on Git
Date: 2024-05-09
Status: published
Tags: git

The following is a summary of thoughts and ideas presented in the [devtools.fm
podcast](https://www.devtools.fm) episode: [Scott Chacon
- GitHub, GitButler and changing the face of version control
  ](https://www.devtools.fm/episode/97)

I strongly encourage you to listen to the complete episode as there's a wealth
of great ideas. It actually makes me excited about the future of version
control and possible tool improvements we could see in the future.

## 🔎 Grouping changes

When I make a change it would be great to be able to logically group together
a set of related changes and display them alongside each other.

I.e. if I make a change to a function, and then a change a corresponding test,
It would be better to see them grouped in the PR.

However, if you bundle these changes alongside other changes, clients will
often show all the changes in the PR sorted alphabetically, which can make
reviewing the PR harder.

Even if we strive to make small atomic commits, it's not always possible to
separate changes into easily reviewable PRs. I think there's a lot that clients
could do to make the job of a reviewer easier.

Most clients will force a review to be conducted holistically displaying the
entire diff with the target branch. Sometimes it would be more useful to be
able to review a chain of commits individually along the entire journey of
a change.

## 💢 Merge conflicts

If two developers are working on the same piece of code, whoever merges first
essentially wins, i.e. they don't have the extra work required to resolve the
merge conflict. This encourages developers to merge early and often but we
don't all have that luxury.

Wouldn't it be nice if tooling could figure out if two developers are working
on the same code at the point they're writing it, before anything is even
committed and pushed.

I.e. perhaps I'm working on a change, if I could see that my colleague has made
changes in the same code, I can reach out to them coordinate our changes
earlier in the process, perhaps avoiding a merge conflict altogether.

## 🌳 Branch names

A lot of times I don't really care about branches, I just care about the
feature/fix I'm authoring.

Often leads to situations where I accidentally commit to main and
retrospectively have to checkout a new branch then revert main back to the
correct state.

Other times I'll create a temporary branch to work on a feature, but the scope
of that feature changes and I end up having to rename the branch (to reflect
the real nature of the change) before pushing.

A named branching model implies implies that I know ahead of time exactly the
scope of the thing I'm working on.

## ♻️  Undo

The vast majority of issues developers have with Git is when trying to undo
something or roll back a change and for each scenarios the solution is often
different.

Experienced developers build up a good mental model of how Git works and can
reliably undo changes, but I shouldn't have to be an expert to be able to undo
a change.

## ✨ AI

While I'm not particularly bullish on AI as a tool to author code, current
tools do a good job of being able to summarize existing code.

Having a mechanism to auto write commit messages or PR descriptions based on
code changes would be useful (this is already available in a few tools).

Another thing Scott mentions in the episode is the idea of using specifically
trained AI model to resolve merge conflicts.

Every publicly hosted git repo has a potential history of merge conflicts, so
we already have a huge corpus of data available to train a model on.

Such a model could be trained to resolve merge conflicts in a way that is
consistent with the way that projects typically resolve merge conflicts in the
past.

Although how well this would work in practice is another question.

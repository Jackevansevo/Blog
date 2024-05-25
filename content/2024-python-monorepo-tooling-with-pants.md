Title: Python Monorepo Tooling With Pants 👖
Date: 2024-05-25
Status: published
Tags: python

A while back I helped migrate a Python monorepo at my workplace
([multiply.ai](multiply.ai)) to use [Pantsbuild](https://www.pantsbuild.org/).
I thought I'd write a bit about my motivations for doing so and my experience
adopting pantsbuild.

If you're unfamiliar with pantsbuild (or build systems in general) I encourage
you to watch the talk below:

<div class="m-5">
    <div class="ratio ratio-16x9">
      <iframe src="https://www.youtube.com/embed/N6ENyH4_r8U" title="Benjy Weinberger: Python monorepos: what, why and how" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
    </div>
</div>


# Requirements

Storing all our code in a monorepo allows us to easily share code between
different deployable artifacts (app-engine services or cloud-functions).

A big challenge we face is that each deployment artifact has a different subset
of modules/requirements/dependencies.

The below image demonstrates a simplified overview of our monorpeo. The colours
indicate where shared library code in our repo might be shared across multiple
deployable artifacts.

I.e. we have shared schema definitions that need including in a cloud function
or app engine deployment but excluded from all other deployments.

Service C might be the only service to use numpy/scipy, but we want to avoid
including this dependency in our cloud function deployments or other artifacts.

<img src="{static}/images/Untitled-2024-05-06-1909.png" class="d-block w-100 p-4" alt="...">

A compiled language will typically take care of removing dead/unreachable code
automatically. But unfortunately Python doesn't really have any built in
tooling to support this[^1]

When starting out you might be able to get away with bundling all dependencies
for every deployment (irrespective of whether they're required or not). But
    this approach really doesn't scale all that well.

Large dependencies might start slowing down all your deployments, especially if
a compilation step is involved. You might also run into artificial size limits
of tools like google cloud functions or AWS lambda.

Additionally, for compliance purposes it makes sense to only include strictly
whats necessary. This reduces the blast radius of sensitive code getting leaked
(i.e. a server gets hacked or accidental exposure). It also enables us to
easily share code with clients if they should ever wish to audit our code.

Before adopting pants each deployable artifact had to manually specify which
local modules it needed. We had a custom build step to package then package up
this code. This meant switching between projects was a pain, increased the
barrier to re-using code and made it harder to globally manage/upgrade
dependencies with a single tool.

<br>

# Migrating to Pants

One of the main advantages touted by pants is that you can progressively adopt
it into your code-base. Instead of a piecemeal migration I opted just to get
everything working in a single big change.

At a top level we like to be able to define a single requirement file with ALL
the dependencies used in our monorepo. When working locally this enables us to
globally install ALL dependencies in a single virtualenv and then work on any
part of the repo.

The trade off here is that there's the potential to run into dependencies
conflicts, but in practice we don't tend to run into these issues. We're also
fortunate to be in a situation where no deployments require different
versions[^2].

<br>

# Advantages

In a typical Python project you'll likely install dependencies into a virtual
environment and periodically merge in changes from upstream. In situations
where upstream changes modify dependencies there's absolutely nothing stopping
you from running code locally without first updating your virtualenv.

In my experience this is a huge source of confusion[^3], especially to
contributors who are unfamiliar with the Python ecosystem.

Pants avoids this entire category of problems entirely by utilising Pex.
Executing a pants target typically builds a pex executable vendoring only the
necessary dependencies and requirements.

This is great for frontend engineers I work with who infrequently run the
backend locally to make changes or debug issues. They don't have to worry about
the idiosyncrasies of python virtual environments, they just run a command.

During the course of migrating the repo I asked an tonne of questions on the
Pants slack channel. I found the community there to be incredibly accommodating
and helpful.

---

[^1]: Python has `modulefinder` in the standard library that can be used to
determine the set of modules imported by a script. But it falls short in a lot
of cases.

[^2]: For these situations pants does support multiple lockfiles but we've never had
to reach for it.

[^3]: At a previous job we had a Slack bot reminder every time dependabot merged
changes to remind people to merge upstream and explicitly rebuild their
containers/re-create their virtual environments.

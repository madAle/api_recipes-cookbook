# api_recipes cookbook

Portable recipes for [api_recipes](https://github.com/madAle/api_recipes): each
file in [`recipes`](recipes) describes one HTTP API, as data only, and can be
installed in an application with one command.

    $ api_recipes install github

The command shows where the requests and the credential go and which calls are
not GET, asks, then writes `config/api_recipes/github.recipe.yml` and
`config/api_recipes/recipes.lock`. The application loads what is installed:

```ruby
ApiRecipes.configure do |config|
  config.recipes_paths = Dir['config/api_recipes/*.recipe.yml']
end

ApiRecipes.github.users.show('octocat').run
```

Portable recipes need api_recipes 3.0.0.beta3 or later. The
[README of the gem](https://github.com/madAle/api_recipes#portable-recipes)
describes the commands and the format.

## Recipes

| Recipe | API | Credential |
| --- | --- | --- |
| [`github`](recipes/github.recipe.yml) | GitHub REST API: every operation, 1,281 calls | `Authorization: Bearer TOKEN`; public data needs none |
| [`github_essentials`](recipes/github_essentials.recipe.yml) | GitHub REST API: the most used calls on users, repositories, issues, pull requests and releases, 14 calls | `Authorization: Bearer TOKEN`; public data needs none |
| [`httpbin`](recipes/httpbin.recipe.yml) | httpbin, a service that echoes requests | none, except for `bearer` |
| [`jsonplaceholder`](recipes/jsonplaceholder.recipe.yml) | JSONPlaceholder, a free fake REST API | none |

## Versions

A version of a recipe is published with the tag `NAME-VERSION`, for example
`github-1.0.0`. `api_recipes install github` takes the recipe on the main
branch; `api_recipes install github --version 1.0.0` takes the one at the tag.
The version in the file and the version in the tag are the same, and a
published tag is never moved. Version 1.0.0 of `github` was the small recipe that
is now called `github_essentials`; from 2.0.0 `github` has every operation.

## Contributing a recipe

1. Write `recipes/NAME.recipe.yml`. The name is made of lowercase letters,
   digits, `-` and `_`, and it is also the name of the API and `recipe.name`.
   `api_recipes import` writes a first draft from an OpenAPI description.
2. Start the file with a comment that says what the API is and has a `Usage`
   part: a few calls written in Ruby, each on a line that starts with `#   `.
   `ruby scripts/check_usage.rb recipes` runs them with the requests stubbed.
3. Check it: `api_recipes check recipes/NAME.recipe.yml`. Look at what
   `api_recipes install ./recipes/NAME.recipe.yml --to /tmp/try` shows: it is
   what everyone who installs the recipe will read.
4. Open a pull request. Say where the paths and the verbs come from: the page
   of the official documentation, or the OpenAPI description and its license.

What is asked of a recipe:

- It describes the official API of a service, at the official host. A variable
  is welcome where the host depends on the account or on the region.
- It never holds a credential. `auth` says where the credential travels.
- It uses `https`, and does not put the credential in the query string unless
  the API offers nothing else.
- Endpoint names say what the call does. A call that changes or deletes
  something has a name that says so.
- A change to a published recipe comes with a new `recipe.version`. A change of
  host, of `auth` or of a verb is explained in the pull request: `api_recipes
  update` shows it to everyone who updates.
- A comment beside each endpoint with the verb, the path and the main query
  parameters helps whoever reads the file.

The CI runs `api_recipes check` on every file of `recipes`, and the examples of
every `Usage` comment.

## Security

A recipe decides where your credential is sent. Read what `api_recipes install`
and `api_recipes update` show before you answer yes, and review the changes of
the installed files in your repository as you review code. To report a recipe
that sends requests where it should not, open an issue or write to the
maintainers.

## License

MIT. See [LICENSE](LICENSE).

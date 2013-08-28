# VersionableApi

VersionableApi is a small gem that hopefully helps you create versionable apis.

# The Problem

The most common way to start trying to version APIs is to create URIs (and routes and controllers) that look somewhat like this:
```
/api/v1/person.json
```
and route that to a controller in `app/controllers/api/v1/people_controller.rb`

Then, when you want to make a change to the person API, you create:
```
/api/v2/person.json
```
and you create `app/controllers/api/v2/people_controller.rb`.

But do you make `Api::V2::PeopleController` inherit from `Api::V1::PeopleController`? Or do you copy/paste every method in the Version 1 controller to the Version 2 controller?

# How VersionableApi tries to solve this problem

`VersionableApi` proposes that you create tiny controllers and then put version-specific behavior in modules that are included in that controller.  `VersionableApi` provides a module that does a tiny bit of magic to determine which "versioned" method gets called based on an HTTP Accept header and will look for lower versions of the methods in case a particular method on a controller hasn't revved yet.

Instead of putting the version of the API you want to call in the request URI, it's specified in the Accept Header by adding `;version=X` to one of the acceptable types.  The easiest way is to specify an accept type of `*/*;version=X` (where X is the version you want).

# Maintaining backwards compatibility with clients who are already using the "old" URI style

If you're transitioning an existing API to using VersionableApi and you need to be able to handle 'old' style routes (like `/api/v2/something.json`) VersionableApi provides a simple piece of Rack middleware that can help.

The `VersionableApi::ApiVersionInterceptor` can intercept requests to the 'old' api style and massage them to fit your new style.  You can include it by adding the following line inside your `config/application.rb` class:
```
config.middleware.use "VersionableApi::ApiVersionInterceptor"
```

By default, it will look for requests to paths that look like `/api/v#/something` and transform them into `/api/something` with `*/*;version=#` prepended to the HTTP_ACCEPT header and then forward the request on to your Rails app. You can configure most of how it behaves via initialization parameters if you don't like the defaults, for example:
```
config.middleware.use "VersionableApi::ApiVersionInterceptor", {version_regex: /\/API\/version-(?<version>\d+)\/(?<path>.*)/}
```
would cause it to match paths like: `/API/version-10/something` instead.  See documentation in `lib/versionable_api/api_version_interceptor.rb` for details.

# Example
`PeopleController` with support for 2 versions of API
```
class Api::PeopleController < ::ApplicationController
  respond_to :json
  include VersionableApi::ApiVersioning
  include Api::V1::People
  include Api::V2::People
end
```
The first version:
```
module Api::V1::People
  def show_v1
    respond_with People.first
  end
  def index_v1
    respond_with People.all
  end
end
```

And the Second version
```
module Api::V2::People
  def show_v2
    respond_with People.where(email: "foo@bar.com")
  end
end
```

**An explicit version 2 request comes in:**
```
GET /api/people/1234.json {HTTP_ACCEPT: text/json;version=2}
```
the `Api::V2::People#show_v2` method will handle the request.

**An explicit version 1 request comes in:**
```
GET /api/people/1234.json {HTTP_ACCEPT: text/json;version=1}
```
the `Api::V1::People#show_v1` method will handle the request.


**However, if a request comes in that looks like this:**
```
GET /api/people.json {HTTP_ACCEPT: text/json;version=2}
```
the request will get handled by the `Api::V1::People#index_v1` action.  Even though the request specified that it's using Version 2, since there isn't an explicit Version 2 of the `index` action, control will fall back to the Version 1 version.


# How to use it
1. Add it to your `Gemfile`:
    
    ```
    gem 'versionable_api', git: 'git@github.com:/centro/versionable_api.git'
    ```
2. Create API controllers that are not versioned: `Api::PeopleController` should be in `app/controllers/api/people_controller.rb`
3. Include the `VersionableApi::ApiVersioning` module in your controller
4. Add version identifiers to your action method names.  Instead of `def index; ... end;` you do `def index_v1; ... end;`.  You can put these in named modules to keep things tidy if you want, or just put them all in the base controller.
5. Set up routes like there's no versioning:
    
    ```
    namespace :api do 
      resources :people
    end
    ```

This project rocks and uses MIT-LICENSE.

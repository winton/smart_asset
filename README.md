SmartAsset
===========

Smart asset packaging for Rails and Sinatra.

Why?
----

We wanted asset packaging similar to <code>AssetPackager</code>, but with the following changes:

* Versioning is based off of modified time from Git
* Javascript compression uses Google Closure Compiler
* Compatible with any Ruby framework (tested with Rails 2, Rails 3, and Sinatra)
* More configurable options

Requirements
------------

<pre>
gem install smart_asset
</pre>

Rails 2
-------

### config/environment.rb

<pre>
config.gem 'smart_asset'
</pre>

Rails 3
-------

### Gemfile

<pre>
gem 'smart_asset'
</pre>

Sinatra
-------

require 'sinatra/base'
require 'smart_asset'

class Application < Sinatra::Base
  include SmartAsset::Adapters::Sinatra
end

Package Configuration File
--------------------------

### config/assets.yml

<pre>
javascripts:
  package_1:
    - jquery/jquery
    - underscore
  package_2:
    - front_page
stylesheets:
  package_1:
    - blueprint/blueprint
    - 960
  package_2:
    - front_page
</pre>

By default, SmartAsset will look for your assets in <code>public/javascripts</code> and <code>public/stylesheets</code>.

Create Packaged Assets
----------------------

In a shell, <code>cd</code> to your project and run

<pre>
smart_asset
</pre>

If your project is Git version controlled, only the assets that have changed will be repackaged.

Otherwise, all packages generate every time.

Include Packages in Your Template
---------------------------------

<pre>
&lt;%= javascript_include_merged :package_1, :package_2 %&gt;
&lt;%= stylesheet_link_merged :package_1, :package_2 %&gt;
</pre>

Migrating from AssetPackager
----------------------------

* Remove <code>asset\_packager</code> from your project
* Install <code>smart\_asset</code> into your project using the instructions for your framework (above)
* Move <code>config/asset\_packages.yml</code> to <code>config/assets.yml</code>
* <code>cd</code> to your project and run the <code>smart_asset</code> command

Profit!

Other Options
-------------

There are more options to be used within the <code>assets.yml</code> file.

Default values are listed below when applicable:

<pre>
# Asset host URL (defaults to nil)
asset_host:
  production: http://assets%d.mydomain.com

# How many asset hosts you have (if asset_host defined with %d)
asset_host_count: 4

# Public directory
public: public

# Package destination directory (within the public directory)
destination:
  javascripts: javascripts/packaged
  stylesheets: stylesheets/packaged

# Asset source directories (within the public directory)
sources:
  javascripts: javascripts
  stylesheets: stylesheets
</pre>
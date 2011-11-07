SmartAsset
===========

Smart asset packaging for Rails and Sinatra.

Features
--------

Similar to <code>AssetPackager</code>, but with the following changes:

* Git modified date/time for package version (only re-packages files that have been modified)
* [UglifyJS](https://github.com/mishoo/UglifyJS) for javascript compression
* Framework agnostic (adapters provided for Rails 2, Rails 3, and Sinatra)

<a name="installation"></a>

Installation
------------

### Install Gem

<pre>
gem install smart_asset
</pre>

### Rails 2

#### config/environment.rb

<pre>
config.gem 'smart_asset'
</pre>

### Rails 3

#### Gemfile

<pre>
gem 'smart_asset'
</pre>

### Sinatra

<pre>
require 'sinatra/base'
require 'smart_asset'

class Application &lt; Sinatra::Base
  include SmartAsset::Adapters::Sinatra
end
</pre>

Create Configuration File
-------------------------

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

By default, SmartAsset will look for assets in <code>public/javascripts</code> and <code>public/stylesheets</code>.

Create Packaged Assets
----------------------

<code>cd</code> to your project and run

<pre>
smart_asset
</pre>

If your project is Git version controlled, only the assets that have changed are repackaged.

Otherwise, all packages generate every time.

Include Packages in Your Template
---------------------------------

<pre>
&lt;%= javascript_include_merged :package_1, :package_2 %&gt;
&lt;%= stylesheet_link_merged :package_1, :package_2 %&gt;
</pre>

Migrating from AssetPackager
----------------------------

* <code>rm vendor/plugins/asset\_packager</code>
* <a href="#installation">Install SmartAsset</a>
* Move <code>config/asset\_packages.yml</code> to <code>config/assets.yml</code>
* Instead of running <code>rake asset:packager:build_all</code>, run <code>smart\_asset</code>

Other Options
-------------

### config/assets.yml

You may add extra options to your <code>config/assets.yml</code> file.

Below are the default values (excluding <code>asset\_host</code>):

<pre>
# Append random numbers to script paths on each request
append_random:
  development: true

# Asset host URL (defaults to ActionController::Base.asset_host or nil)
asset_host:
  production: http://assets%d.mydomain.com

# How many asset hosts you have (use if asset_host defined with %d)
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

### smart\_asset

You may use environment variables with the <code>smart\_asset</code> command to alter its behavior.

<code>DEBUG=1</code><br/>Output commands that are running, leave the tmp file around for inspection

<code>PACKAGE=package\_1</code><br/>Only compress a specific package

<code>MODIFIED='12/1/2010 12:00'</code><br/>Use a default modified time other than Time.now for non-version controlled files

<code>WARN=1</code><br/>Get compression warnings from UglifyJS and YUI Compressor

#### Example:

<pre>
WARN=1 smart_asset
</pre>

Running Specs
-------------

Forks and contributions to this project are much appreciated, but please make sure the specs run!

To run the basic specs:

<pre>
spec spec
</pre>

There are also framework specs to make sure the helpers work in Rails 2, Rails 3, and Sinatra 1:

<pre>
spec/run
</pre>
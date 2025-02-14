# Polaris

This is the Rails API app for Polaris.

## Setup

If ruby has not yet been installed, RVM (Ruby Version Manager) can be used to install and manage different versions of ruby.  The current ruby version used for this project is 3.0.0

See https://rvm.io/rvm/install for installation instructions


### Install dependencies

Install Redis for sidekiq

See https://github.com/Homebrew/brew for installing redis with Brew

Install Ghostscript for merging pdfs

See https://github.com/Homebrew/brew for installing ghostscript with Brew

See https://installati.one/ubuntu/20.04/ghostscript/ for installing ghostscript with ubuntu


`brew install ghostscript`

See https://github.com/Homebrew/brew for installing ImageMagick with Brew


See https://linuxhint.com/install-the-latest-imagemagick-on-ubuntu/ for installing ImageMagick with ubuntu



`brew install imagemagick`

Next install the ruby gem dependencies
```
bundle install
```

#### Rails master.key
The rails master key for editing/viewing sensitive credentials is stored in 1Password.  Reach out to the dev team to get access.


#### Setup the local databases
The following commands will setup the database, run the necessary migrations, and initially seed the database
```
bundle exec rake db:setup
bundle exec rake db:migrate
```

#### Accessing Credentials File


Credentials key of different environments are present in One Password Account https://1password.com/

```
EDITOR=vi bin/rails credentials:edit
```

##### For starting Sidekiq in background run

```
#default
bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml -e development

#critical
bundle exec sidekiq -d -L log/sidekiq.critical.log -C config/sidekiq.critical.yml -e development
```

#### For stopping sidekiq run

```
ps -ef | grep sidekiq | grep -v grep | awk '{print $2}' | xargs kill -9
```

You can access sidekiq portal by accessing url: http://localhost:3000/api/sidekiq

Username and Password for accessing sidekiq portal are saved in credentials.yml.enc file


#### Zipcode
The postal codes data is sourced from zipcodeapi.com, and is populated periodically with the following rake task.

```
You can run task from sidekiq portal manually by enqueue StatePostalCodeWorker Job.

or

By running rails console and run StatePostalCodeWorker.perform_async
```

We **do not** want to run this task locally.  The API is rate-limited and the rake task will quickly exhaust the number of requests we can make to the API within a certain time period.  However, the alternative is to get a table dump of the current zipcodes data from the AWS dev environment, and load it manually.


#### Start local server
Start the local server

```
bundle exec rails server
```

App can be viewed in the browser by navigating to http://localhost:3000

### Testing

To run the full test suite

```
bundle exec rspec spec
```


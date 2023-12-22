# SolidQueueUi
I wanted to setup a quick UI to see jobs run by solid_queue. It's currently very barebones.

## Usage
This gem heavily mimics the implementation of the Sidekiq UI. To view the jobs, here's what to do:

Update `config/routes.rb` to mount SolidQueueUI::Web like so:

```
  Rails.application.routes.draw do
    mount SolidQueueUi::Web => '/solid_queue_ui'

    # all your routes.
  end
```

The main page should be now visible at `your_url/solid_queue_ui` as specified. You can use any string after the slash and it will work accordingly.

This is the first version. Wanted to release this and make improvements. There's no polling, turbo refreshes, other tables, editing, sorting, NO TESTS, etc. Just wanted to put this out first.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "solid_queue_ui"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install solid_queue_ui
```

## Contributing
You can just fork and submit a PR for your issue.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Gendered

Guess the gender of names with the help of the [genderize.io](http://genderize.io).

```bash
gem install gendered
```

You can guess one name at a time...
```ruby
> require 'gendered'
> name = Gendered::Name.new("Sean")
> name.gender
> :not_guessed
> name.guess!
=> :male
> name.male?
=> true
> name.female?
=> false
> name.probability
=> "0.99E0"
> name.sample_size
=> 967
```

Or batch up a list of names (which sends only one request per hundred names to the API)...
```ruby
> require 'gendered'
> name_list = Gendered::NameList.new(["Sean","Theresa"])
> name_list.guess!
=> [:male, :female]
> name_list.collect { |name| name.male? }
=> [true, false]
> name_list.collect { |name| name.female? }
=> [false, true]
> name_list.collect { |name| name.probability.to_f }
=> [0.99, 1.0]
> name_list.collect { |name| name.sample_size }
=> [967, 370]
> name_list["Sean"].gender
=> :male
```

Options can be passed in too...
```ruby
options = { :apikey => "X123Y456", :country_id => "dk" }
name = Gendered::Name.new("Sean")
name.guess!(options)
name_list = Gendered::NameList.new(["Kim", "Theresa"], options)
```

Or set globally, as defaults...
```ruby
Gendered.configure do |config|
  config.apikey = "X123Y456"
  config.language_id = "pt"
  # ...
end
```

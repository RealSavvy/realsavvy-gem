[![CircleCI](https://circleci.com/gh/RealSavvy/realsavvy-gem.svg?style=svg)](https://circleci.com/gh/RealSavvy/realsavvy-gem)

# realsavvy-gem
RealSavvy Connection Gem

# API Docs
https://docs.realsavvy.com/reference

## How To Use

### Install Package

```bash
gem install real_savvy
```

### Creating A Client

```ruby
require 'real_savvy'

client = RealSavvy::Client.new(token: 'jwt.access.token')
```

### Querying for properties

```ruby
client.properties.search(filter: {price: {max: 500000}}, page: {size: 8}).results
```

### Show a property

```ruby
client.properties.show(id: complex_id).result
```

### Get share token for a user

```ruby
token = RealSavvy::JWT::Token.new('jwt.access.tokenForUser')

token.to_share_token.short_token
```

### Get Agents For Given Site

```ruby
client.agents.index(page: {size: 8}).results
```

### Show Agent

```ruby
client.agents.show(id: 48).result
```

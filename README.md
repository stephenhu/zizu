# zizu

zizu is an opinionated static site generator based on bootstrap, haml, html5,
and github.

## requirements

* bundler
* github_api
* haml
* thor
* tilt

## installation

### gem package

1.  install the gem from rubygems
```gem install zizu-0.0.1.gem```

### from source

1.  clone the repository
```git clone git@github.com:stephenhu/zizu```
2.  install dependencies
```bundle install # from the zizu root directory```
3.  build the gem
```gem build zizu.gemspec # from the zizu root directory```
4.  install the local gem
```gem install zizu-0.0.1.gem``` 

## faq

1.  what does zizu stand for?
```zizu is the chinese pin yin for spider, technically it should be zhizhu,
but that's a bit harder to type.```
2.  are sinatra haml files compatible with zizu?
```technically i tried to keep the syntax consistent with sinatra since i'm
a big fan, so i mocked _haml_ and _url_ functions.```


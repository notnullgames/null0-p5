This is an experimental null0 runtime, with lots of inspiration from [processing](https://processing.org/) and [p5js](https://p5js.org/) written in nim.

The idea is you make your game in whatever language you like, and it will work on any platform natively & the web.

Initially, I will make a native runtime, but the plan is also a web & retroarch runtime.


## Usage

Get the [release](https://github.com/notnullgames/null0-p5/releases) for your platform and run it like this:

```
null0 draw.null0
```

## Development

```
# get this repo and it's submodules
git clone --recursive git@github.com:notnullgames/null0-pixie.git
cd null0-pixie

# compile draw cart
nimble cart draw

# compile justlog cart
nimble cart justlog

# build runtime, then run it on draw.null0
nimble run -- draw.null0
```
This is an experimental null0 runtime, with lots of inspiration from [processing](https://processing.org/) and [p5js](https://p5js.org/) written in nim.

The idea is you make your game in whatever language you like, and it will work on any platform natively & the web.

Initially, I will make a native runtime, but the plan is also a web & retroarch runtime.


## Usage

Get the nightly-release for your platform:

- [MacOS](https://nightly.link/notnullgames/null0-p5/workflows/build/main/null0-macOS.zip)
- [Linux](https://nightly.link/notnullgames/null0-p5/workflows/build/main/null0-ubuntu.zip)

Run it like this:

```
null0 draw.null0
```

## Development

```
# get this repo and it's submodules
git clone --recursive git@github.com:notnullgames/null0-p5.git
cd null0-p5

# compile draw cart
nimble cart drawing

# compile justlog cart
nimble cart justlog

# build runtime, then run it on draw.null0
nimble run -- drawing.null0
```

You can see all the available carts in [carts](carts/).
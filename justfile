set shell := ["bash", "-cu"]

default := ("test")

build:
    zig build

install:
    zig build install

# Run the main test suite (pass extra args after `--`).
test *args:
    zig build test -- {{args}}

# Run the collision-focused test variant (pass extra args after `--`).
test-collisions *args:
    zig build test-collisions -- {{args}}

clean:
    rm -rf zig-out zig-cache

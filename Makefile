.PHONY: test

all: clean upgrade yarn-install husky-install build test snapshot format build-rust

clean  :; forge clean

upgrade :; foundryup

yarn-install :; yarn install

husky-install :; npx husky install

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

build-rust:
	cd rust && cargo build --release

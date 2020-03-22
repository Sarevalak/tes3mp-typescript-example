This repository demonstrates how to build tes3mp server side script using typescript.

# How to build

## Clone this repository
```
git clone https://github.com/Sarevalak/tes3mp-typescript-example.git
cd ./tes3mp-typescript-example
```
## Install dependencies
```
npm i
```

## Build
```
npm run build
```

## Install lua script on tes3mp server

1. Copy contents of directory `./dist/custom` to `/server/scripts/custom`
2. Add `require("custom/PassiveRegen")` to `/server/scripts/customScripts.lua`

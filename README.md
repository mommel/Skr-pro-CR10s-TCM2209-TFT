This repository uses submodules to informations and firmware to mod a Creality CR10s with a Bigtreetech SKR Pro v1.2 combined with TMC2209 drivers and a Bigtreetech TFT7 v3.

# Usage
Just open btt.code-workspace in VSCode and run the included tasks.

# Tooling
The build folder holds scripts to change the firmwares configuration files with data setup in a json, so you can update the submodules to the latest version. There are scripts to build the firmware and copy the generated firmware to a dist folder.
The scripts build:
* Marlin 2 Firmware
* BTT TFT Firmware (incl. language and theme)
* ESP-01 ESP3D Firmware

# License
The license covers only the files of this repository. Node modules and Submodules are untouched by the license and they have their own firmware.

The MIT License

Copyright © 2021 Mommel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# Disclaimer
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

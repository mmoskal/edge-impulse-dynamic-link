# Build EdgeImpulse impulses for dynamic linking

The idea of this build method is to build an impulse, so that it can be easily replaced in
hosting application, without rewriting the application itself (eg., for a partial OTA update).
The build results in a `.bin` file that needs to be flashed at a specific address
(`$(FLASH_START)`), and needs a bit (`$(COMM_SIZE)`) of SRAM also at a specific address
(`$(COMM_START)`).

To build:

* copy (or symlink) the following folders here:
    `tflite-model`,
    `model-parameters`,
    `edge-impulse-sdk`
* run `make`
* the file `build/eimodel.bin` is the one to link in the host app

## Configuration

There are parameters on top of `Makefile` that can be adjusted.
For example, if you get an error like `section '.bss' will not fit in region 'RAM'` you can
try to do something like `make COMM_SIZE=3K`; however, this needs to be matched at the host application side.


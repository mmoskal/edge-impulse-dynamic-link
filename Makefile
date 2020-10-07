# this will depend on MCU
# the RAM (data/BSS) section will start here:
COMM_START ?= 0x20002000
# tha maximum size of RAM
COMM_SIZE ?= 4K
# the flash (text) should be loaded at this address 
FLASH_START ?= 0x8060008
# the maximum size of flash
FLASH_SIZE ?= 128K

PREF = arm-none-eabi-
COMMON_FLAGS = \
	-mcpu=cortex-m4 -mfloat-abi=softfp -mfpu=fpv4-sp-d16 -DTF_LITE_MCU_DEBUG_LOG \
	-fdata-sections -ffunction-sections

CC = $(PREF)gcc
CXX = $(PREF)gcc

BUILD = build
LD_SCRIPT = $(BUILD)/linker.ld

CFLAGS = $(COMMON_FLAGS) -Wall
CXXFLAGS = $(COMMON_FLAGS) \
	-fwrapv -fno-rtti -fno-threadsafe-statics -fno-exceptions \
	-fno-unwind-tables -Wl,--gc-sections -Wl,--sort-common -Wl,--sort-section=alignment -Wno-array-bounds

MACROS += -DTF_LITE_DISABLE_X86_NEON
MACROS += -DEIDSP_SIGNAL_C_FN_POINTER=1
MACROS += -D__TARGET_CPU_CORTEX_M4=1

COMMON_INC = \
-Iedge-impulse-sdk/CMSIS/Core/Include \
-Iedge-impulse-sdk/CMSIS/DSP/Include \
-Iedge-impulse-sdk/CMSIS/DSP/PrivateInclude \
-I. \
-Isource \
-Iedge-impulse-sdk \
-Imodel-parameters \
-Itflite-model \
-Iedge-impulse-sdk/anomaly \
-Iedge-impulse-sdk/classifier \
-Iedge-impulse-sdk/dsp \
-Iedge-impulse-sdk/dsp/kissfft \
-Iedge-impulse-sdk/porting \

CXXFLAGS += -std=c++11
CXXFLAGS += $(COMMON_INC)
CXXFLAGS += -Iedge-impulse-sdk/tensorflow
CXXFLAGS += -Iedge-impulse-sdk/third_party
CXXFLAGS += -Iedge-impulse-sdk/third_party/flatbuffers
CXXFLAGS += -Iedge-impulse-sdk/third_party/flatbuffers/include
CXXFLAGS += -Iedge-impulse-sdk/third_party/flatbuffers/include/flatbuffers
CXXFLAGS += -Iedge-impulse-sdk/third_party/gemmlowp/
CXXFLAGS += -Iedge-impulse-sdk/third_party/gemmlowp/fixedpoint
CXXFLAGS += -Iedge-impulse-sdk/third_party/gemmlowp/internal
CXXFLAGS += -Iedge-impulse-sdk/third_party/ruy

CFLAGS += $(COMMON_INC)


EXE = eimodel

SRC = $(wildcard  \
	edge-impulse-sdk/dsp/kissfft/*.cpp \
	edge-impulse-sdk/dsp/dct/*.cpp \
	edge-impulse-sdk/tensorflow/lite/kernels/*.cc \
	edge-impulse-sdk/tensorflow/lite/kernels/internal/*.cc \
	edge-impulse-sdk/tensorflow/lite/micro/kernels/*.cc \
	edge-impulse-sdk/tensorflow/lite/micro/*.cc \
	edge-impulse-sdk/tensorflow/lite/micro/memory_planner/*.cc \
	edge-impulse-sdk/tensorflow/lite/core/api/*.cc \
	edge-impulse-sdk/dsp/memory.cpp \
	edge-impulse-sdk/tensorflow/lite/c/common.c  \
	edge-impulse-sdk/CMSIS/NN/Source/*/*.c \
	edge-impulse-sdk/CMSIS/DSP/Source/*/*.c \
	tflite-model/*.cpp \
	source/*.c*)
OBJ := $(SRC:.cpp=.o)
OBJ := $(OBJ:.c=.o)
OBJ := $(OBJ:.cc=.o)
OBJ := $(addprefix $(BUILD)/,$(OBJ))

#LDFLAGS = -Wl,-Map -Wl,$(BUILD)/$(EXE).map -nodefaultlibs -lm mylib.a -lgcc
LDFLAGS = -Wl,-Map -Wl,$(BUILD)/$(EXE).map -lm \
	-specs=nosys.specs -specs=nano.specs \
	-T"$(LD_SCRIPT)" -Wl,--gc-sections

all:
	$(MAKE) -j16 $(BUILD)

.PHONY: $(BUILD) clean

$(BUILD): $(OBJ) $(LD_SCRIPT)
	$(CXX) $(MACROS) $(CXXFLAGS) -o $(BUILD)/$(EXE) $(OBJ) $(LDFLAGS) 
	$(PREF)objcopy -O binary $(BUILD)/$(EXE) $(BUILD)/$(EXE).bin

$(BUILD)/%.o: %.c
	@mkdir -p `dirname $@`
	$(CC) -c $(MACROS) $(CFLAGS) $< -o $@

$(BUILD)/%.o: %.cpp
	@mkdir -p `dirname $@`
	$(CXX) -c $(MACROS) $(CXXFLAGS) $< -o $@

$(BUILD)/%.o: %.cc
	@mkdir -p `dirname $@`
	$(CXX) -c $(MACROS) $(CXXFLAGS) $< -o $@

clean:
	rm -rf $(BUILD)/

.force:

$(LD_SCRIPT): Makefile .force
	mkdir -p $(BUILD)
	: > $@
	echo "MEMORY {" >> $@
	echo "RAM (rwx)   : ORIGIN = $(COMM_START), LENGTH = $(COMM_SIZE)" >> $@
	echo "FLASH (rx)  : ORIGIN = $(FLASH_START), LENGTH = $(FLASH_SIZE)" >> $@
	echo "}" >> $@
	echo "INCLUDE common.ld" >> $@

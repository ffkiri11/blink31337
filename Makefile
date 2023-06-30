#******************************************************************************#
#**                         Arduino Makefile                                 **#
#**                      (c) xerasovanon@gmail.com                           **#
#**                         under BSD License                                **#
#******************************************************************************#

AVR_I_DIR=	/usr/lib/avr/include
INO_BASE_DIR= 	/usr/share/arduino/hardware/arduino
INO_SRC_DIR=	$(INO_BASE_DIR)/avr/cores/arduino
HW_I_DIR=	$(INO_BASE_DIR)/avr/variants/eightanaloginputs

CFLAGS=		-Wall -Os\
		-flto -fuse-linker-plugin -Wl,--gc-sections -fwhole-program\
		-funsigned-char\
		-funsigned-bitfields\
		-fno-inline-small-functions\
		-fno-exceptions\
		-mmcu=atmega328\
		-DF_CPU=16000000L -DARDUINO=10607 -DARDUINO_AVR_NANO\
		-DARDUINO_ARCH_AVR -fno-exceptions

CPPFLAGS=	$(CFLAGS) -std=c++11 -lm -fpermissive\
		-fno-threadsafe-statics -fno-threadsafe-statics

CC=  		avr-gcc $(CFLAGS)
CXX=		avr-g++ $(CPPFLAGS)

DEBUG=		-g3
CLI_INO_FLAGS=	-b arduino:avr:uno
SKETCHNAME=	$(notdir $(PWD))
ARDUINO_CLI=	/data/develop/arduino-cli/bin/arduino-cli
ARDUINO_CLI_PP=	$(ARDUINO_CLI) compile $(CLI_INO_FLAGS) --preprocess

CORE_C_SRC=	$(wildcard $(INO_SRC_DIR)/*.c)

CORE_CXX_SRC=	$(wildcard $(INO_SRC_DIR)/*.cpp)

CORE_C_OBJ=	$(addsuffix .c.o, $(basename $(notdir $(CORE_C_SRC))))
CORE_CXX_OBJ=	$(addsuffix .cpp.o, $(basename $(notdir $(CORE_CXX_SRC))))

release: DEBUG=
release: debug

debug: $(SKETCHNAME).hex

$(SKETCHNAME).hex : $(SKETCHNAME).elf
	avr-objcopy -j .text -j .data\
		-O ihex $(SKETCHNAME).elf $(SKETCHNAME).hex

$(SKETCHNAME).elf : $(CORE_C_OBJ) $(CORE_CXX_OBJ) $(SKETCHNAME).o
	$(CXX) -Os $(MMCU) $(LDFLAGS)\
	       -o $(SKETCHNAME).elf\
	       -I $(INO_SRC_DIR)\
	       -I $(HW_I_DIR)\
		$+

$(SKETCHNAME).o : $(SKETCHNAME).cpp
	$(CXX) -Os $(MMCU) $(LDFLAGS)\
	       -o $(SKETCHNAME).o\
	       -I $(INO_SRC_DIR)\
	       -I $(HW_I_DIR)\
	       -c $<

%.cpp : %.ino
	$(ARDUINO_CLI_PP) . > $@

%.c.o : $(INO_SRC_DIR)/%.c
	$(CC) $(DEBUG) $(DEFS) $(MMCU)\
		-I $(INO_SRC_DIR)\
		-I $(HW_I_DIR)\
		-I $(AVR_I_DIR) -c $< -o $@

%.cpp.o : $(INO_SRC_DIR)/%.cpp
	$(CXX) $(DEBUG) $(DEFS) $(MMCU)\
		-I $(INO_SRC_DIR)\
		-I $(HW_I_DIR)\
		-I $(AVR_I_DIR) -c $< -o $@

clean :
	rm *.o *.elf *.hex $(SKETCHNAME).cpp

tags : $(CORE_C_SRC) $(CORE_CXX_SRC) $(SKETCHNAME).cpp
	ctags -R . $(INO_SRC_DIR)\
	       $(CORE_C_SRC) $(CORE_CXX_SRC) $(SKETCHNAME).cpp

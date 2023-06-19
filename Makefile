AVR_I_DIR= /usr/lib/avr/include
CORE_SRC= /usr/share/arduino/hardware/arduino/avr/cores/arduino/main.cpp
WIRING_SRC= /usr/share/arduino/hardware/arduino/avr/cores/arduino/wiring.c
WD_SRC= /usr/share/arduino/hardware/arduino/avr/cores/arduino/wiring_digital.c
HOOKS_SRC= /usr/share/arduino/hardware/arduino/avr/cores/arduino/hooks.c
HW_I_DIR= /usr/share/arduino/hardware/arduino/avr/variants/eightanaloginputs
ARDUINO_CORE_I_DIR= /usr/share/arduino/hardware/arduino/avr/cores/arduino
DEFS= -DF_CPU=16000000
MMCU= -mmcu=atmega328
CC=avr-gcc
CXX=avr-g++
DEBUG=-g3

release: DEBUG=
release: firmware

firmware : blink31337.elf
	avr-objcopy -j .text -j .data -O ihex blink31337.elf blink31337.hex

blink31337.elf : main.o w_digital.o blink.o wiring.o hooks.o
	$(CXX) -Os $(MMCU) -o blink31337.elf \
		main.o \
		w_digital.o \
		blink.o \
		wiring.o \
		hooks.o

main.o : $(CORE_SRC) blink.o w_digital.o
	$(CXX) $(DEBUG) -Os $(DEFS) $(MMCU) $(CORE_SRC) \
		-I $(ARDUINO_CORE_I_DIR) \
		-I $(HW_I_DIR) -c -o main.o 

w_digital.o : $(WD_SRC)
	$(CC) $(DEBUG) $(DEFS) $(MMCU) $(WD_SRC) \
	       	-o w_digital.o -I $(HW_I_DIR) -I $(AVR_I_DIR) -c 

blink.o : blink.cpp
	$(CXX) $(DEBUG) $(DEFS) -Os $(MMCU) \
		-I $(AVR_I_DIR)\
		-I $(ARDUINO_CORE_I_DIR) \
		-I $(HW_I_DIR) \
		-c blink.cpp -o blink.o

wiring.o : $(WIRING_SRC) 
	$(CC) $(DEBUG) $(DEFS) $(MMCU) \
		-I $(AVR_I_DIR) \
		-I $(HW_I_DIR) \
		-c $(WIRING_SRC) \
		-o wiring.o

hooks.o : $(HOOKS_SRC)
	$(CC) $(DEBUG) $(MMCU) \
		-I $(AVR_I_DIR) \
		-I $(HW_I_DIR) \
		-c $(HOOKS_SRC) \
		-o hooks.o
clean :
	rm *.o *.elf *.hex


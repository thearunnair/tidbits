CXX = clang++
CC = clang

WARNINGS = -Wall
PROGRAM_NAME = program
SOURCE = $(PROGRAM_NAME).cpp
FLAGS = -std=c++11

all: $(PROGRAM_NAME)

$(PROGRAM_NAME): $(SOURCE)
	$(CXX) $(FLAGS) $(SOURCE) -o bin/$(PROGRAM_NAME) $(WARNINGS)

clean: 
	rm -f bin/$(PROGRAM_NAME) bin/$(PROGRAM_NAME).o
CC = pdflatex
OPEN = open

BUILD_DIR = ./Latex\ build
SRC_DIR = ./

_BUILD_FILES = 1 2 3 4
BUILD_FILES = $(patsubst %, $(BUILD_DIR)/stats%.pdf, $(_BUILD_FILES))


OUTPUT_OPTION = -output-directory=$(BUILD_DIR)


all: $(BUILD_FILES)

$(BUILD_DIR)/%.pdf : $(SRC_DIR)/%.tex 
	$(CC) $(OUTPUT_OPTION) $^	


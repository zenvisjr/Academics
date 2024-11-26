# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Iinclude  # Include the header files from the 'include' folder

# Folders
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build

# Target
TARGET = $(BUILD_DIR)/my_shell

# Find all .cpp files in src folder
SRC = $(wildcard $(SRC_DIR)/*.cpp)

# Generate object files from .cpp files
OBJ = $(SRC:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)

# Default target
all: $(TARGET)

# Rule for linking the object files to the final executable
$(TARGET): $(OBJ)
	$(CXX) $(OBJ) -o $(TARGET) -lreadline  # Link the Readline library

# Rule for compiling .cpp files to .o files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)  # Ensure build directory exists
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up the build folder
clean:
	rm -rf $(BUILD_DIR) $(TARGET)

# Phony targets (not files)
.PHONY: all clean

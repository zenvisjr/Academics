
# Custom POSIX Shell

## Table of Contents

#### [Overview](#overview)
#### [Features Implemented](#features-implemented)
   - [Shell Prompt](#shell-prompt)
   - [cd command](#cd-command)
   - [echo command](#echo-command)
   - [pwd command](#pwd-command)
   - [ls command](#ls-command)
   - [Process Management](#process-management)
   - [pinfo Command](#pinfo-command)
   - [Signals Handling](#signals-handling)
   - [I/O Redirection](#io-redirection)
   - [Piping](#piping)
   - [History](#history)
#### [Implementation Details](#implementation-details)
#### [Requirements](#requirements)
#### [Project Structure](#project-structure)
#### [Installation and Setup](#installation-and-setup)
#### [Usage](#usage)
#### [Contributing](#contributing)
#### [Learning Outcomes](#learning-outcomes)
#### [Author](#author)
#### [Points to Notice](#points-to-notice)

---

## Overview

This is a custom shell implementation in C++ that mimics the original Linux terminal, demonstrating a deep understanding of process management, system calls, and shell functionality.

## Features Implemented

### Shell Prompt
- Dynamically displays `username@system_name:current_directory>`.
- Supports random spaces and tabs in command input.
- Home directory represented by `~`.

### `cd` Command
- Supports flags: `.`, `..`, `-`, `~`.
- Handles directory navigation with error checking.
- Changes current working directory and reflects absolute path.

### `echo` Command
- Prints input strings.
- Handles tabs and spaces.

### `pwd` Command
- Displays current working directory.

### `ls` Command
- Implements detailed file/directory listing.
- Supports flags:
  - `-a`: Show all files (including hidden).
  - `-l`: Detailed listing with file permissions, size, etc.
- Handles multiple flags and directory arguments.
- Supports various input combinations like `ls`, `ls -a`, `ls -l`, etc.

### Process Management

#### Foreground Processes
- Shell waits for process completion.
- Blocks the shell until process exits.

#### Background Processes
- Use `&` to run processes in the background.
- Prints Process ID (PID) of background processes.
- Supports multiple simultaneous background processes.

### `pinfo` Command
- Displays process information.
- Shows PID, process status, memory usage, executable path.
- Supports querying specific process or current shell process.

### Signals Handling
- `CTRL-Z`: Push foreground job to background.
- `CTRL-C`: Interrupt running foreground process.
- `CTRL-D`: Logout from shell.

### I/O Redirection
- Supports `<`, `>`, `>>` operators.
- Redirects input/output for commands.
- Creates/overwrites/appends output files.
- Handles input file non-existence.

### Piping
- Implements `|` for command chaining.
- Supports multiple pipe combinations.
- Works with redirection.

### History
- Stores the last 20 commands.
- `history` command displays recent commands.
- Up arrow key navigation through command history.

---

## Implementation Details
- **Language**: C/C++
- **System Calls**: `fork()`, `exec()`, `wait()`, `signal()`
- **Error Handling**: Using `perror()`
- **Design**: Modular design with separate functions for different functionalities.

---

## Requirements

Before you begin, ensure you have the following software installed:
- **g++**: The GNU C++ compiler.
- **Make**: A build automation tool.
- **Readline library** (for auto-completion support): The Readline library is required to provide features like command-line editing and auto-completion.

To install Readline on Linux:
```bash
sudo apt-get install libreadline-dev
```

---

## Project Structure

```
/CustomShell
|-- /include              # Header files
|-- /src                  # Source files
|-- /build                # Directory for compiled object files and final executable
|-- Makefile              # Makefile to build the project
```

### Key Files
- **include/**: Contains header files (`*.h`) for various components like command execution, directory manipulation, and history management.
- **src/**: Contains the implementation (`*.cpp`) files for the core functionality.
- **build/**: Contains the compiled object files and the final executable.
- **Makefile**: A Makefile to automate the compilation and linking process.

---

## Installation and Setup

1. Clone the repository or download the project:
   ```bash
   git clone https://github.com/zenvisjr/Academics.git
   cd Projects/CustomShell
   ```

2. Install the necessary dependencies. For Ubuntu/Debian:
   ```bash
   sudo apt-get update
   sudo apt-get install libreadline-dev g++
   ```

3. Build the project using the `Makefile`. In the root directory of the project:
   ```bash
   make
   ```

   This will compile the source files and generate the executable `my_shell` in the `build/` directory.

---

## Usage

After building the project, you can run the shell by executing the following command:

```bash
./build/my_shell
```

Now give it any command like you would in a Linux terminal, and it will output the response with 99.99% accuracy.

---

## Contributing

Feel free to fork the repository and submit pull requests for improvements or bug fixes. Please follow the guidelines for clear and concise commit messages.

---

## Learning Outcomes

- Process creation and management.
- System programming in Unix-like environments.
- Command parsing and execution.
- Signal handling.
- I/O redirection and piping techniques.

---

## Author

**Ayush Rai**  
Email: [ayushrai.cse@gmail.com]

---

## Points to Notice:
- The tab key does not currently work for giving spaces in the terminal.
- Some processes like Nautilus (Ubuntu's file explorer) and Firefox, for which the terminal parent process does not wait, will cause the prompt to return immediately without waiting for the process to complete.
- When using piping with output redirection, the final output is written to the output file, but `execvp` still shows a `perror` message.
- Typing a random process name and running it in the background gives a `perror` in `execvp`, but the terminal gets stuck and does not move to the next line.

---

#ifndef HEADER_H
# define HEADER_H

#include <string>
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <ctime>
#include <iomanip>
#include <vector>
#include <pwd.h>
#include <grp.h>
#include <filesystem>
#include <fstream>
#include <readline/readline.h>
#include <readline/history.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <algorithm>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <utility>
#include <readline/history.h>

// using namespace std;
// using namespace std::filesystem;

extern char curr_dir[500];            // Declare the global variable
extern std::string home;
extern std::string current_directory;
extern std::string prev_dir;
extern std::vector<std::string> history;

#endif
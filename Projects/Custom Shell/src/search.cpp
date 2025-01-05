#include "header.h"
#include "search.h"
#include "utility.h"
using namespace std;

// bool search(string &command)
// {
//     command = command.substr(7);
//     command = trim(command);
//     //cout<<"search: "<<command<<endl;

//     bool result = searchit(filesystem::current_path(), command);
//     cout << (result ? "True" : "False") << endl;
//     return true;

// }

// bool searchit(const filesystem::path& start_dir, string& input) 
// {
//     // checking if file or folder exist in current directory
//     if (start_dir.filename() == input) {
//         return true;
//     }

//     // if no then searching recursively inside current directory 
//     if (filesystem::is_directory(start_dir)) 
//     {
//         for (const auto& inside : filesystem::directory_iterator(start_dir)) 
//         {
//             if (searchit(inside.path(), input)) return true;  // got it somewhere inside
//         }
//     }

//     // not found 
//     return false;
// }

bool search(string& command) {
    command = command.substr(7);  // Remove "search " prefix
    command = trim(command);      // Trim any leading/trailing whitespace
    cout << "Searching for: " << command << endl;

    if (getcwd(curr_dir, sizeof(curr_dir)) == nullptr) 
    {
        perror("Failed to get current working directory");
        return false;
    }

    bool result = searchit(curr_dir, command);
    cout << (result ? "True" : "False") << endl;
    return result;
}

// Recursive search function
bool searchit(const char* dir_path, string& target) {
    DIR* d;
    struct dirent* entry;
    d = opendir(dir_path); // Open the directory
    if (!d) {
        perror("Unable to open directory");
        return false;
    }

    
    while ((entry = readdir(d)) != nullptr) {
        string name = entry->d_name;

        // Skip "." and ".." entries
        if (name == "." || name == "..") continue;

        // If current entry matches the target, return true
        if (name == target) {
            closedir(d);
            return true;
        }

        // If it's a directory, search recursively
        if (entry->d_type == DT_DIR) {
            string new_path = string(dir_path) + "/" + name;
            if(searchit(new_path.c_str(), target)) {
                closedir(d); // Close the current directory before returning
                return true;
            }
        }
    }

    closedir(d); // Close the directory after traversing all entries
    return false; // Target not found
}

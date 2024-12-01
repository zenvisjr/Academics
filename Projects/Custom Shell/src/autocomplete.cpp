#include "header.h"
#include "autocomplete.h"


using namespace std;
namespace fs = std::filesystem;  // Alias for filesystem namespace

char** auto_complete(const char* input, int start, int end)  //The partial argument we’re completing and the positions where it starts and ends in the current line of input will be passed as arguments automatically when we press tab
{
    //rl_attempted_completion_over = 1;
    char **match_list = nullptr;

    // Autocomplete commands or file/directory names
    match_list = rl_completion_matches(input, generator_function);  //The generator function is called repeatedly from rl_completion_matches(), returning a string each time
    // This function, in turn, repeatedly calls the function pointer given as its second argument (in your case, command_generator) until that function returns nullptr, signaling there are no more completions.

    return match_list;
    //match_list is a point to a array where each entry points to a string
}

char* generator_function(const char* input, int state) 
{
     vector<std::string> listt;
     size_t list_index = 0;

    if (state == 0) {
        // If this is a new word to complete, initialize now.
        listt.clear();
        list_index = 0;

        // Collect a list of matches from current directory
        std::string text(input);
        for (auto v : std::filesystem::directory_iterator(".")) //. represent current directory
        {
            // v points to directory entry (not a string)
            if (v.path().filename().string().find(text) == 0) 
            {
                listt.push_back(v.path().filename().string());
            }
        }
    }

    if (list_index >= listt.size()) 
    {
        return nullptr;
    } else {
        return strdup(listt[list_index++].c_str());
        //strdup is a function that duplicates a string by allocating memory for a new string and copying the contents of the original string into it. It takes a const char* as an argument and returns a pointer to the duplicated string
    }
}
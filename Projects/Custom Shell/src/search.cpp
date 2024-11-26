#include "header.h"
#include "search.h"
#include "utility.h"
using namespace std;

bool search(string &command)
{
    command = command.substr(7);
    command = trim(command);
    //cout<<"search: "<<command<<endl;

    bool result = searchit(filesystem::current_path(), command);
    cout << (result ? "True" : "False") << endl;
    return true;

}

bool searchit(const filesystem::path& start_dir, string& input) 
{
    // checking if file or folder exist in current directory
    if (start_dir.filename() == input) {
        return true;
    }

    // if no then searching recursively inside current directory 
    if (filesystem::is_directory(start_dir)) 
    {
        for (const auto& inside : filesystem::directory_iterator(start_dir)) 
        {
            if (searchit(inside.path(), input)) return true;  // got it somewhere inside
        }
    }

    // not found 
    return false;
}

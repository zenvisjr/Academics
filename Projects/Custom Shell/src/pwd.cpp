#include "header.h"
#include "pwd.h"

using namespace std;

bool pwd(string& command)
{
    getcwd(curr_dir, sizeof(curr_dir));
    if(curr_dir == nullptr)
    {
        cerr <<"Unable to fetch current directory"<<endl;
        return false;
    }

    cout<<curr_dir<<endl;
    return true;
}

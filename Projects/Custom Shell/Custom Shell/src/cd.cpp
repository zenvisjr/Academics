#include "header.h"
#include "cd.h"
#include "utility.h"

using namespace std;

bool cd(std::string &command)
{
    string path;
    if(command.size() == 2)
        {
            path = home;
        }
        else
        {
            path = command.substr(3);
            path = trim(path);
        }
        //cout<<"hi"<<endl;
        
        if(path == "~")
        {
            path = home;
        }

        if(path == "." )
        {
            path = curr_dir;
        }

        if(path == "-")
        {
            path = prev_dir;
        }
        prev_dir = curr_dir;

        int i = chdir(path.c_str());                                     //chdir() changes the current working directory of the calling process to the directory specified in path
        if(i!=0)
        {
            cerr<<"Unable to change current path"<<endl;
            return false;
        }
    
        getcwd(curr_dir, sizeof(curr_dir)); 
        //cout<<curr_dir<<endl;  
        //cout<<home<<endl;           
        if(curr_dir == nullptr)
        {
            cerr <<"Unable to fetch current directory"<<endl;
            return false;
        }

        if(strncmp(curr_dir, home.c_str(), home.size())==0)
        {
            current_directory = "~" + string(curr_dir+home.size());
            //cout<<"~ wali "<<current_directory<<endl;
        }
        else
        {
            //string home = curr_dir;
            //current_directory = curr_dir;
            current_directory = (strcmp(curr_dir, home.c_str())==0)? "~": curr_dir;
        }   
        //cout<<current_directory<<endl;
        //cout<<username<<"@"<<hostname<<":"<<current_directory<<"> ";
        return true;
}
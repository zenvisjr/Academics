#include "header.h"
#include "process_info.h"
#include "utility.h"

using namespace std::filesystem;
using namespace std;

bool process_info(string& command)
{
    if(command.length() == 5) 
    {
        int pid = getpid();
        retrieve_pinfo(pid);
        return true;
    }
    else 
    {
        command = command.substr(5);
        command = trim(command);
        retrieve_pinfo(stoi(command));
        return true;
    }
}

bool retrieve_pinfo(int pid)
{
    pid_t pgid = tcgetpgrp(STDIN_FILENO);
    //cout<<pgid<<endl;

    //getting exectutable path
    string exec_path = "/proc/" + to_string(pid) + "/exe";
    //cout<<exec_path<<endl;
    char real_path[500];
    if(realpath(exec_path.c_str(), real_path) == NULL)
    {
        perror("Unable to retrieve executable path");
        return false;
    }

    //getting process status
    string status_path = "/proc/" + to_string(pid) + "/status";
    //cout<<status_path<<endl;
    ifstream sp(status_path);             //input file stream 
    string status;
    while(getline(sp, status))
    {
        if(status.substr(0,6) == "State:")
        {
            
            status = status.substr(6);
            status = trim(status);
            if(pgid == pid)
            {
                status.insert(1, "+");
            }
            break;
        }
    }

    //getting memory information
    string mem_path = "/proc/" + to_string(pid) + "/statm";
    //cout<<mem_path<<endl;
    ifstream m(mem_path);             //input file stream 
    string memory;
    getline(m, memory, ' ');

    cout<<"pid -- "<<pid<<endl;
    cout<<"Process Status -- "<<status<<endl;
    cout<<"Memory -- "<<memory<<" {Virtual Memory}"<<endl;
    cout<<"Executable path -- "<<real_path<<endl;

    return true;
}
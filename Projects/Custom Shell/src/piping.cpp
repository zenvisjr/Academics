#include "header.h"
#include "piping.h"
#include "utility.h"
#include "exec.h"

using namespace std;


bool piping(vector<string>& command)
{
    //cout<<"ebtering piping"<<endl;
    vector<pid_t> pid;
    int pip[2];
    int fd=0;
    //string sep = "|";
    string check = find_separator(command);
    if(check == "<")
    {
        pair<vector<string>, vector<string>> com = extract_pipe(command);
        //cout<<(com.second[0])<<endl;
        print(com.first);
        print(com.second);
        fd = open(com.second[0].c_str(), O_RDONLY);
        //cout<<fd<<endl;
        if(fd== -1)
        {
            perror("file do not exist");
            exit(EXIT_FAILURE);
        }
        command = com.second;
        command.erase(command.begin(), command.begin() + 2);
        print(command);

    }
    while(true)
    {
        string check = find_separator(command);
        pair<vector<string>, vector<string>> com = extract_pipe(command);

    //int pip[2] is an array of two integers that will hold the file descriptors for the read end (pipefd[0]) and the write end (pipefd[1]) of the pipe
        
        pipe(pip);           //A new pipe is created for communication between the current command and the next command in the chain.
        pid_t pid1;
        pid1 = fork();

        if(pid1<0)
        {
            perror("unable to create 1st child process");
            return false;
        }

        if(pid1==0)
        {
                close(pip[0]);
                if(dup2(fd, STDIN_FILENO) == -1)  //You can use STDIN_FILENO when you want to redirect input from a different source, such as a file or another process.
                {
                    perror("unable to redirect input from standard input e.i terminal screen");
                    exit(EXIT_FAILURE);
                    return false;
                }
                close(fd);
            if(!com.second.empty())
            {
                if(check == ">" || check == ">>")
                {
                    
                    int fd;
                    vector<string> temp = com.second;
                    //cout<<"hy1"<<endl;
                    //print(com.first);
                    //cout<<"hy2"<<endl;
                    
                    //print(temp);
                    //cout<<temp[0]<<endl;
                    if(check == ">") fd = open(temp[0].c_str(), O_CREAT | O_WRONLY  | O_TRUNC, 0644);
                    else fd = open(temp[0].c_str(), O_WRONLY  | O_APPEND);
                    //cout<<fd<<endl;
                    if(fd== -1)
                    {
                        perror("unable to open file");
                        exit(EXIT_FAILURE);
                    }
                    //int ofd;
                    //ofd = dup(STDOUT_FILENO);
                    if(dup2(fd, STDOUT_FILENO) == -1)
                    {
                        perror("unable to write on output file");
                        exit(EXIT_FAILURE);
                    }

                }
                else
                {
                    if(dup2(pip[1], STDOUT_FILENO) == -1) //You can use STDOUT_FILENO when you want to redirect output to a different destination, such as a file or a pipe.
                    {
                        perror("unable to redirect output to pipe");
                        exit(EXIT_FAILURE);
                        return false;
                    }
                }
                
                close(pip[1]);   //Close the write-end of the pipe after redirection to signal the next command that there's no more data when the current command finishes execution
            }
            
            //cout<<"after dup"<<endl;
            call_exec(com.first);
            exit(0);
        }
        else
        {
            if(pid1>0)
            {
                if(fd !=0) close(fd);

                close(pip[1]);
                fd = pip[0];


                pid.push_back(pid1);

                if(com.second.empty())
                {
                    //call_exec(com.first);
                    break;
                }
                
               command = com.second;
            }
           
        }
     }
        //closing file descriptors of pipe in parent process (not necessary but good practice)
        
        //waiting for child process 1 and 2 to terminate
        //waitpid(pid1, NULL, 0);
        //waitpid(pid2, NULL, 0);
        for(auto v: pid)
        {
            waitpid(v, NULL, 0);
        }
        return true;
    
}

pair<vector<string>, vector<string>> extract_pipe(vector<string>& arguments)
{
    //print(arguments);
    vector<string> command1;
    vector<string> command2;
    string sep1 = "|";
    string sep2 = ">";
    string sep3 = ">>";
    string sep4 = "<";
    // pair<vector<string>, vector<string> > = com_pair;
    // com_pair.first = command1;
    // com_pair.first = command2;
    bool find_sep = false;
    

    for(auto v : arguments)
    {
        if((v == sep1 || v == sep2 || v == sep3 || v == sep4) && find_sep == false) 
        {
            find_sep = true;
            continue;
        }
        if(find_sep == false)
        {
            //cout<<"1"<<endl;
            command1.push_back(v);
            //com += " ";
            //cout<<"2"<<endl;
        }
        else
        {
            command2.push_back(v);
            //output += " ";
        }
        
    }
    //print(command1);
    //print(command2);
    return make_pair(command1, command2);
}



#include "header.h"
#include "exec.h"
#include "utility.h"

void call_exec(std::vector<std::string> arguments)
{
    int length = arguments.size();
        char ** args = new char*[length+1];
        //args[0] = string_to_Cstyle(command);
        for(int i=0; i<length; i++)
        {
            // string temp = arguments[i];
            // if(temp.front() == '\"' || temp.back() == '\"' || temp.front() == '\'' || temp.back() == '\'')
            // {
            //     //string temp = arguments[i];
            //     temp = temp.substr(1, temp.length()-2);
            //     //arguments[i] = temp;
            //     cout<<temp<<endl;
            // }
            args[i] = string_to_Cstyle(arguments[i]);
        }
        args[length] = NULL;
        //cout<<"before exec"<<endl;
        int i = execvp(args[0], args);
        //cout<<"after exec"<<endl;
        if(i==-1)
        {
            perror("exec cant be executed");
            exit(EXIT_FAILURE);
        }
       
      
        delete[] args;
}

#include "header.h"
#include "background.h"
#include "exec.h"
using namespace std;

void background(std::vector<std::string>& arguments)
{
    pid_t pid = fork();

    if(pid == -1)
    {
        perror("ERROR in creating child process");
    }
    else if(pid == 0)
    {

        // call_exec(arguments);//cout<<"child: "<<pid<<endl;              

         // Child process
        // Convert std::vector<std::string> to char* array for execvp
        std::vector<char*> args;
        for (auto& arg : arguments)
        {
            args.push_back(&arg[0]); // Get pointer to the underlying string data
        }
        args.push_back(nullptr); // Null-terminate the argument list

        // Execute the program
        execvp(args[0], args.data());
        
        // If execvp returns, it means there was an error
        perror("execvp failed");
        exit(1);
        
    }
    else 
    {
        std::cout<<"["<<pid<<"]"<<endl;
        //int status;
        //waitpid(pid, &status, WUNTRACED);   //Also return if a child has stopped
    }
}

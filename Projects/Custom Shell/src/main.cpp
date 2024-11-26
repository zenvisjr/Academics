#include "header.h"
#include "autocomplete.h"
#include "background.h"
#include "cd.h"
#include "echo.h"
#include "exec.h"
#include "file_permission.h"
#include "foreground.h"
#include "header.h"
#include "history.h"
#include "ls.h"
#include "piping.h"
#include "process_info.h"
#include "pwd.h"
#include "redirection.h"
#include "search.h"
#include "signals.h"
#include "utility.h"

using namespace std;

bool echo( std::string& command)
{
    string text;
    if(command.size() == 4)
    {
        cout<<endl;
        return true;
    }
    else if(command.substr(0, 5) == "echo ")
    {
        text = command.substr(5);
        text = trim(text);
        /*if (text.front() == '"' && text.back() == '"') 
        {
            text = text.substr(1, text.length() - 2);
        }
        else if (text.front() == '\'' && text.back() == '\'') 
        {
            text = text.substr(1, text.length() - 2);
        }*/
        //cout<<"echoooooo"<<endl;
        cout<<text<<endl;
        return true;
    }
    else return false;
}


char curr_dir[500];            // Declare the global variable
string home;
string current_directory;
string prev_dir;
vector<string> history;

int main()
{   cout<<"compiled"<<endl;
    //extracting username
    char *username = getenv("USER");                        //getenv() function returns a pointer to the value  in  the  environment, or NULL if there is no match
    if(username == nullptr)
    {
        cerr <<"Unable to fetch username"<<endl;
        return 1;
    }

    //extracting hostname
    char hostname[500];                                  //gethostname() returns the null-terminated hostname in the character array hostname, return 0 on success, -1 on error
    if(gethostname(hostname, sizeof(hostname)) == -1)
    {
        cerr <<"Unable to fetch hostname"<<endl;
        return 1;
    }

    ///extracting current directory
    getcwd(curr_dir, sizeof(curr_dir));                  //getcwd() return a null-terminated string containing an absolute pathname that is the current working directory of the calling process.
    if(curr_dir == nullptr)
    {
        cerr <<"Unable to fetch current directory"<<endl;
        return 1;
    }
    //cout<<curr_dir<<endl;

    //checking if current directory is home directory
    char *h = getenv("HOME");                     
    if(h == nullptr)
    {
        cerr <<"Unable to fetch home"<<endl;
        return 1;
    }
    
    home = curr_dir;
    prev_dir = curr_dir;
    //cout<<prev_dir<<endl;
    current_directory = (curr_dir == home)? "~": curr_dir;
    
    rl_attempted_completion_function = auto_complete; // This is a pointer to a function provided by the readline library and we are paing address of our custom made function 
    signal(SIGINT, SIG_IGN);  
    signal(SIGTSTP, SIG_IGN);
    signal(SIGQUIT, ctrlD);
    //signal(SIGCHLD, handle_sigchld);

    hist_read();
    
    while(true)
    {
        //cout<<username<<"@"<<hostname<<":"<<current_directory<<"> ";

        //string input;
        //getline(cin, input);

        char* line = readline((username + string("@") + hostname + string(":") + current_directory + string("> ")).c_str());
        // If the user presses Ctrl-D (EOF), readline returns a nullptr
       //cout<<"hyy22"<<endl;
        if (line == nullptr) 
        {  raise(SIGQUIT);
            break;
        }
        string input(line);
        //free(in);  // Free the allocated memory by readline

        // Add to history if not empty
        if (!input.empty()) 
        {
            add_history(input.c_str()); //add_history is a function from the readline library and accepts c style string (char*) as its arguments
        }
        char * a = string_to_Cstyle(input);

        //char *a = new char[input.length()+1];
        //strcpy(a, input.c_str());
        char * in = strtok(a, ";");
        while(in)
        {
            //cout<<in<<endl;
            string command(in);
            command = trim_both(command);
            history.push_back(command);

            //cout<<command<<endl;

            vector<string> arguments;
            tokenize_string(arguments, command);
            if(arguments.back() == "&")
            {
                arguments.pop_back();
                background(arguments);
                
            }
            else 
            {
                //string find = ">";
                string separator = find_separator(arguments);
                vector<string> com;
                vector<string> output;
                extract(arguments, separator, com, output);
                string separator2 = find_separator(output);

                if(separator == "|" || (separator == "<" && separator2 == "|"))
                {
                    //cout<<"entring pipe"<<endl;
                    piping(arguments);
                }
                else if(!separator.empty())
                {
                    //cout<<command<<endl;
                    vector<string> com;
                    vector<string> output;
                    
                    extract(arguments, separator, com, output);
                    // cout<<"printing command"<<endl;
                    // print(com);
                    // cout<<"printing arguments"<<endl;
                    // print(output);
                    
                    //checking if another separator exist
                    string separator2 = find_separator(output);
                    //cout<<"separator2: "<<separator2<<endl;
                    if(!separator2.empty())
                    {
                        //cout<<command<<endl;
                        vector<string> output1;
                        vector<string> output2;
                        
                        extract(output, separator2, output1, output2);
                        // cout<<"printing output1"<<endl;
                        // print(output1);
                        // cout<<"printing output2"<<endl;
                        // print(output2);

                        
                    
                        //cout << "command: " << com<< endl;
                        //cout << "file: " << output << endl;
                        //cout<<"hyy"<<endl;
                        
                        if(separator == "<" && (separator2 == ">"|| separator2 == ">>"))
                        {
                            //cout<<"input_output"<<endl;
                            input_output_redirection(com, separator2, output1, output2);
                        }
                    }
                    else
                    {
                    
                        if(separator == ">" || separator == ">>")
                        {
                            
                            output_redirection(com, separator, output);
                        }
                        
                        if(separator == "<")
                        {
                            input_redirection(com, output);
                        }
                        
                        // if(separator == "|")
                        // {
                        //     cout<<"entring pipe"<<endl;
                        //     piping(com, output);
                        // }
                    }
                }

                else if(command.substr(0,2) == "cd")
                {
                    int i = cd(command);
                    if(i==0)
                    {
                        cerr <<"unable to process cd command"<<endl;
                    }
                }

                else if(command.substr(0,2) == "ls")
                {
                    int i = list(command);
                if(i==0)
                    {
                        cerr <<"unable to process ls command"<<endl;
                    }
                }

                else if(command == "pwd")
                {
                    int i = pwd(command);
                    if(i==0)
                    {
                        cerr <<"unable to process pwd command"<<endl;
                    }
                }

                else if(command.substr(0,4) == "echo")
                {
                    int i = echo(command);
                    if(i==0)
                    {
                        cerr <<"unable to process echo command"<<endl;
                    }
                }
                
                else if(command.substr(0,6) == "search")
                {
                    //cout<<"hyyyy"<<endl;
                    int i = search(command);
                    if(i==0)
                    {
                        cerr <<"unable to process echo command"<<endl;
                    }
                }

                else if(command.substr(0,5) == "pinfo")
                {
                    //cout<<"hyyyy"<<endl;
                    int i = process_info(command);
                    if(i==0)
                    {
                        cerr <<"unable to process pinfo command"<<endl;
                    }
                }
                else if(command.substr(0,7) == "history")
                {
                    if(command.length() == 7)
                    {
                        int i = hist_retrieve();
                        if(i==0)
                        {
                            cerr <<"unable to process history command"<<endl;
                        }
                    }
                    else
                    {
                        command = command.substr(8);
                        int num = stoi(command);
                        //cout<<num<<endl;
                        int i = hist_retrieve_num(num);
                        if(i==0)
                        {
                            cerr <<"unable to process history command"<<endl;
                        }

                    }   
                }
                else 
                {
                    foreground(arguments);
                }
            }

           // cout<<"printing arguments"<<endl;
            //print(arguments);

            in = strtok(NULL, ";");
        }
    
    }
    hist_save(); 
}
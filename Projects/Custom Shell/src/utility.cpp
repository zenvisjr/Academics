#include "header.h"
#include "utility.h"
using namespace std;

char* string_to_Cstyle(string &input)
{
    char *a = new char[input.length()+1];
    strcpy(a, input.c_str());
    return a;

}

string trim(string &input)
{
    int s = input.find_first_not_of(" \t");
    input = input.substr(s);
    return input;
}

string trim_both(string& command)
{
    size_t s = command.find_first_not_of(" \t");
    size_t e = command.find_last_not_of(" \t");

    if(s != string::npos && e != string::npos)
    {
        command = command.substr(s, e-s+1);
    }
    else
    {
        cout<<"not a valid commamd"<<endl;
    }
    return command;
}

void tokenize_string(vector<string>& arguments, string& command)
{
    string arg;
                
    bool sq = false, dq= false;
    
    for(char v: command) 
    {
        if(v == '\'') 
        {
            sq = !sq; 
        } 
        else if(v == '\"') 
        {
            dq = !dq; 
        } 
        else if(v == ' ' && !sq && !dq) 
        {
            if(!arg.empty()) 
            {
                arguments.push_back(arg);
                arg.clear();
            }
        } 
        else 
        {
            arg += v;
        }
    }

    // Push the last command
    if(!arg.empty()) 
    {
        arguments.push_back(arg);
    }
    //print(arguments);
}

string find_separator(vector<string>& arguments) 
{
    // Define a list of possible separators
    vector<string> sep = {">", "<", ">>", "|"};

    for (auto v : arguments) 
    {
        if (find(sep.begin(), sep.end(), v) != sep.end()) 
        {
            return v;  // Return the first separator found
        }
    }

    return "";  // Return an empty string if no separator is found
}

void print(vector<string> list)
{
    for (auto args : list)
    {
    cout << "Argument: " << args << endl;
    }
    cout<<endl;
}

void extract(vector<string>& arguments, string &separator, vector<string>& com, vector<string>& output)
{

    bool find_sep = false;

    for(auto v : arguments)
    {
        if(v == separator) find_sep = true;
        else
        {
            if(find_sep == false)
            {
                com.push_back(v);
                //com += " ";

            }
            else
            {
                output.push_back(v);
                //output += " ";
            }
        }
    }
}





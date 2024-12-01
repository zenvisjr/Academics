#include "header.h"
#include "ls.h"
#include "file_permission.h"
#include "utility.h"

using namespace std;
using namespace std::filesystem;

bool list(string &command)
{
    if(command.length() == 2) 
    {
        ls();
        return true;
    }
    else 
    {
        command = command.substr(3);
        command = trim(command);
        vector<string> res;
        istringstream yo(command);
        string arg;
        string temp;

        while (yo >> arg) 
        {
            if (arg == "-a" || arg == "-l") 
            {
                if (!temp.empty()) 
                {
                    temp += " ";
                }
                temp += arg;
            } 
            else 
            {
                if (!temp.empty()) 
                {
                    res.push_back(temp);
                    temp.clear();
                }
                res.push_back(arg);
            }
        }

        // Handle any remaining flags
        if (!temp.empty()) 
        {
            res.push_back(temp);
        }

        //print(res);
        int size = res.size();
        //cout<<size<<endl;
        
        if(size == 1)
        {
            if(res[0] == "-a")  ls_a();

            else if(res[0] == "-l")  ls_l();
            
            else if(res[0] == ".")  ls_curr();

            else if(res[0] == "..")  ls_prev();

            else if(res[0] == "~")  ls_home();

            else if(res[0] == "-a -l")  ls_a_l();

            else if(res[0] == "-al" || res[0] == "-la" )  ls_a_l();

            else ls_with_dir(res[0]);
        }
        else if(size == 2)
        {
            if(res[0] == "-a")  ls_a_with_dir(res[1]);

            else if(res[0] == "-l")  ls_l_with_dir(res[1]);

            else if(res[0] == "-a -l" || res[0] == "-al" || res[0] == "-la" )  ls_a_l_with_dir(res[1]);

            else 
            {
                
                cout<<res[0]<<":"<<endl;
                cout<<endl;
                ls_with_dir(res[0]);
                cout<<endl;
                cout<<res[1]<<":"<<endl;
                cout<<endl;
                ls_with_dir(res[1]);
            }
        }
        else
        {
            cout<<"entering inside else"<<endl;
            int i=0;
            bool flag2 = false;
            string sym;
            while(i<size)
            {
                bool flag = false;
                
                

                if(res[i] == "-a")  
                { 
                    cout<<endl;
                    cout<<res[i+1]<<":"<<endl; 
                    cout<<endl;
                    ls_a_with_dir(res[i+1]); 
                    flag = true; 
                    flag2 = true;
                    sym = res[i];
                }

                else if(res[i] == "-l")  
                { 
                    cout<<endl;
                    cout<<res[i+1]<<":"<<endl;
                    cout<<endl;
                    ls_l_with_dir(res[i+1]); 
                    flag = true; 
                    flag2 = true;
                    sym = res[i];
                }
                
                else if(res[i] == "-a -l" || res[i] == "-al" || res[i] == "-la" ) 
                { 
                    cout<<endl;
                    cout<<res[i+1]<<":"<<endl; 
                    cout<<endl;
                    ls_a_l_with_dir(res[i+1]); 
                    flag = true; 
                    flag2 = true;
                    sym = res[i];
                }

                else
                {
                    if(flag2 == false)
                    {
                        cout<<endl;
                        cout<<res[i]<<":"<<endl;
                        cout<<endl;
                        ls_with_dir(res[i]);
                    }
                    else
                    {
                        if(sym == "-a")
                        {
                            cout<<endl;
                            cout<<res[i]<<":"<<endl; 
                            cout<<endl;
                            ls_a_with_dir(res[i]);
                        }
                        if(sym == "-l")
                        {
                            cout<<endl;
                            cout<<res[i]<<":"<<endl; 
                            cout<<endl;
                            ls_l_with_dir(res[i]);
                        }
                        if(sym == "-al" || sym == "-la" ||sym == "-a -l")
                        {
                            cout<<endl;
                            cout<<res[i]<<":"<<endl; 
                            cout<<endl;
                            ls_a_l_with_dir(res[i]);
                        }
                    }
                    
                    
                }
                
                if(flag == true) i = i+2;
                else i++;
            }
            
        }
        

        // command = command.substr(3);
        // command = trim(command);
     
        // if(command == "-a")  ls_a();

        // else if(command == "-l")  ls_l();
        
        // else if(command == ".")  ls_curr();

        // else if(command == "..")  ls_prev();

        // else if(command == "~")  ls_home();

        // else if(command == "-a -l")  ls_a_l();

        // else if(command == "-al" || command == "-la" )  ls_a_l();

        // else if(command.substr(0,5) == "-a -l" && command.length()>5)
        // {
        //     cout<<"1 "<<command<<endl;
        //     command = command.substr(6);
            
        //     command = trim(command);
        //     cout<<"2 "<<command<<endl;
        //     ls_a_l_with_dir(command);
        // }

        // else if(command.substr(0,2) == "-a" && command.substr(2,1) == " " && command.substr(3,2) != "-l" && command.length()>2)
        // {
            
        //     cout<<"bhai ya"<<endl;
        //     command = command.substr(3);
        //     command = trim(command);
        //     ls_a_with_dir(command);
        // }

        // else if(command.substr(0,2) == "-l" && command.substr(2,1) == " " && command.substr(3,2) != "-a" &&  command.length()>2)
        // {
        //     command = command.substr(3);
        //     command = trim(command);
        //     ls_l_with_dir(command);
        // }

         
        // else if((command.substr(0,3) == "-la" || command.substr(0,3) == "-al") && command.length()>3)
        // {
        //     cout<<"4 "<<command<<endl;
        //     command = command.substr(4);
        //     command = trim(command);
        //     cout<<"5 "<<command<<endl;
        //     ls_a_l_with_dir(command);
        // }
        
        // else
        // {
        //     ls_with_dir(command);
        // }
    }
    return true;
}

bool ls()
{
    DIR *d;                       //DIR represent directory stream
    struct dirent *dir;           //it represent a single entry in a directory and store various information about that entry (file)
    //cout<<current_directory<<endl;
    d = opendir(curr_dir);
    if( d == nullptr)                                  //The  opendir()  function  opens a directory stream corresponding to the directory name, and returns a pointer to  the  directory  stream. The stream is positioned at the first entry in the directory
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;
        cout<<dir->d_name<<endl;
    }
    return true;
}

bool ls_with_dir(string& path)
{
  
    struct stat check;

    int i= stat(path.c_str(), &check);
    if (i==0)
    {
        if(check.st_mode & S_IFDIR)
        {
            DIR *d;                       //DIR represent directory stream
            struct dirent *dir;           //it represent a single entry in a directory and store various information about that entry (file)
            //cout<<current_directory<<endl;
            d = opendir(path.c_str());
            if( d == nullptr)                                  //The  opendir()  function  opens a directory stream corresponding to the directory name, and returns a pointer to  the  directory  stream. The stream is positioned at the first entry in the directory
            {
                perror("directory cannot be opened: ERRORRR");
                return false;
            }
            while((dir = readdir(d)) != nullptr )
            {
                string name = dir->d_name;
                if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;
                cout<<dir->d_name<<endl;
            }
            return true;
        }
        else
        {
            int point = path.find_last_of("/");
            string file_name = path.substr(point+1);
            cout<<file_name<<endl;
            return true;
        }
        
    }
    else
    {
        perror("invalid path: path do not exist:");
        return false;
    }
    
    
}
bool ls_curr()
{
    DIR *d;                       //DIR represent directory stream
    struct dirent *dir;           //it represent a single entry in a directory and store various information about that entry (file)
    //cout<<current_directory<<endl;
    d = opendir(curr_dir);
    if( d == nullptr)                                  //The  opendir()  function  opens a directory stream corresponding to the directory name, and returns a pointer to  the  directory  stream. The stream is positioned at the first entry in the directory
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        //if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;
        cout<<dir->d_name<<endl;
    }
    return true;
}

bool ls_home()
{
    DIR *d;                       //DIR represent directory stream
    struct dirent *dir;           //it represent a single entry in a directory and store various information about that entry (file)
    //cout<<current_directory<<endl;
    d = opendir(home.c_str());
    if( d == nullptr)                                  //The  opendir()  function  opens a directory stream corresponding to the directory name, and returns a pointer to  the  directory  stream. The stream is positioned at the first entry in the directory
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        //if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;
        cout<<dir->d_name<<endl;
    }
    return true;
}

bool ls_prev()
{
    DIR *d;                       //DIR represent directory stream
    struct dirent *dir;           //it represent a single entry in a directory and store various information about that entry (file)
    //cout<<current_directory<<endl;


    string prev = curr_dir;
    //cout<<prev<<endl;
    int e = prev.find_last_of("/");
    prev = prev.substr(0, e);
    //cout<<s<<endl;
    //cout<<e<<endl;
    //int z = e-s+1;
    //cout<<prev<<endl;
    //cout<<z<<endl;

    d = opendir(prev.c_str());
    if( d == nullptr)                                  //The  opendir()  function  opens a directory stream corresponding to the directory name, and returns a pointer to  the  directory  stream. The stream is positioned at the first entry in the directory
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;
        cout<<dir->d_name<<endl;
    }
    return true;
}


bool ls_a()
{
    DIR *d;                       
    struct dirent *dir;           
    d = opendir(curr_dir);
    if( d == nullptr)                            
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        //if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) continue;
        cout<<dir->d_name<<endl;
    }
    return true;
}

bool ls_a_with_dir(string &path)
{
    struct stat check;

    int i= stat(path.c_str(), &check);
    if (i==0)
    {
        if(check.st_mode & S_IFDIR)
        {
            DIR *d;                       
            struct dirent *dir;           
            d = opendir(path.c_str());
            if( d == nullptr)                            
            {
                perror("directory cannot be opened: ERRORRR");
                return false;
            }
            while((dir = readdir(d)) != nullptr )
            {
                //if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) continue;
                cout<<dir->d_name<<endl;
            }
            return true;
        }
        else
        {
            int point = path.find_last_of("/");
            string file_name = path.substr(point+1);
            cout<<file_name<<endl;
            return true;
        }
        
    }
    else
    {
        perror("invalid path: path do not exist:");
        return false;
    }

//     FILE* file = fopen(command.c_str(), "r");
//    //cout<<"hy"<<endl;
//     if(file == NULL)
//     {
//      perror("unable to open file due to some failure");
//      //return 0;
//     }

    
}


bool ls_l()
{
    //cout<<"entering ls -l"<<endl;
    DIR *d;                       
    struct dirent *dir; 
    struct stat status;
    if(stat(curr_dir, &status) == -1)
    {
        perror("unable to retrieve stat information");
    }          
    d = opendir(curr_dir);
    if( d == nullptr)                            
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;

        string path;
        path = string(curr_dir) + "/" + name;

        if(stat(path.c_str(), &status) == -1)
    {
        perror("unable to retrieve stat information");
        continue;
    }   

        cout << file_permission(status.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
        cout << status.st_nlink << " ";
        // cout << getpwuid(status.st_uid)->pw_name << " ";
        cout << getgrgid(status.st_uid)->gr_name << " ";
        cout << setw(8) << to_string(status.st_size) << " ";
        string time = ctime(&status.st_mtime);
        time = time.substr(4, 12);      //remove new line
        cout << time <<" ";
        cout<<dir->d_name<<endl;
    }
    return true;
}


bool ls_a_l()
{
    //<<"entering detail"<<endl;
    DIR *d;                       
    struct dirent *dir; 
    struct stat status;
        
    d = opendir(curr_dir);
    if( d == nullptr)                            
    {
        perror("directory cannot be opened: ERRORRR");
        return false;
    }
    while((dir = readdir(d)) != nullptr )
    {
        string name = dir->d_name;
        //if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;

        string path;
        path = string(curr_dir) + "/" + name;

        if(stat(path.c_str(), &status) == -1)
    {
        perror("unable to retrieve stat information");
        continue;
    }   

        cout << file_permission(status.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
        cout << setw(2) << status.st_nlink << " ";
        // cout << getpwuid(status.st_uid)->pw_name << " ";
        cout << getgrgid(status.st_uid)->gr_name << " ";
        cout << setw(8) << to_string(status.st_size) << " ";
        string time = ctime(&status.st_mtime);
        time = time.substr(4, 12);        //remove new line
        cout << time <<" ";
        cout<<dir->d_name<<endl;
    }
    return true;
}


bool ls_a_l_with_dir(string& command)
{



    struct stat check;

    int i= stat(command.c_str(), &check);
    if (i==0)
    {
        if(check.st_mode & S_IFDIR)
        {
            DIR *d;                       
            struct dirent *dir; 
            struct stat status;
                
            d = opendir(command.c_str());
            if( d == nullptr)                            
            {
                perror("directory cannot be opened: ERRORRR");
                return false;
            }
            while((dir = readdir(d)) != nullptr )
            {
                string name = dir->d_name;
               // if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;

                string path;
                path = command + "/" + name;

                if(stat(path.c_str(), &status) == -1)
            {
                perror("unable to retrieve stat information");
                continue;
            }   

                cout << file_permission(status.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
                cout << setw(3) << status.st_nlink << " ";
                // cout << getpwuid(status.st_uid)->pw_name << " ";
                cout << getgrgid(status.st_uid)->gr_name << " ";
                cout << setw(6) << to_string(status.st_size) << " ";
                string time = ctime(&status.st_mtime);
                time = time.substr(4, 12);        //remove new line
                cout << time <<" ";
                cout<<dir->d_name<<endl;
            }
            return true;
        }
        else if (check.st_mode & S_IFREG)
        {
            //int point = command.find_last_of("/");
            //string file_name = command.substr(point+1);

            cout << file_permission(check.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
            cout << setw(2) << check.st_nlink << " ";
            // cout << getpwuid(check.st_uid)->pw_name << " ";
            cout << getgrgid(check.st_uid)->gr_name << " ";
            cout << setw(6) << to_string(check.st_size) << " ";
            string time = ctime(&check.st_mtime);
            time = time.substr(4, 12);        //remove new line
            cout << time <<" ";
            cout<<command<<endl;

            return true;
        } 
    }
    else
    {
        perror("invalid path: path do not exist:");
        return false;
    }
    return true;
}


bool ls_l_with_dir(string &command)
{
    //cout<<"3 "<<command<<endl;
    
    struct stat check;

    int i= stat(command.c_str(), &check);
    if (i==0)
    {
        if(check.st_mode & S_IFDIR)
        {
            DIR *d;                       
            struct dirent *dir; 
            struct stat status;
                
            d = opendir(command.c_str());
            if( d == nullptr)                            
            {
                perror("directory cannot be opened: ERRORRR");
                return false;
            }
            while((dir = readdir(d)) != nullptr )
            {
                string name = dir->d_name;
                if(strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0 || name.front() == '.') continue;

                string path;
                path = command + "/" + name;

                if(stat(path.c_str(), &status) == -1)
            {
                perror("unable to retrieve stat information");
                continue;
            }   

                cout << file_permission(status.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
                cout << setw(3) << status.st_nlink << " ";
                // cout << getpwuid(status.st_uid)->pw_name << " ";
                cout << getgrgid(status.st_uid)->gr_name << " ";
                cout << setw(8) << to_string(status.st_size) << " ";
                string time = ctime(&status.st_mtime);
                time = time.substr(4, 12);        //remove new line
                cout << time <<" ";
                cout<<dir->d_name<<endl;
            }
            return true;
        }
        else if (check.st_mode & S_IFREG)
        {
            //int point = command.find_last_of("/");
            //string file_name = command.substr(point+1);

            cout << file_permission(check.st_mode)<< " ";   //st_mode contains the file's mode (permissions and file type information)
            cout << setw(2) << check.st_nlink << " ";
            // cout <<getpwuid(check.st_uid)->pw_name << " ";
            cout << getgrgid(check.st_uid)->gr_name << " ";
            cout << setw(8) << to_string(check.st_size) << " ";
            string time = ctime(&check.st_mtime);
            time = time.substr(4, 12);        //remove new line
            cout << time <<" ";
            cout<<command<<endl;

            return true;
        }
        
    }
    else
    {
        perror("invalid path: path do not exist:");
        return false;
    }
    return true;
}




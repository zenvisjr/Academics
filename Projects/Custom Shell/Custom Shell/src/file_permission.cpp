#include "header.h"
#include "file_permission.h"

std::string file_permission(mode_t mode) 
{
    std::string permissions;
    
    // File type
    if (S_ISDIR(mode)) permissions += "d";
    else if (S_ISREG(mode)) permissions += "-";
    else if (S_ISLNK(mode)) permissions += "l";
    else if (S_ISCHR(mode)) permissions += "c";
    else if (S_ISBLK(mode)) permissions += "b";
    else if (S_ISFIFO(mode)) permissions += "p";
    else if (S_ISSOCK(mode)) permissions += "s";

    // User permissions
    permissions += (mode & S_IRUSR) ? "r" : "-";
    permissions += (mode & S_IWUSR) ? "w" : "-";
    permissions += (mode & S_IXUSR) ? "x" : "-";

    // Group permissions
    permissions += (mode & S_IRGRP) ? "r" : "-";
    permissions += (mode & S_IWGRP) ? "w" : "-";
    permissions += (mode & S_IXGRP) ? "x" : "-";

    // Others permissions
    permissions += (mode & S_IROTH) ? "r" : "-";
    permissions += (mode & S_IWOTH) ? "w" : "-";
    permissions += (mode & S_IXOTH) ? "x" : "-";

    return permissions;
}

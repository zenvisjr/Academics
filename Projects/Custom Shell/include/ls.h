#ifndef LS_H
#define LS_H

bool list(std::string &command);
bool ls();
bool ls_a();
bool ls_l();
bool ls_curr();
bool ls_home();
bool ls_prev();
bool ls_a_l();
bool ls_with_dir(std::string& command);
bool ls_l_with_dir(std::string& command);
bool ls_a_with_dir(std::string& command);
bool ls_a_l_with_dir(std::string& command);

#endif

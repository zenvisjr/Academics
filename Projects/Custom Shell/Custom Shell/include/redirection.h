#ifndef REDIRECTION_H
#define REDIRECTION_H

bool output_redirection(std::vector<std::string>& com, std::string& separator, std::vector<std::string>& output);
bool input_redirection(std::vector<std::string>& command, std::vector<std::string>& output);
bool input_output_redirection(std::vector<std::string>&, std::string&, std::vector<std::string>&, std::vector<std::string>&);

#endif

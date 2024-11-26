#ifndef AUTOCOMPLETE_H
#define AUTOCOMPLETE_H

char** auto_complete(const char* text, int start, int end);
char* generator_function(const char* text, int state);

#endif

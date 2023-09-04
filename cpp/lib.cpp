#include <alsa/asoundlib.h>
#include <cstdio>

void foo()
{
    printf("Hello C++!\n");

    printf("ALSA library version: %s\n", snd_asoundlib_version());
}
#include <cstdio>
#include "IApplication.hpp"

using namespace qg;

namespace qg {
    extern IApplication* g_pApp;
}

int main(int argc, char** argv) {
    int ret;

    if ((ret = g_pApp->Initialize()) != 0) {
        printf("App Initialize failed, will exit now.");
        return ret;
    } else printf("ok");

    while (!g_pApp->IsQuit()) {
        g_pApp->Tick();
    }

    g_pApp->Finalize();

    return 0;
}
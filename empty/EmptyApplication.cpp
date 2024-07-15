#include "BaseApplication.hpp"

namespace qg {
    BaseApplication g_App;
    IApplication* g_pApp = &g_App;
}
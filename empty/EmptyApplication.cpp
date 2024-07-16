#include "BaseApplication.hpp"

namespace qg {
    GfxConfiguration config;
	BaseApplication g_App(config);
	IApplication* g_pApp = &g_App;
}

#include "BaseApplication.hpp"
#include <iostream>

using namespace qg;

bool qg::BaseApplication::m_bQuit = false;

qg::BaseApplication::BaseApplication(GfxConfiguration& cfg)
    :m_Config(cfg)
{
}

// Parse command line, read configuration, initialize all sub modules
int qg::BaseApplication::Initialize()
{
    int result = 0;

    std::cout << m_Config;

	return result;
}


// Finalize all sub modules and clean up all runtime temporary files.
void qg::BaseApplication::Finalize()
{
}


// One cycle of the main loop
void qg::BaseApplication::Tick()
{
}

bool qg::BaseApplication::IsQuit()
{
	return m_bQuit;
}
#include "BaseApplication.hpp"

// Parse command line, read configuration, initialize all sub modules
int qg::BaseApplication::Initialize() {
        m_bQuit = false;
        return 0;
}


// Finalize all sub modules and clean up all runtime temporary files.
void qg::BaseApplication::Finalize() {
}


// One cycle of the main loop
void qg::BaseApplication::Tick() {
}

bool qg::BaseApplication::IsQuit() {
    return m_bQuit;
}
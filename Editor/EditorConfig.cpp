#include "GfxConfiguration.h"
#include "EditorLogic.hpp"
#include "QG/QGPhysicsManager.hpp"

namespace qg {
    GfxConfiguration config(8, 8, 8, 8, 24, 8, 0, 960, 540, "GameEngineFromScratch Editor");
    IGameLogic*       g_pGameLogic       = static_cast<IGameLogic*>(new EditorLogic);
    IPhysicsManager*  g_pPhysicsManager  = static_cast<IPhysicsManager*>(new qgPhysicsManager);
}
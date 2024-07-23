#include <iostream>
#include "DebugManager.hpp"
#include "GraphicsManager.hpp"
#include "IPhysicsManager.hpp"
#include "IGameLogic.hpp"

using namespace qg;
using namespace std;

#ifdef DEBUG
int DebugManager::Initialize()
{
    return 0;
}

void DebugManager::Finalize()
{

}

void DebugManager::Tick()
{
    g_pGraphicsManager->ClearDebugBuffers();

    if(m_bDrawDebugInfo)
    {
        DrawDebugInfo();
        g_pPhysicsManager->DrawDebugInfo();
        g_pGameLogic->DrawDebugInfo();
    }
}

void DebugManager::ToggleDebugInfo()
{
    m_bDrawDebugInfo = !m_bDrawDebugInfo;
}

void DebugManager::DrawDebugInfo()
{
    DrawGrid();
    DrawAxis();
}

void DebugManager::DrawAxis()
{
    // x - axis
    Vector3f from (-1000.0f, 0.0f, 0.0f);
    Vector3f to (1000.0f, 0.0f, 0.0f);
    Vector3f color(1.0f, 0.0f, 0.0f);
    g_pGraphicsManager->DrawLine(from, to, color);

    // y - axis
    from.Set(0.0f, -1000.0f, 0.0f);
    to.Set(0.0f, 1000.0f, 0.0f);
    color.Set(0.0f, 1.0f, 0.0f);
    g_pGraphicsManager->DrawLine(from, to, color);

    // z - axis
    from.Set(0.0f, 0.0f, -1000.0f);
    to.Set(0.0f, 0.0f, 1000.0f);
    color.Set(0.0f, 0.0f, 1.0f);
    g_pGraphicsManager->DrawLine(from, to, color);
}

void DebugManager::DrawGrid()
{
    Vector3f color(0.1f, 0.1f, 0.1f);
    PointList grid;

    for (int x = -100; x <= 100; x += 10)
    {
        PointPtr from = make_shared<Point>(x, -100.0f, 0.0f);
        PointPtr to = make_shared<Point>(x, 100.0f, 0.0f);
        grid.push_back(from);
        grid.push_back(to);
    }

    for (int y = -100; y <= 100; y += 10)
    {
        PointPtr from = make_shared<Point>(-100.0f, y, 0.0f);
        PointPtr to = make_shared<Point>(100.0f, y, 0.0f);
        grid.push_back(from);
        grid.push_back(to);
    }

    g_pGraphicsManager->DrawLine(grid, color);
}

#endif
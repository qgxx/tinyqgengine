#include <iostream>
#include "QGPhysicsManager.hpp"
#include "Box.hpp"
#include "Plane.hpp"
#include "Sphere.hpp"
#include "RigidBody.hpp"
#include "GraphicsManager.hpp"

using namespace qg;
using namespace std;

int QGPhysicsManager::Initialize()
{
    cout << "[QGPhysicsManager] Initialize" << endl;
    return 0;
}

void QGPhysicsManager::Finalize()
{
    cout << "[QGPhysicsManager] Finalize" << endl;
    // Clean up
    ClearRigidBodies();
}

void QGPhysicsManager::Tick()
{
    if (g_pSceneManager->IsSceneChanged())
    {
        ClearRigidBodies();
        CreateRigidBodies();
        g_pSceneManager->NotifySceneIsPhysicalSimulationQueued();
    }
    else
    {
        auto& scene = g_pSceneManager->GetSceneForPhysicalSimulation();

        // Geometries
        for (auto _it : scene.GeometryNodes)
        {
            auto pGeometryNode = _it.second;
            if (void* rigidBody = pGeometryNode->RigidBody()) {
                RigidBody* _rigidBody = reinterpret_cast<RigidBody*>(rigidBody);
                auto pGeometry = _rigidBody->GetCollisionShape();
                if (pGeometry->GetGeometryType() == GeometryType::kPolyhydron)
                {
                    dynamic_pointer_cast<ConvexHull>(pGeometry)->Iterate();
                }
            }
        }
    }
}

void QGPhysicsManager::CreateRigidBody(SceneGeometryNode& node, const SceneObjectGeometry& geometry)
{
    const float* param = geometry.CollisionParameters();
    RigidBody* rigidBody = nullptr;

    switch(geometry.CollisionType())
    {
        case SceneObjectCollisionType::kSceneObjectCollisionTypeSphere:
            {
                auto collision_box = make_shared<Sphere>(param[0]);

                const auto trans = node.GetCalculatedTransform();
                auto motionState = 
                    make_shared<MotionState>(
                                *trans 
                            );
                rigidBody = new RigidBody(collision_box, motionState);
            }
            break;
        case SceneObjectCollisionType::kSceneObjectCollisionTypeBox:
            {
                auto collision_box = make_shared<Box>(Vector3f(param[0], param[1], param[2]));

                const auto trans = node.GetCalculatedTransform();
                auto motionState = 
                    make_shared<MotionState>(
                                *trans 
                            );
                rigidBody = new RigidBody(collision_box, motionState);
            }
            break;
        case SceneObjectCollisionType::kSceneObjectCollisionTypePlane:
            {
                auto collision_box = make_shared<Plane>(Vector3f(param[0], param[1], param[2]), param[3]);

                const auto trans = node.GetCalculatedTransform();
                auto motionState = 
                    make_shared<MotionState>(
                                *trans 
                            );
                rigidBody = new RigidBody(collision_box, motionState);
            }
            break;
        default:
            {
                // create collision box using convex hull
                auto bounding_box = geometry.GetBoundingBox();
                auto collision_box = make_shared<ConvexHull>(geometry.GetConvexHull());

                const auto trans = node.GetCalculatedTransform();
                auto motionState = 
                    make_shared<MotionState>(
                                *trans,
                                bounding_box.centroid 
                            );
                rigidBody = new RigidBody(collision_box, motionState);
            }
    }

    node.LinkRigidBody(rigidBody);
}

void QGPhysicsManager::UpdateRigidBodyTransform(SceneGeometryNode& node)
{
    const auto trans = node.GetCalculatedTransform();
    auto rigidBody = node.RigidBody();
    auto motionState = reinterpret_cast<RigidBody*>(rigidBody)->GetMotionState();
    motionState->SetTransition(*trans);
}

void QGPhysicsManager::DeleteRigidBody(SceneGeometryNode& node)
{
    RigidBody* rigidBody = reinterpret_cast<RigidBody*>(node.UnlinkRigidBody());
    if(rigidBody) {
        delete rigidBody;
    }
}

int QGPhysicsManager::CreateRigidBodies()
{
    auto& scene = g_pSceneManager->GetSceneForPhysicalSimulation();

    // Geometries
    for (auto _it : scene.GeometryNodes)
    {
        auto pGeometryNode = _it.second;
        auto pGeometry = scene.GetGeometry(pGeometryNode->GetSceneObjectRef());
        assert(pGeometry);

        CreateRigidBody(*pGeometryNode, *pGeometry);
    }

    return 0;
}

void QGPhysicsManager::ClearRigidBodies()
{
    auto& scene = g_pSceneManager->GetSceneForPhysicalSimulation();

    // Geometries
    for (auto _it : scene.GeometryNodes)
    {
        auto pGeometryNode = _it.second;
        DeleteRigidBody(*pGeometryNode);
    }
}

Matrix4X4f QGPhysicsManager::GetRigidBodyTransform(void* rigidBody)
{
    RigidBody* _rigidBody = reinterpret_cast<RigidBody*>(rigidBody);
    auto motionState = _rigidBody->GetMotionState();
    return motionState->GetTransition();
}

void QGPhysicsManager::ApplyCentralForce(void* rigidBody, Vector3f force)
{

}

#ifdef DEBUG
    void QGPhysicsManager::DrawDebugInfo()
    {
        auto& scene = g_pSceneManager->GetSceneForPhysicalSimulation();

        // Geometries
        for (auto _it : scene.GeometryNodes)
        {
            auto pGeometryNode = _it.second;
            if (void* rigidBody = pGeometryNode->RigidBody()) {
                RigidBody* _rigidBody = reinterpret_cast<RigidBody*>(rigidBody);
                auto motionState = _rigidBody->GetMotionState();
                auto centerOfMass = motionState->GetCenterOfMassOffset();
                auto trans = motionState->GetTransition();
                auto pGeometry = _rigidBody->GetCollisionShape();
                DrawAabb(*pGeometry, trans, centerOfMass);
                DrawShape(*pGeometry, trans, centerOfMass);
            }
        }
    }

    void QGPhysicsManager::DrawAabb(const Geometry& geometry, const Matrix4X4f& trans, const Vector3f& centerOfMass)
    {
        Vector3f bbMin, bbMax;
        Vector3f color(0.7f, 0.6f, 0.5f);

        Matrix4X4f _trans;
        BuildIdentityMatrix(_trans);
        _trans.data[3][0] = centerOfMass.x * trans.data[0][0]; // scale by x-scale
        _trans.data[3][1] = centerOfMass.y * trans.data[1][1]; // scale by y-scale
        _trans.data[3][2] = centerOfMass.z * trans.data[2][2]; // scale by z-scale
        MatrixMultiply(_trans, trans, _trans);

        geometry.GetAabb(_trans, bbMin, bbMax);
        g_pGraphicsManager->DrawBox(bbMin, bbMax, color);
    }

    void QGPhysicsManager::DrawShape(const Geometry& geometry, const Matrix4X4f& trans, const Vector3f& centerOfMass)
    {
        Vector3f color(0.8f, 0.7f, 0.6f);

        Matrix4X4f _trans;
        BuildIdentityMatrix(_trans);
        _trans.data[3][0] = centerOfMass.x * trans.data[0][0]; // scale by x-scale
        _trans.data[3][1] = centerOfMass.y * trans.data[1][1]; // scale by y-scale
        _trans.data[3][2] = centerOfMass.z * trans.data[2][2]; // scale by z-scale
        MatrixMultiply(_trans, trans, _trans);

        if (geometry.GetGeometryType() == GeometryType::kPolyhydron)
        {
            g_pGraphicsManager->DrawPolyhydron(reinterpret_cast<const Polyhedron&>(geometry), trans, color);
        }
    }
#endif
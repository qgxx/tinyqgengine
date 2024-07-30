#include <iostream>
#include "GraphicsManager.hpp"
#include "SceneManager.hpp"
#include "cbuffer.h"
#include "IApplication.hpp"
#include "IPhysicsManager.hpp"
#include "ForwardRenderPass.hpp"
#include "ShadowMapPass.hpp"
#include "HUDPass.hpp"

using namespace qg;
using namespace std;

int GraphicsManager::Initialize()
{
    int result = 0;
    m_Frames.resize(kFrameCount);
	InitConstants();
    m_DrawPasses.push_back(make_shared<ShadowMapPass>());
    m_DrawPasses.push_back(make_shared<ForwardRenderPass>());
    m_DrawPasses.push_back(make_shared<HUDPass>());
    return result;
}

void GraphicsManager::Finalize()
{
#ifdef DEBUG
    ClearDebugBuffers();
#endif
    ClearBuffers();
}

void GraphicsManager::Tick()
{
    if (g_pSceneManager->IsSceneChanged())
    {
        cout << "[GraphicsManager] Detected Scene Change, reinitialize buffers ..." << endl;
        ClearBuffers();
        const Scene& scene = g_pSceneManager->GetSceneForRendering();
        InitializeBuffers(scene);
        g_pSceneManager->NotifySceneIsRenderingQueued();
    }

    UpdateConstants();

    Clear();
    Draw();
}

void GraphicsManager::UpdateConstants()
{
    // update scene object position
    auto& frame = m_Frames[m_nFrameIndex];

    for (auto dbc : frame.batchContexts)
    {
        if (void* rigidBody = dbc->node->RigidBody()) {
            Matrix4X4f trans;

            // the geometry has rigid body bounded, we blend the simlation result here.
            Matrix4X4f simulated_result = g_pPhysicsManager->GetRigidBodyTransform(rigidBody);

            BuildIdentityMatrix(trans);

            // apply the rotation part of the simlation result
            memcpy(trans[0], simulated_result[0], sizeof(float) * 3);
            memcpy(trans[1], simulated_result[1], sizeof(float) * 3);
            memcpy(trans[2], simulated_result[2], sizeof(float) * 3);

            // replace the translation part of the matrix with simlation result directly
            memcpy(trans[3], simulated_result[3], sizeof(float) * 3);

            dbc->trans = trans;
        } else {
            dbc->trans = *dbc->node->GetCalculatedTransform();
        }
    }

    // Generate the view matrix based on the camera's position.
    CalculateCameraMatrix();
    CalculateLights();
}

void GraphicsManager::Clear()
{

}

void GraphicsManager::Draw()
{
    auto& frame = m_Frames[m_nFrameIndex];

    for (auto pDrawPass : m_DrawPasses)
    {
        pDrawPass->Draw(frame);
    }

#ifdef DEBUG
    RenderDebugBuffers();
#endif
}

void GraphicsManager::InitConstants()
{
    // Initialize the world/model matrix to the identity matrix.
    BuildIdentityMatrix(m_Frames[m_nFrameIndex].frameContext.m_worldMatrix);
}

void GraphicsManager::CalculateCameraMatrix()
{
    auto& scene = g_pSceneManager->GetSceneForRendering();
    auto pCameraNode = scene.GetFirstCameraNode();
    DrawFrameContext& frameContext = m_Frames[m_nFrameIndex].frameContext;
    if (pCameraNode) {
        auto transform = *pCameraNode->GetCalculatedTransform();
        InverseMatrix4X4f(transform);
        frameContext.m_viewMatrix = transform;
    }
    else {
        // use default build-in camera
        Vector3f position = { 0.0f, -5.0f, 0.0f }, lookAt = { 0.0f, 0.0f, 0.0f }, up = { 0.0f, 0.0f, 1.0f };
        BuildViewRHMatrix(frameContext.m_viewMatrix, position, lookAt, up);
    }

    float fieldOfView = PI / 3.0f;
    float nearClipDistance = 1.0f;
    float farClipDistance = 100.0f;

    if (pCameraNode) {
        auto pCamera = scene.GetCamera(pCameraNode->GetSceneObjectRef());
        // Set the field of view and screen aspect ratio.
        fieldOfView = dynamic_pointer_cast<SceneObjectPerspectiveCamera>(pCamera)->GetFov();
        nearClipDistance = pCamera->GetNearClipDistance();
        farClipDistance = pCamera->GetFarClipDistance();
    }

    const GfxConfiguration& conf = g_pApp->GetConfiguration();

    float screenAspect = (float)conf.screenWidth / (float)conf.screenHeight;

    // Build the perspective projection matrix.
    BuildPerspectiveFovRHMatrix(frameContext.m_projectionMatrix, fieldOfView, screenAspect, nearClipDistance, farClipDistance);
}

void GraphicsManager::CalculateLights()
{
    DrawFrameContext& frameContext = m_Frames[m_nFrameIndex].frameContext;
    frameContext.m_ambientColor = { 0.01f, 0.01f, 0.01f };
    frameContext.m_lights.clear();

    auto& scene = g_pSceneManager->GetSceneForRendering();
    for (auto LightNode : scene.LightNodes) {
        Light& light = *(new Light());
        auto pLightNode = LightNode.second.lock();
        if (!pLightNode) continue;
        auto trans_ptr = pLightNode->GetCalculatedTransform();
        Transform(light.m_lightPosition, *trans_ptr);
        Transform(light.m_lightDirection, *trans_ptr);

        auto pLight = scene.GetLight(pLightNode->GetSceneObjectRef());
        if (pLight) {
            light.m_lightGuid = pLight->GetGuid();
            light.m_lightColor = pLight->GetColor().Value;
            light.m_lightIntensity = pLight->GetIntensity();
            light.m_lightCastShadow = pLight->GetIfCastShadow();
            const AttenCurve& atten_curve = pLight->GetDistanceAttenuation();
            light.m_lightDistAttenCurveType = atten_curve.type; 
            memcpy(light.m_lightDistAttenCurveParams, &atten_curve.u, sizeof(atten_curve.u));

            Matrix4X4f view;
            Matrix4X4f projection;
            BuildIdentityMatrix(projection);
            Vector3f position;
            memcpy(&position, &light.m_lightPosition, sizeof position); 
            Vector4f tmp = light.m_lightPosition + light.m_lightDirection;
            Vector3f lookAt; 
            memcpy(&lookAt, &tmp, sizeof lookAt);
            Vector3f up = { 0.0f, 0.0f, 1.0f };
            if (abs(light.m_lightDirection[0]) <= 0.01f
                && abs(light.m_lightDirection[1]) <= 0.01f)
            {
                up = { 0.0f, 1.0f, 0.0f};
            }
            BuildViewRHMatrix(view, position, lookAt, up);

            if (pLight->GetType() == SceneObjectType::kSceneObjectTypeLightInfi)
            {
                light.m_lightPosition[3] = 0.0f;
            }
            else if (pLight->GetType() == SceneObjectType::kSceneObjectTypeLightSpot)
            {
                auto plight = dynamic_pointer_cast<SceneObjectSpotLight>(pLight);
                const AttenCurve& angle_atten_curve = plight->GetAngleAttenuation();
                light.m_lightAngleAttenCurveType = angle_atten_curve.type;
                memcpy(light.m_lightAngleAttenCurveParams, &angle_atten_curve.u, sizeof(angle_atten_curve.u));

                float fieldOfView = light.m_lightAngleAttenCurveParams[1] * 2.0f;
                float nearClipDistance = 1.0f;
                float farClipDistance = 100.0f;
                float screenAspect = 1.0f;

                // Build the perspective projection matrix.
                BuildPerspectiveFovRHMatrix(projection, fieldOfView, screenAspect, nearClipDistance, farClipDistance);
            }
            else if (pLight->GetType() == SceneObjectType::kSceneObjectTypeLightArea)
            {
                auto plight = dynamic_pointer_cast<SceneObjectAreaLight>(pLight);
                light.m_lightSize = plight->GetDimension();
            }

            light.m_lightVP = view * projection;
        }
        else
        {
            assert(0);
        }

        frameContext.m_lights.push_back(std::move(light));
    }
}

void GraphicsManager::InitializeBuffers(const Scene& scene)
{
    cout << "[GraphicsManager] InitializeBuffers()" << endl;
}

void GraphicsManager::ClearBuffers()
{
    cout << "[GraphicsManager] ClearBuffers()" << endl;
}

#ifdef DEBUG
void GraphicsManager::RenderDebugBuffers()
{
    cout << "[GraphicsManager] RenderDebugBuffers()" << endl;
}

void GraphicsManager::DrawPoint(const Point& point, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawPoint(" << point << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawPointSet(const PointSet& point_set, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawPointSet(" << point_set.size() << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawPointSet(const PointSet& point_set, const Matrix4X4f& trans, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawPointSet(" << point_set.size() << ","
        << trans << "," 
        << color << ")" << endl;
}

void GraphicsManager::DrawLine(const Point& from, const Point& to, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawLine(" << from << ","
        << to << "," 
        << color << ")" << endl;
}

void GraphicsManager::DrawLine(const PointList& vertices, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawLine(" << vertices.size() << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawLine(const PointList& vertices, const Matrix4X4f& trans, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawLine(" << vertices.size() << ","
        << trans << "," 
        << color << ")" << endl;
}

void GraphicsManager::DrawEdgeList(const EdgeList& edges, const Vector3f& color)
{
    PointList point_list;

    for (auto edge : edges)
    {
        point_list.push_back(edge->first);
        point_list.push_back(edge->second);
    }

    DrawLine(point_list, color);
}

void GraphicsManager::DrawTriangle(const PointList& vertices, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawTriangle(" << vertices.size() << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawTriangle(const PointList& vertices, const Matrix4X4f& trans, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawTriangle(" << vertices.size() << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawTriangleStrip(const PointList& vertices, const Vector3f& color)
{
    cout << "[GraphicsManager] DrawTriangleStrip(" << vertices.size() << ","
        << color << ")" << endl;
}

void GraphicsManager::DrawPolygon(const Face& polygon, const Vector3f& color)
{
    PointSet vertices;
    PointList edges;
    for (auto pEdge : polygon.Edges)
    {
        vertices.insert({pEdge->first, pEdge->second});
        edges.push_back(pEdge->first);
        edges.push_back(pEdge->second);
    }
    DrawLine(edges, color);

    DrawPointSet(vertices, color);

    DrawTriangle(polygon.GetVertices(), color * 0.5f);
}

void GraphicsManager::DrawPolygon(const Face& polygon, const Matrix4X4f& trans, const Vector3f& color)
{
    PointSet vertices;
    PointList edges;
    for (auto pEdge : polygon.Edges)
    {
        vertices.insert({pEdge->first, pEdge->second});
        edges.push_back(pEdge->first);
        edges.push_back(pEdge->second);
    }
    DrawLine(edges, trans, color);

    DrawPointSet(vertices, trans, color);

    DrawTriangle(polygon.GetVertices(), trans, color * 0.5f);
}

void GraphicsManager::DrawPolyhydron(const Polyhedron& polyhedron, const Vector3f& color)
{
    for (auto pFace : polyhedron.Faces)
    {
        DrawPolygon(*pFace, color);
    }
}

void GraphicsManager::DrawPolyhydron(const Polyhedron& polyhedron, const Matrix4X4f& trans, const Vector3f& color)
{
    for (auto pFace : polyhedron.Faces)
    {
        DrawPolygon(*pFace, trans, color);
    }
}

void GraphicsManager::DrawBox(const Vector3f& bbMin, const Vector3f& bbMax, const Vector3f& color)
{
    //  ******0--------3********
    //  *****/:       /|********
    //  ****1--------2 |********
    //  ****| :      | |********
    //  ****| 4- - - | 7********
    //  ****|/       |/*********
    //  ****5--------6**********

    // vertices
    PointPtr points[8];
    for (int i = 0; i < 8; i++)
        points[i] = make_shared<Point>(bbMin);
    *points[0] = *points[2] = *points[3] = *points[7] = bbMax;
    points[0]->data[0] = bbMin[0];
    points[2]->data[1] = bbMin[1];
    points[7]->data[2] = bbMin[2];
    points[1]->data[2] = bbMax[2];
    points[4]->data[1] = bbMax[1];
    points[6]->data[0] = bbMax[0];

    // edges
    EdgeList edges;
    
    // top
    edges.push_back(make_shared<Edge>(make_pair(points[0], points[3])));
    edges.push_back(make_shared<Edge>(make_pair(points[3], points[2])));
    edges.push_back(make_shared<Edge>(make_pair(points[2], points[1])));
    edges.push_back(make_shared<Edge>(make_pair(points[1], points[0])));

    // bottom
    edges.push_back(make_shared<Edge>(make_pair(points[4], points[7])));
    edges.push_back(make_shared<Edge>(make_pair(points[7], points[6])));
    edges.push_back(make_shared<Edge>(make_pair(points[6], points[5])));
    edges.push_back(make_shared<Edge>(make_pair(points[5], points[4])));

    // side
    edges.push_back(make_shared<Edge>(make_pair(points[0], points[4])));
    edges.push_back(make_shared<Edge>(make_pair(points[1], points[5])));
    edges.push_back(make_shared<Edge>(make_pair(points[2], points[6])));
    edges.push_back(make_shared<Edge>(make_pair(points[3], points[7])));

    DrawEdgeList(edges, color);
}

void GraphicsManager::ClearDebugBuffers()
{
    cout << "[GraphicsManager] ClearDebugBuffers(void)" << endl;
}

void GraphicsManager::DrawOverlay(const intptr_t shadowmap, uint32_t layer_index, float vp_left, float vp_top, float vp_width, float vp_height)
{
    cout << "[GraphicsManager] DrayOverlay(" << shadowmap << ", "
        << layer_index << ", "
        << vp_left << ", "
        << vp_top << ", "
        << vp_width << ", "
        << vp_height << ", "
        << ")" << endl;
}

#endif

void GraphicsManager::UseShaderProgram(const intptr_t shaderProgram)
{
    cout << "[GraphicsManager] UseShaderProgram(" << shaderProgram << ")" << endl;
}

void GraphicsManager::SetPerFrameConstants(const DrawFrameContext& context)
{
    cout << "[GraphicsManager] SetPerFrameConstants(" << &context << ")" << endl;
}

void GraphicsManager::DrawBatch(const DrawBatchContext& context)
{
    cout << "[GraphicsManager] DrawBatch(" << &context << ")" << endl;
}

void GraphicsManager::DrawBatchDepthOnly(const DrawBatchContext& context)
{
    cout << "[GraphicsManager] DrawBatchDepthOnly(" << &context << ")" << endl;
}

intptr_t GraphicsManager::GenerateShadowMapArray(uint32_t count)
{
    cout << "[GraphicsManager] GenerateShadowMap(" << count << ")" << endl;
    return 0;
}

void GraphicsManager::BeginShadowMap(const Light& light, const intptr_t shadowmap, uint32_t layer_index)
{
    cout << "[GraphicsManager] BeginShadowMap(" << light.m_lightGuid << ", " << shadowmap << ", " << layer_index << ")" << endl;
}

void GraphicsManager::EndShadowMap(const intptr_t shadowmap, uint32_t layer_index)
{
    cout << "[GraphicsManager] EndShadowMap(" << shadowmap << ", " << layer_index << ")" << endl;
}

void GraphicsManager::SetShadowMap(const intptr_t shadowmap)
{
    cout << "[GraphicsManager] SetShadowMap(" << shadowmap << ")" << endl;
}

void GraphicsManager::DestroyShadowMap(intptr_t& shadowmap)
{
    cout << "[GraphicsManager] DestroyShadowMap(" << shadowmap << ")" << endl;
    shadowmap = -1;
}
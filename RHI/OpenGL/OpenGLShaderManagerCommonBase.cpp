#include <iostream>
#include <fstream>
#include "AssetLoader.hpp"
#include "GraphicsManager.hpp"

using namespace qg;
using namespace std;

namespace qg {
    extern AssetLoader* g_pAssetLoader;

    static void OutputShaderErrorMessage(unsigned int shaderId, const char* shaderFilename)
    {
        int logSize, i;
        char* infoLog;
        ofstream fout;

        // Get the size of the string containing the information log for the failed shader compilation message.
        glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &logSize);

        // Increment the size by one to handle also the null terminator.
        logSize++;

        // Create a char buffer to hold the info log.
        infoLog = new char[logSize];
        if(!infoLog)
        {
                return;
        }

        // Now retrieve the info log.
        glGetShaderInfoLog(shaderId, logSize, NULL, infoLog);

        // Open a file to write the error message to.
        fout.open("shader-error.txt");

        // Write out the error message.
        for(i=0; i<logSize; i++)
        {
                fout << infoLog[i];
        }

        // Close the file.
        fout.close();

        // Pop a message up on the screen to notify the user to check the text file for compile errors.
        cerr << "Error compiling shader.  Check shader-error.txt for message." << shaderFilename << endl;

        return;
    }

    static void OutputLinkerErrorMessage(unsigned int programId)
    {
        int logSize, i;
        char* infoLog;
        ofstream fout;


        // Get the size of the string containing the information log for the failed shader compilation message.
        glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &logSize);

        // Increment the size by one to handle also the null terminator.
        logSize++;

        // Create a char buffer to hold the info log.
        infoLog = new char[logSize];
        if(!infoLog)
        {
                return;
        }

        // Now retrieve the info log.
        glGetProgramInfoLog(programId, logSize, NULL, infoLog);

        // Open a file to write the error message to.
        fout.open("linker-error.txt");

        // Write out the error message.
        for(i=0; i<logSize; i++)
        {
                fout << infoLog[i];
        }

        // Close the file.
        fout.close();

        // Pop a message up on the screen to notify the user to check the text file for linker errors.
        cerr << "Error compiling linker.  Check linker-error.txt for message." << endl;
    }

    static bool LoadShaderFromFile(const char* filename, const GLenum shaderType, GLuint& shader)
    {
        std::string cbufferShaderBuffer;
        std::string commonShaderBuffer;
        std::string shaderBuffer;
        int status;

        // Load the shader source file into a text buffer.
        shaderBuffer = g_pAssetLoader->SyncOpenAndReadTextFileToString(filename);
        if(shaderBuffer.empty())
        {
            return false;
        }

        shaderBuffer = cbufferShaderBuffer + commonShaderBuffer + shaderBuffer;

        // Create a shader object.
        shader = glCreateShader(shaderType);

        // Copy the shader source code strings into the shader objects.
        const char* pStr = shaderBuffer.c_str();
        glShaderSource(shader, 1, &pStr, NULL);

        // Compile the shaders.
        glCompileShader(shader);

        // Check to see if the shader compiled successfully.
        glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
        if(status != 1)
        {
                // If it did not compile then write the syntax error message out to a text file for review.
                OutputShaderErrorMessage(shader, filename);
                return false;
        }

        return true;
    }

    typedef vector<pair<GLenum, string>> ShaderSourceList;

    static bool LoadShaderProgram(const ShaderSourceList& source, GLuint& shaderProgram)
    {
        int status;

        // Create a shader program object.
        shaderProgram = glCreateProgram();

        for (auto it = source.cbegin(); it != source.cend(); it++)
        {
            GLuint shader;
            status = LoadShaderFromFile(it->second.c_str(), it->first, shader);
            if (!status)
            {
                return false;
            }

            // Attach the shader to the program object.
            glAttachShader(shaderProgram, shader);
            glDeleteShader(shader);
        }

        // Link the shader program.
        glLinkProgram(shaderProgram);

        // Check the status of the link.
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &status);
        if(status != 1)
        {
                // If it did not link then write the syntax error message out to a text file for review.
                OutputLinkerErrorMessage(shaderProgram);
                return false;
        }

        return true; 
    }
}

int OpenGLShaderManagerCommonBase::Initialize()
{
    return InitializeShaders() == false;
}

void OpenGLShaderManagerCommonBase::Finalize()
{
    ClearShaders();
}

void OpenGLShaderManagerCommonBase::Tick()
{

}

bool OpenGLShaderManagerCommonBase::InitializeShaders()
{
    GLuint shaderProgram;
    bool result;

    // Basic Shader
    ShaderSourceList list = {
        {GL_VERTEX_SHADER, VS_BASIC_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_BASIC_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::Basic] = shaderProgram;

    // PBR Shader
    list = {
        {GL_VERTEX_SHADER, VS_BASIC_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_PBR_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::Pbr] = shaderProgram;

    // Shadow Map Shader
    list = {
        {GL_VERTEX_SHADER, VS_SHADOWMAP_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_SHADOWMAP_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::ShadowMap] = shaderProgram;

    // Omni Shadow Map Shader
    list = {
        {GL_VERTEX_SHADER, VS_OMNI_SHADOWMAP_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_OMNI_SHADOWMAP_SOURCE_FILE},
        {GL_GEOMETRY_SHADER, GS_OMNI_SHADOWMAP_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::OmniShadowMap] = shaderProgram;

    // Depth Texture overlay shader
    list = {
        {GL_VERTEX_SHADER, VS_PASSTHROUGH_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_DEPTH_TEXTURE_ARRAY_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::DepthCopy] = shaderProgram;

    // Depth CubeMap overlay shader
    list = {
        {GL_VERTEX_SHADER, VS_PASSTHROUGH_CUBEMAP_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_DEPTH_CUBEMAP_ARRAY_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::DepthCopyCube] = shaderProgram;

    // Texture overlay shader
    list = {
        {GL_VERTEX_SHADER, VS_PASSTHROUGH_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_TEXTURE_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::Copy] = shaderProgram;

    // CubeMap overlay shader
    list = {
        {GL_VERTEX_SHADER, VS_PASSTHROUGH_CUBEMAP_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_CUBEMAP_ARRAY_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::CopyCube] = shaderProgram;

    // SkyBox shader
    list = {
        {GL_VERTEX_SHADER, VS_SKYBOX_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_SKYBOX_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::SkyBox] = shaderProgram;

    // Terrain shader
    list = {
        {GL_VERTEX_SHADER, VS_TERRAIN_SOURCE_FILE},
        {GL_TESS_CONTROL_SHADER, TESC_TERRAIN_SOURCE_FILE},
        {GL_TESS_EVALUATION_SHADER, TESE_TERRAIN_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_TERRAIN_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::Terrain] = shaderProgram;

#ifdef DEBUG
    // Debug Shader
    list = {
        {GL_VERTEX_SHADER, DEBUG_VS_SHADER_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, DEBUG_PS_SHADER_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::Debug] = shaderProgram;
#endif

    // BRDF PS
    list = {
        {GL_VERTEX_SHADER, VS_PASSTHROUGH_SOURCE_FILE},
        {GL_FRAGMENT_SHADER, PS_PBR_BRDF_SOURCE_FILE}
    };

    result = LoadShaderProgram(list, shaderProgram);
    if (!result)
    {
        return result;
    }

    m_DefaultShaders[DefaultShaderIndex::PbrBrdfPs] = shaderProgram;

    /////////////////
    // CS Shaders

    if(g_pGraphicsManager->CheckCapability(RHICapability::COMPUTE_SHADER))
    {
        // BRDF
        list = {
            {GL_COMPUTE_SHADER, CS_PBR_BRDF_SOURCE_FILE}
        };

        result = LoadShaderProgram(list, shaderProgram);
        if (!result)
        {
            return result;
        }

        m_DefaultShaders[DefaultShaderIndex::PbrBrdf] = shaderProgram;
    }

    return result;
}

void OpenGLShaderManagerCommonBase::ClearShaders()
{
    for (auto item : m_DefaultShaders)
    {
        glDeleteProgram((GLuint) item.second);
    }
}
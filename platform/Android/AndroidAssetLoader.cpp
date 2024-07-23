#include <string>
#include "AndroidAssetLoader.hpp"
#include "platform_defs.hpp"

using namespace qg;
using namespace std;

void AndroidAssetLoader::SetPlatformAssetManager(AAssetManager* assetManager)
{
    m_pPlatformAssetManager = assetManager;
}

AndroidAssetLoader::AssetFilePtr AndroidAssetLoader::OpenFile(const char* name, AssetOpenMode mode)
{
    LOGI("Open Asset: %s", name);
    AAsset* fp = nullptr;;
    if(m_pPlatformAssetManager)
    	fp = AAssetManager_open(m_pPlatformAssetManager, name, AASSET_MODE_BUFFER);
    else {
    	LOGE("m_pPlatfornAssetManager is null!");
    }
    LOGI("fp: %p", fp);
    return (AssetFilePtr)fp;
}

Buffer AndroidAssetLoader::SyncOpenAndReadText(const char* assetPath)
{
    AAsset* fp = (AAsset*)OpenFile(assetPath, qg_OPEN_TEXT);
    Buffer* pBuff = nullptr;

    if (fp) {
        size_t fileLength = AAsset_getLength(fp);
        LOGD("asset file size: %zu", fileLength);

        pBuff = new Buffer(fileLength + 1);
        AAsset_read(fp, pBuff->GetData(), fileLength);
        pBuff->GetData()[fileLength] = '\0';
        AAsset_close(fp);
    } else {
        LOGE("Error opening asset file '%s'", assetPath);
        pBuff = new Buffer();
    }

    return *pBuff;
}

Buffer AndroidAssetLoader::SyncOpenAndReadBinary(const char* assetPath)
{
    AAsset* fp = (AAsset*)OpenFile(assetPath, qg_OPEN_BINARY);
    Buffer* pBuff = nullptr;

    if (fp) {
        size_t fileLength = AAsset_getLength(fp);
        LOGD("asset file size: %zu", fileLength);

        pBuff = new Buffer(fileLength);
        AAsset_read(fp, pBuff->GetData(), fileLength);
        AAsset_close(fp);
    } else {
        LOGE("Error opening asset file '%s'", assetPath);
        pBuff = new Buffer();
    }

    return *pBuff;
}
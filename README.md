# Run
Press `ctrl + shift + b` to start `tasks.json` to generate the external lib required by the project,  
and then compile the all project.  

Start `build_shader.bat` to generate shaders for each graphics api.  

Press `F5` to start project. You can modify the parameters in `launch.json`.  

Use `cmft.exe` to generate radiance texture and irridiance texture.
*Example:*  
``` shell
cmft.exe --useOpenCL true --inputFacePosX Asset\Textures\sor_sea\sea_posx.tga --inputFaceNegX Asset\Textures\sor_sea\sea_negx.tga --inputFacePosY Asset\Textures\sor_sea\sea_posy.tga --inputFaceNegY Asset\Textures\sor_sea\sea_negy.tga --inputFacePosZ Asset\Textures\sor_sea\sea_posz.tga --inputFaceNegZ Asset\Textures\sor_sea\sea_negz.tga --filter irradiance --outputNum 1 --output0 Asset\Textures\sor_sea\sea_irradiance --output0params tga,bgr8,facelist --dstFaceSize 1024

cmft.exe --useOpenCL true --clVendor anyGpuVendor --deviceType gpu --deviceIndex 0 --inputFacePosX Asset\Textures\sor_sea\sea_posx.tga --inputFaceNegX Asset\Textures\sor_sea\sea_negx.tga --inputFacePosY Asset\Textures\sor_sea\sea_posy.tga --inputFaceNegY Asset\Textures\sor_sea\sea_negy.tga --inputFacePosZ Asset\Textures\sor_sea\sea_posz.tga --inputFaceNegZ Asset\Textures\sor_sea\sea_negz.tga --filter radiance --excludeBase false --mipCount 9 --glossScale 10 --glossBias 1 --lightingModel phongbrdf --outputNum 2 --output0 Asset\Textures\sor_sea\sea_radiance --output0params dds,rgba16f,vstrip --output1 Asset\Textures\sor_sea\sea_radiance_preview --output1params tga,bgr8,facelist
```